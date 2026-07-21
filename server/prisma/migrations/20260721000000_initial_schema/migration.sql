CREATE TYPE "UserRole" AS ENUM ('CUSTOMER', 'STAFF', 'ADMIN');
CREATE TYPE "LoanStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
CREATE TYPE "DocumentKind" AS ENUM ('ID_FRONT', 'ID_BACK', 'SELFIE', 'SIGNATURE');
CREATE TYPE "PaymentStatus" AS ENUM ('DUE', 'PAID', 'OVERDUE', 'WAIVED');
CREATE TYPE "TransactionType" AS ENUM ('LOAN_DISBURSEMENT', 'REPAYMENT', 'WITHDRAWAL', 'DEPOSIT', 'FEE');
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED');

CREATE TABLE "User" (
  "id" UUID NOT NULL,
  "email" VARCHAR(254) NOT NULL,
  "passwordHash" TEXT NOT NULL,
  "fullName" TEXT NOT NULL,
  "idNumber" TEXT,
  "role" "UserRole" NOT NULL DEFAULT 'CUSTOMER',
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "RefreshToken" (
  "id" UUID NOT NULL,
  "tokenHash" TEXT NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "revokedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "userId" UUID NOT NULL,
  CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Loan" (
  "id" UUID NOT NULL,
  "loanNumber" TEXT NOT NULL,
  "status" "LoanStatus" NOT NULL DEFAULT 'PENDING',
  "currency" VARCHAR(3) NOT NULL DEFAULT 'PHP',
  "principal" DECIMAL(14, 2) NOT NULL,
  "termMonths" INTEGER NOT NULL,
  "monthlyInterestRate" DECIMAL(7, 6) NOT NULL,
  "interestAmount" DECIMAL(14, 2) NOT NULL,
  "totalRepayment" DECIMAL(14, 2) NOT NULL,
  "monthlyPayment" DECIMAL(14, 2) NOT NULL,
  "acceptedTermsAt" TIMESTAMP(3) NOT NULL,
  "actualName" TEXT NOT NULL,
  "idCardNumber" TEXT NOT NULL,
  "currentJob" TEXT NOT NULL,
  "gender" TEXT NOT NULL,
  "stableIncome" DECIMAL(14, 2) NOT NULL,
  "loanPurpose" TEXT NOT NULL,
  "currentAddress" TEXT NOT NULL,
  "guarantorName" TEXT NOT NULL,
  "guarantorPhone" TEXT NOT NULL,
  "beneficiaryBank" TEXT NOT NULL,
  "accountName" TEXT NOT NULL,
  "accountNumber" TEXT NOT NULL,
  "reviewerNote" TEXT,
  "reviewedAt" TIMESTAMP(3),
  "disbursedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "borrowerId" UUID NOT NULL,
  CONSTRAINT "Loan_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "LoanDocument" (
  "id" UUID NOT NULL,
  "kind" "DocumentKind" NOT NULL,
  "storageKey" TEXT NOT NULL,
  "fileName" TEXT NOT NULL,
  "mimeType" TEXT NOT NULL,
  "sizeBytes" INTEGER NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "loanId" UUID NOT NULL,
  CONSTRAINT "LoanDocument_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Repayment" (
  "id" UUID NOT NULL,
  "installment" INTEGER NOT NULL,
  "dueDate" TIMESTAMP(3) NOT NULL,
  "principal" DECIMAL(14, 2) NOT NULL,
  "interest" DECIMAL(14, 2) NOT NULL,
  "amountDue" DECIMAL(14, 2) NOT NULL,
  "amountPaid" DECIMAL(14, 2) NOT NULL DEFAULT 0,
  "paidAt" TIMESTAMP(3),
  "status" "PaymentStatus" NOT NULL DEFAULT 'DUE',
  "loanId" UUID NOT NULL,
  CONSTRAINT "Repayment_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Transaction" (
  "id" UUID NOT NULL,
  "type" "TransactionType" NOT NULL,
  "status" "TransactionStatus" NOT NULL DEFAULT 'PENDING',
  "amount" DECIMAL(14, 2) NOT NULL,
  "currency" VARCHAR(3) NOT NULL DEFAULT 'PHP',
  "description" TEXT NOT NULL,
  "occurredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "userId" UUID NOT NULL,
  "loanId" UUID,
  CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Notification" (
  "id" UUID NOT NULL,
  "title" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "payload" TEXT,
  "readAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "userId" UUID NOT NULL,
  CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AuditLog" (
  "id" UUID NOT NULL,
  "action" TEXT NOT NULL,
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "actorId" UUID,
  CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_idNumber_key" ON "User"("idNumber");
CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON "RefreshToken"("tokenHash");
CREATE UNIQUE INDEX "Loan_loanNumber_key" ON "Loan"("loanNumber");
CREATE UNIQUE INDEX "LoanDocument_storageKey_key" ON "LoanDocument"("storageKey");
CREATE UNIQUE INDEX "LoanDocument_loanId_kind_key" ON "LoanDocument"("loanId", "kind");
CREATE UNIQUE INDEX "Repayment_loanId_installment_key" ON "Repayment"("loanId", "installment");

CREATE INDEX "RefreshToken_userId_expiresAt_idx" ON "RefreshToken"("userId", "expiresAt");
CREATE INDEX "Loan_borrowerId_createdAt_idx" ON "Loan"("borrowerId", "createdAt");
CREATE INDEX "Loan_status_createdAt_idx" ON "Loan"("status", "createdAt");
CREATE INDEX "Repayment_loanId_dueDate_idx" ON "Repayment"("loanId", "dueDate");
CREATE INDEX "Transaction_userId_occurredAt_idx" ON "Transaction"("userId", "occurredAt");
CREATE INDEX "Transaction_loanId_occurredAt_idx" ON "Transaction"("loanId", "occurredAt");
CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");
CREATE INDEX "AuditLog_entityType_entityId_createdAt_idx" ON "AuditLog"("entityType", "entityId", "createdAt");

ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Loan" ADD CONSTRAINT "Loan_borrowerId_fkey" FOREIGN KEY ("borrowerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "LoanDocument" ADD CONSTRAINT "LoanDocument_loanId_fkey" FOREIGN KEY ("loanId") REFERENCES "Loan"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Repayment" ADD CONSTRAINT "Repayment_loanId_fkey" FOREIGN KEY ("loanId") REFERENCES "Loan"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_loanId_fkey" FOREIGN KEY ("loanId") REFERENCES "Loan"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
