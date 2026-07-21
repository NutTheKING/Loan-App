import type { FastifyInstance } from 'fastify';
import { randomUUID } from 'node:crypto';
import { DocumentKind, LoanStatus, UserRole } from '@prisma/client';
import { z } from 'zod';

import type { AppConfig } from '../lib/config.js';
import { createRepaymentSchedule, calculateLoanQuote, loanPolicy } from '../lib/loan-policy.js';
import { prisma } from '../lib/prisma.js';
import { serializeLoan } from '../lib/serializers.js';
import { readPrivateDocument, savePrivateDocument } from '../lib/storage.js';
import { requireAuthentication, requireRoles } from '../plugins/auth.js';

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
});

const loanIdParams = z.object({ loanId: z.string().uuid() });

function uniqueLoanNumber(): string {
  return `LN-${new Date().toISOString().slice(0, 10).replaceAll('-', '')}-${randomUUID().slice(0, 8).toUpperCase()}`;
}

function canReadLoan(user: { sub: string; role: string }, loan: { borrowerId: string }): boolean {
  return loan.borrowerId === user.sub || user.role === UserRole.STAFF || user.role === UserRole.ADMIN;
}

export async function registerLoanRoutes(app: FastifyInstance, config: AppConfig): Promise<void> {
  app.get('/loan-products/current', {
    schema: { tags: ['Loan products'], summary: 'Get the active loan product rules' },
  }, async () => loanPolicy);

  app.post('/loans', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'Submit a loan application' },
  }, async (request, reply) => {
    const body = applicationSchema.parse(request.body);
    const quote = calculateLoanQuote(body.amount, body.termMonths);
    const schedule = createRepaymentSchedule(body.amount, body.termMonths);

    const loan = await prisma.$transaction(async (transaction) => {
      const createdLoan = await transaction.loan.create({
        data: {
          loanNumber: uniqueLoanNumber(),
          currency: loanPolicy.currency,
          principal: quote.principal,
          termMonths: body.termMonths,
          monthlyInterestRate: loanPolicy.monthlyInterestRate,
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
          borrowerId: request.user.sub,
          repayments: { create: schedule },
        },
        include: { repayments: true, documents: true },
      });
      await transaction.auditLog.create({
        data: { actorId: request.user.sub, action: 'LOAN_SUBMITTED', entityType: 'Loan', entityId: createdLoan.id },
      });
      return createdLoan;
    });

    return reply.status(201).send({ loan: serializeLoan(loan) });
  });

  app.get('/loans', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Loans'], summary: 'List the signed-in customer loans' },
  }, async (request) => {
    const loans = await prisma.loan.findMany({
      where: { borrowerId: request.user.sub },
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
    if (!loan || !canReadLoan(request.user, loan)) {
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
    if (loan.status !== LoanStatus.PENDING) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'Documents can only be changed while an application is pending.' });
    }

    const upload = await request.file({ limits: { fileSize: config.MAX_UPLOAD_BYTES, files: 1 } });
    if (!upload) {
      return reply.code(400).send({ error: 'VALIDATION_ERROR', message: 'A document file is required.' });
    }
    const kindValue = upload.fields.kind;
    const kind = DocumentKindSchema.parse(Array.isArray(kindValue) ? kindValue[0]?.value : kindValue?.value);
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(upload.mimetype)) {
      return reply.code(415).send({ error: 'UNSUPPORTED_MEDIA_TYPE', message: 'Only JPG, PNG, and WEBP images are accepted.' });
    }

    const bytes = await upload.toBuffer();
    const storageKey = await savePrivateDocument(config, { loanId, filename: upload.filename, bytes });
    const document = await prisma.loanDocument.upsert({
      where: { loanId_kind: { loanId, kind } },
      create: { loanId, kind, storageKey, fileName: upload.filename, mimeType: upload.mimetype, sizeBytes: bytes.byteLength },
      update: { storageKey, fileName: upload.filename, mimeType: upload.mimetype, sizeBytes: bytes.byteLength, createdAt: new Date() },
    });
    return reply.status(201).send({ document });
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
    if (!document || !canReadLoan(request.user, document.loan)) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Document not found.' });
    }
    const content = await readPrivateDocument(config, document.storageKey);
    return reply.type(document.mimeType).header('Content-Disposition', `attachment; filename="${document.fileName}"`).send(content);
  });

  app.get('/admin/loans', {
    onRequest: [requireRoles(UserRole.STAFF, UserRole.ADMIN)],
    schema: { tags: ['Staff'], summary: 'List loan applications for review' },
  }, async (request) => {
    const query = z.object({ status: z.nativeEnum(LoanStatus).optional() }).parse(request.query);
    const loans = await prisma.loan.findMany({
      where: query.status ? { status: query.status } : undefined,
      include: { borrower: { select: { id: true, fullName: true, email: true } }, documents: true },
      orderBy: { createdAt: 'asc' },
    });
    return { loans: loans.map(serializeLoan) };
  });

  app.patch('/admin/loans/:loanId/status', {
    onRequest: [requireRoles(UserRole.STAFF, UserRole.ADMIN)],
    schema: { tags: ['Staff'], summary: 'Approve or reject a pending loan' },
  }, async (request, reply) => {
    const { loanId } = loanIdParams.parse(request.params);
    const body = z.object({ status: z.enum([LoanStatus.APPROVED, LoanStatus.REJECTED]), reviewerNote: z.string().trim().max(1000).optional() }).parse(request.body);
    const loan = await prisma.loan.findUnique({ where: { id: loanId } });
    if (!loan) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan not found.' });
    }
    if (loan.status !== LoanStatus.PENDING) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'Only pending loans can be reviewed.' });
    }

    const updatedLoan = await prisma.$transaction(async (transaction) => {
      const reviewedLoan = await transaction.loan.update({
        where: { id: loanId },
        data: {
          status: body.status,
          reviewerNote: body.reviewerNote,
          reviewedAt: new Date(),
          disbursedAt: body.status === LoanStatus.APPROVED ? new Date() : null,
        },
      });
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
          body: body.status === LoanStatus.APPROVED ? `Your loan ${loan.loanNumber} has been approved.` : `Your loan ${loan.loanNumber} was not approved.`,
          payload: `/loan/${loan.id}`,
        },
      });
      await transaction.auditLog.create({
        data: { actorId: request.user.sub, action: `LOAN_${body.status}`, entityType: 'Loan', entityId: loan.id, metadata: { reviewerNote: body.reviewerNote } },
      });
      return reviewedLoan;
    });
    return { loan: serializeLoan(updatedLoan) };
  });
}

const DocumentKindSchema = z.nativeEnum(DocumentKind);
