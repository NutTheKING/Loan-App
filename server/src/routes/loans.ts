import type { FastifyInstance } from 'fastify';
import { randomUUID } from 'node:crypto';
import { DocumentKind, LoanStatus, Prisma } from '@prisma/client';
import { z } from 'zod';

import type { AppConfig } from '../lib/config.js';
import { sendPushToUsers } from '../lib/firebase.js';
import { findLoanApplicationBlock } from '../lib/loan-eligibility.js';
import { createRepaymentSchedule, calculateLoanQuote } from '../lib/loan-policy.js';
import { getActiveLoanProduct, productToPolicy, serializeLoanProduct } from '../lib/loan-products.js';
import { findUserIdsWithPermission, Permissions } from '../lib/permissions.js';
import { prisma } from '../lib/prisma.js';
import { serializeLoan, serializeLoanDocument } from '../lib/serializers.js';
import { readPrivateDocument, savePrivateDocument } from '../lib/storage.js';
import { requireAuthentication, requirePermission } from '../plugins/auth.js';

const applicationSchema = z.object({
  amount: z.coerce.number().finite(),
  termMonths: z.coerce.number().int(),
  acceptTerms: z.literal(true),
  actualName: z.string().trim().min(2).max(120),
  idCardNumber: z.string().trim().min(4).max(64),
  currentJob: z.string().trim().min(2).max(120),
  gender: z.string().trim().min(1).max(40),
  stableIncome: z.coerce.number().positive().max(999999999),
  loanPurpose: z.string().trim().min(2).max(300),
  currentAddress: z.string().trim().min(5).max(500),
  guarantorName: z.string().trim().min(2).max(120),
  guarantorPhone: z.string().trim().min(7).max(30),
  beneficiaryBank: z.string().trim().min(2).max(120),
  accountName: z.string().trim().min(2).max(120),
  accountNumber: z.string().trim().min(4).max(64),
  productId: z.string().uuid().optional(),
});

const loanIdParams = z.object({ loanId: z.string().uuid() });

function uniqueLoanNumber(): string {
  return `LN-${new Date().toISOString().slice(0, 10).replaceAll('-', '')}-${randomUUID().slice(0, 8).toUpperCase()}`;
}

function canReadLoan(userId: string, permissions: string[], loan: { borrowerId: string }): boolean {
  return loan.borrowerId === userId || permissions.includes(Permissions.loansRead);
}

export async function registerLoanRoutes(app: FastifyInstance, config: AppConfig): Promise<void> {
  app.get('/loan-products/current', {
    schema: { tags: ['Loan products'], summary: 'Get the active loan product rules' },
  }, async (_request, reply) => {
    const product = await getActiveLoanProduct();
    if (!product) {
      return reply.code(503).send({ error: 'LOAN_PRODUCT_UNAVAILABLE', message: 'No active loan package is available.' });
    }
    return { product: serializeLoanProduct(product) };
  });

  app.get('/loan-products', {
    schema: { tags: ['Loan products'], summary: 'List active loan packages' },
  }, async () => {
    const products = await prisma.loanProduct.findMany({ where: { isActive: true }, orderBy: [{ isDefault: 'desc' }, { name: 'asc' }] });
    return { products: products.map(serializeLoanProduct) };
  });

  app.post('/loans', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'Submit a loan application' },
  }, async (request, reply) => {
    const body = applicationSchema.parse(request.body);
    const product = await getActiveLoanProduct(body.productId);
    if (!product) {
      return reply.code(400).send({ error: 'INVALID_LOAN_PRODUCT', message: 'The selected loan package is unavailable.' });
    }
    const applicationBlock = await findLoanApplicationBlock(request.user.sub);
    if (applicationBlock) {
      return reply.code(409).send({
        error: applicationBlock.reason,
        message: applicationBlock.message,
        loan: applicationBlock,
      });
    }
    const policy = productToPolicy(product);
    let quote;
    let schedule;
    try {
      quote = calculateLoanQuote(body.amount, body.termMonths, policy);
      schedule = createRepaymentSchedule(body.amount, body.termMonths, new Date(), policy);
    } catch (error) {
      return reply.code(400).send({
        error: 'INVALID_LOAN_QUOTE',
        message: error instanceof Error ? error.message : 'The requested loan is outside the active package rules.',
      });
    }

    const draft = await prisma.loan.findFirst({
      where: {
        borrowerId: request.user.sub,
        status: LoanStatus.PENDING,
        submittedAt: null,
      },
      orderBy: { createdAt: 'desc' },
      select: { id: true },
    });
    let loan;
    try {
      loan = await prisma.$transaction(async (transaction) => {
        const applicationData = {
          loanNumber: uniqueLoanNumber(),
          currency: policy.currency,
          principal: quote.principal,
          termMonths: body.termMonths,
          monthlyInterestRate: policy.monthlyInterestRate,
          interestAmount: quote.interestAmount,
          totalRepayment: quote.totalRepayment,
          monthlyPayment: quote.monthlyPayment,
          acceptedTermsAt: new Date(),
          actualName: body.actualName,
          idCardNumber: body.idCardNumber,
          currentJob: body.currentJob,
          gender: body.gender,
          stableIncome: body.stableIncome,
          loanPurpose: body.loanPurpose,
          currentAddress: body.currentAddress,
          guarantorName: body.guarantorName,
          guarantorPhone: body.guarantorPhone,
          beneficiaryBank: body.beneficiaryBank,
          accountName: body.accountName,
          accountNumber: body.accountNumber,
          productId: product.id,
          submittedAt: null,
        };
        if (draft) {
          await transaction.repayment.deleteMany({ where: { loanId: draft.id } });
          return transaction.loan.update({
            where: { id: draft.id },
            data: {
              ...applicationData,
              repayments: { create: schedule },
            },
            include: { repayments: true, documents: true },
          });
        }
        return transaction.loan.create({
          data: {
            ...applicationData,
            borrowerId: request.user.sub,
            repayments: { create: schedule },
          },
          include: { repayments: true, documents: true },
        });
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        return reply.code(409).send({
          error: 'PENDING_LOAN_EXISTS',
          message: 'You already have a pending loan application.',
        });
      }
      throw error;
    }

    return reply.status(draft ? 200 : 201).send({ loan: serializeLoan(loan) });
  });

  app.post('/loans/:loanId/submit', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'Finalize a loan after every document is uploaded' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const loan = await prisma.loan.findUnique({
      where: { id: loanId },
      include: { documents: true, repayments: { orderBy: { installment: 'asc' } } },
    });
    if (!loan || loan.borrowerId !== request.user.sub) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan draft not found.' });
    }
    if (loan.status !== LoanStatus.PENDING) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'Only pending loan drafts can be submitted.' });
    }
    if (loan.submittedAt) {
      return { loan: serializeLoan(loan) };
    }

    const requiredDocuments = Object.values(DocumentKind);
    const uploadedDocuments = new Set(loan.documents.map((document) => document.kind));
    const missingDocuments = requiredDocuments.filter((kind) => !uploadedDocuments.has(kind));
    if (missingDocuments.length > 0) {
      return reply.code(409).send({
        error: 'DOCUMENTS_INCOMPLETE',
        message: `Upload every required document before submitting: ${missingDocuments.join(', ')}.`,
      });
    }
    const applicationBlock = await findLoanApplicationBlock(
      request.user.sub,
      loan.id,
    );
    if (applicationBlock) {
      return reply.code(409).send({
        error: applicationBlock.reason,
        message: applicationBlock.message,
        loan: applicationBlock,
      });
    }

    const reviewerIds = (await findUserIdsWithPermission(Permissions.loansRead)).filter(
      (userId) => userId !== request.user.sub,
    );
    const submittedLoan = await prisma.$transaction(async (transaction) => {
      const submittedAt = new Date();
      const update = await transaction.loan.updateMany({
        where: { id: loan.id, submittedAt: null, status: LoanStatus.PENDING },
        data: { submittedAt },
      });
      if (update.count !== 1) {
        return transaction.loan.findUniqueOrThrow({
          where: { id: loan.id },
          include: { documents: true, repayments: { orderBy: { installment: 'asc' } } },
        });
      }
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'LOAN_SUBMITTED',
          entityType: 'Loan',
          entityId: loan.id,
        },
      });
      await transaction.notification.create({
        data: {
          userId: request.user.sub,
          title: 'Application submitted',
          body: `Your loan ${loan.loanNumber} is pending review.`,
          payload: '/home',
        },
      });
      if (reviewerIds.length > 0) {
        await transaction.notification.createMany({
          data: reviewerIds.map((userId) => ({
            userId,
            title: 'New loan application',
            body: `${loan.actualName} submitted ${loan.loanNumber} for review.`,
            payload: '/admin',
          })),
        });
      }
      return transaction.loan.findUniqueOrThrow({
        where: { id: loan.id },
        include: { documents: true, repayments: { orderBy: { installment: 'asc' } } },
      });
    });

    void sendPushToUsers(reviewerIds, {
      title: 'New loan application',
      body: `${loan.actualName} submitted ${loan.loanNumber} for review.`,
      payload: '/admin',
    }).catch((error) => app.log.warn({ err: error }, 'Unable to send reviewer push notification'));

    return { loan: serializeLoan(submittedLoan) };
  });

  app.get('/loans', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'List the signed-in customer loans' },
  }, async (request) => {
    const loans = await prisma.loan.findMany({
      where: { borrowerId: request.user.sub, submittedAt: { not: null } },
      include: { repayments: { orderBy: { installment: 'asc' } }, documents: true },
      orderBy: { createdAt: 'desc' },
    });
    return { loans: loans.map(serializeLoan) };
  });

  app.get('/loans/:loanId', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'Get a loan and repayment schedule' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const loan = await prisma.loan.findUnique({
      where: { id: loanId },
      include: { repayments: { orderBy: { installment: 'asc' } }, documents: true },
    });
    if (!loan || !canReadLoan(request.user.sub, request.permissions, loan)) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan not found.' });
    }
    return { loan: serializeLoan(loan) };
  });

  app.post('/loans/:loanId/documents', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loan documents'], summary: 'Attach an ID, selfie, or signature to a pending loan' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const loan = await prisma.loan.findUnique({ where: { id: loanId } });
    if (!loan || loan.borrowerId !== request.user.sub) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan not found.' });
    }
    if (loan.status !== LoanStatus.PENDING || loan.submittedAt) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'Documents can only be changed before the application is submitted.' });
    }

    const upload = await request.file({ limits: { fileSize: config.MAX_UPLOAD_BYTES, files: 1 } });
    if (!upload) {
      return reply.code(400).send({ error: 'VALIDATION_ERROR', message: 'A document file is required.' });
    }
    const kindValue = upload.fields.kind;
    const kindField = Array.isArray(kindValue) ? kindValue[0] : kindValue;
    const kind = DocumentKindSchema.parse(kindField?.type === 'field' ? kindField.value : undefined);
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(upload.mimetype)) {
      return reply.code(415).send({ error: 'UNSUPPORTED_MEDIA_TYPE', message: 'Only JPG, PNG, and WEBP images are accepted.' });
    }

    const bytes = await upload.toBuffer();
    const storageKey = await savePrivateDocument(config, { loanId, filename: upload.filename, bytes });
    const existingDocument = await prisma.loanDocument.findUnique({
      where: { loanId_kind: { loanId, kind } },
      select: { id: true },
    });
    const documentId = existingDocument?.id ?? randomUUID();
    const url = `/api/v1/loans/${loanId}/documents/${documentId}`;
    const document = await prisma.loanDocument.upsert({
      where: { loanId_kind: { loanId, kind } },
      create: { id: documentId, loanId, kind, storageKey, url, fileName: upload.filename, mimeType: upload.mimetype, sizeBytes: bytes.byteLength },
      update: { storageKey, url, fileName: upload.filename, mimeType: upload.mimetype, sizeBytes: bytes.byteLength, createdAt: new Date() },
    });
    return reply.status(201).send({
      document: serializeLoanDocument(document),
    });
  });

  app.get('/loans/:loanId/documents/:documentId', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loan documents'], summary: 'Download a private loan document' },
  }, async (request, reply) => {
    const params = z.object({ loanId: z.string().uuid(), documentId: z.string().uuid() }).parse(request.params);
    const document = await prisma.loanDocument.findFirst({
      where: { id: params.documentId, loanId: params.loanId },
      include: { loan: { select: { borrowerId: true } } },
    });
    if (!document || !canReadLoan(request.user.sub, request.permissions, document.loan)) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Document not found.' });
    }
    const content = await readPrivateDocument(config, document.storageKey);
    return reply.type(document.mimeType).header('Content-Disposition', `attachment; filename="${document.fileName}"`).send(content);
  });

  app.get('/admin/loans', {
    onRequest: [requirePermission(Permissions.loansRead)],
    schema: { tags: ['Staff'], summary: 'List loan applications for review' },
  }, async (request) => {
    const query = z.object({ status: z.nativeEnum(LoanStatus).optional() }).parse(request.query);
    const loans = await prisma.loan.findMany({
      where: {
        submittedAt: { not: null },
        ...(query.status ? { status: query.status } : {}),
      },
      include: {
        borrower: {
          select: {
            id: true,
            fullName: true,
            email: true,
            idNumber: true,
            phone: true,
            dateOfBirth: true,
            gender: true,
            address: true,
            profilePhotoUrl: true,
          },
        },
        documents: true,
        product: true,
        repayments: { orderBy: { installment: 'asc' } },
      },
      orderBy: { createdAt: 'asc' },
    });
    return { loans: loans.map(serializeLoan) };
  });

  app.get('/admin/loans/:loanId', {
    onRequest: [requirePermission(Permissions.loansRead)],
    schema: { tags: ['Staff'], summary: 'View a complete loan application' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const loan = await prisma.loan.findFirst({
      where: { id: loanId, submittedAt: { not: null } },
      include: {
        borrower: {
          select: {
            id: true,
            fullName: true,
            email: true,
            idNumber: true,
            phone: true,
            dateOfBirth: true,
            gender: true,
            address: true,
            profilePhotoUrl: true,
            isActive: true,
            lastLoginAt: true,
            lastSeenAt: true,
          },
        },
        documents: true,
        product: true,
        repayments: { orderBy: { installment: 'asc' } },
        transactions: { orderBy: { occurredAt: 'desc' } },
      },
    });
    if (!loan) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Loan application not found.',
      });
    }
    return { loan: serializeLoan(loan) };
  });

  app.post('/admin/loans/:loanId/request-information', {
    onRequest: [requirePermission(Permissions.loansReview)],
    schema: { tags: ['Staff'], summary: 'Ask a borrower for more application information' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const body = z.object({
      reason: z.string().trim().min(3).max(1000),
    }).parse(request.body);
    const loan = await prisma.loan.findUnique({ where: { id: loanId } });
    if (!loan || !loan.submittedAt) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Loan application not found.',
      });
    }
    if (loan.status !== LoanStatus.PENDING) {
      return reply.code(409).send({
        error: 'CONFLICT',
        message: 'Information can only be requested for pending applications.',
      });
    }
    const updatedLoan = await prisma.$transaction(async (transaction) => {
      const updated = await transaction.loan.update({
        where: { id: loanId },
        data: {
          reviewerNote: body.reason,
          informationRequestedAt: new Date(),
        },
      });
      await transaction.notification.create({
        data: {
          userId: loan.borrowerId,
          title: 'More loan information required',
          body: body.reason,
          payload: '/notifications',
        },
      });
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'LOAN_INFORMATION_REQUESTED',
          entityType: 'Loan',
          entityId: loanId,
          metadata: { reason: body.reason },
        },
      });
      return updated;
    });
    void sendPushToUsers([loan.borrowerId], {
      title: 'More loan information required',
      body: body.reason,
      payload: '/notifications',
    }).catch((error) =>
      app.log.warn({ err: error }, 'Unable to send information request push notification'),
    );
    return { loan: serializeLoan(updatedLoan) };
  });

  app.patch('/admin/loans/:loanId/status', {
    onRequest: [requirePermission(Permissions.loansReview)],
    schema: { tags: ['Staff'], summary: 'Approve or reject a pending loan' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const body = z
      .object({
        status: z.enum([LoanStatus.APPROVED, LoanStatus.REJECTED]),
        reviewerNote: z.string().trim().max(1000).optional(),
      })
      .superRefine((value, context) => {
        if (
          value.status === LoanStatus.REJECTED
          && !value.reviewerNote?.trim()
        ) {
          context.addIssue({
            code: 'custom',
            path: ['reviewerNote'],
            message: 'A rejection reason is required.',
          });
        }
      })
      .parse(request.body);
    const loan = await prisma.loan.findUnique({ where: { id: loanId } });
    if (!loan) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan not found.' });
    }
    if (loan.status !== LoanStatus.PENDING || !loan.submittedAt) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'Only pending loans can be reviewed.' });
    }

    const updatedLoan = await prisma.$transaction(async (transaction) => {
      const update = await transaction.loan.updateMany({
        where: { id: loanId, status: LoanStatus.PENDING },
        data: {
          status: body.status,
          reviewerNote: body.reviewerNote,
          reviewedAt: new Date(),
          informationRequestedAt: null,
          disbursedAt: body.status === LoanStatus.APPROVED ? new Date() : null,
        },
      });
      if (update.count !== 1) {
        return null;
      }
      const reviewedLoan = await transaction.loan.findUniqueOrThrow({ where: { id: loanId } });
      if (body.status === LoanStatus.APPROVED) {
        await transaction.transaction.create({
          data: {
            userId: loan.borrowerId,
            loanId: loan.id,
            type: 'LOAN_DISBURSEMENT',
            status: 'COMPLETED',
            amount: loan.principal,
            currency: loan.currency,
            description: `Loan ${loan.loanNumber} approved for disbursement.`,
          },
        });
      }
      await transaction.notification.create({
        data: {
          userId: loan.borrowerId,
          title: body.status === LoanStatus.APPROVED ? 'Loan approved' : 'Loan application update',
          body: body.status === LoanStatus.APPROVED
            ? `Your loan ${loan.loanNumber} has been approved and disbursed.`
            : `Your loan ${loan.loanNumber} was rejected: ${body.reviewerNote}`,
          payload: '/home',
        },
      });
      await transaction.auditLog.create({
        data: { actorId: request.user.sub, action: `LOAN_${body.status}`, entityType: 'Loan', entityId: loan.id, metadata: { reviewerNote: body.reviewerNote } },
      });
      return reviewedLoan;
    });
    if (!updatedLoan) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'This loan was already reviewed.' });
    }
    const notificationTitle = body.status === LoanStatus.APPROVED ? 'Loan approved' : 'Loan application update';
    const notificationBody = body.status === LoanStatus.APPROVED
      ? `Your loan ${loan.loanNumber} has been approved and disbursed.`
      : `Your loan ${loan.loanNumber} was rejected: ${body.reviewerNote}`;
    void sendPushToUsers([loan.borrowerId], {
      title: notificationTitle,
      body: notificationBody,
      payload: '/home',
    }).catch((error) => app.log.warn({ err: error }, 'Unable to send borrower push notification'));
    return { loan: serializeLoan(updatedLoan) };
  });
}

const DocumentKindSchema = z.nativeEnum(DocumentKind);
