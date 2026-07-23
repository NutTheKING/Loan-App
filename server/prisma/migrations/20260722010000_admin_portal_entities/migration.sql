CREATE TABLE "LoanProduct" (
  "id" UUID NOT NULL,
  "code" VARCHAR(32) NOT NULL,
  "name" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "currency" VARCHAR(3) NOT NULL DEFAULT 'PHP',
  "minimumAmount" DECIMAL(14, 2) NOT NULL,
  "maximumAmount" DECIMAL(14, 2) NOT NULL,
  "monthlyInterestRate" DECIMAL(7, 6) NOT NULL,
  "allowedTerms" INTEGER[] NOT NULL,
  "repaymentFrequency" VARCHAR(20) NOT NULL DEFAULT 'MONTHLY',
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "isDefault" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "LoanProduct_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Branch" (
  "id" UUID NOT NULL,
  "code" VARCHAR(32) NOT NULL,
  "name" TEXT NOT NULL,
  "address" TEXT NOT NULL,
  "phone" TEXT NOT NULL,
  "email" VARCHAR(254),
  "managerName" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Branch_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "LoanProduct_code_key" ON "LoanProduct"("code");
CREATE INDEX "LoanProduct_isActive_isDefault_idx" ON "LoanProduct"("isActive", "isDefault");
CREATE UNIQUE INDEX "LoanProduct_single_default_key" ON "LoanProduct"("isDefault") WHERE "isDefault" = true;
CREATE UNIQUE INDEX "Branch_code_key" ON "Branch"("code");

INSERT INTO "LoanProduct" (
  "id", "code", "name", "description", "currency", "minimumAmount",
  "maximumAmount", "monthlyInterestRate", "allowedTerms",
  "repaymentFrequency", "isActive", "isDefault", "updatedAt"
) VALUES (
  '00000000-0000-4000-8000-000000000001',
  'STANDARD',
  'Standard Loan',
  'Flexible personal loan package for verified customers.',
  'PHP',
  70000,
  1500000,
  0.005,
  ARRAY[4, 12, 24, 36],
  'MONTHLY',
  true,
  true,
  CURRENT_TIMESTAMP
);

INSERT INTO "Branch" (
  "id", "code", "name", "address", "phone", "email", "managerName", "updatedAt"
) VALUES (
  '00000000-0000-4000-8000-000000000002',
  'HQ-PNH',
  'Phnom Penh Head Office',
  'Phnom Penh, Cambodia',
  '+855 23 000 000',
  'support@loanapp.test',
  'Loan administrator',
  CURRENT_TIMESTAMP
);
