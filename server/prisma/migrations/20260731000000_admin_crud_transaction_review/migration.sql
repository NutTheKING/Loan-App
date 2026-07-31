ALTER TYPE "TransactionStatus" ADD VALUE IF NOT EXISTS 'REJECTED';

ALTER TABLE "User"
ADD COLUMN "phone" VARCHAR(30),
ADD COLUMN "dateOfBirth" DATE,
ADD COLUMN "gender" VARCHAR(40),
ADD COLUMN "address" TEXT,
ADD COLUMN "profilePhotoUrl" TEXT;

ALTER TABLE "Loan"
ADD COLUMN "informationRequestedAt" TIMESTAMP(3);

ALTER TABLE "Transaction"
ADD COLUMN "reviewReason" TEXT,
ADD COLUMN "reviewedAt" TIMESTAMP(3),
ADD COLUMN "reviewedById" UUID;

ALTER TABLE "Transaction"
ADD CONSTRAINT "Transaction_reviewedById_fkey"
FOREIGN KEY ("reviewedById") REFERENCES "User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX "Transaction_status_type_occurredAt_idx"
ON "Transaction"("status", "type", "occurredAt");

CREATE INDEX "Transaction_reviewedById_reviewedAt_idx"
ON "Transaction"("reviewedById", "reviewedAt");

INSERT INTO "Permission" ("key", "name", "description", "category", "sortOrder")
VALUES (
  'transactions.manage',
  'Manage transactions',
  'Create deposits and approve, reject, or remove reviewable transactions.',
  'Finance',
  105
)
ON CONFLICT ("key") DO UPDATE
SET
  "name" = EXCLUDED."name",
  "description" = EXCLUDED."description",
  "category" = EXCLUDED."category",
  "sortOrder" = EXCLUDED."sortOrder";

INSERT INTO "RolePermission" ("role", "permissionId")
SELECT 'ADMIN'::"UserRole", "id"
FROM "Permission"
WHERE "key" = 'transactions.manage'
ON CONFLICT DO NOTHING;

UPDATE "Permission"
SET "description" = 'Create, update, disable, and safely delete registered customer accounts.'
WHERE "key" = 'customers.manage';

UPDATE "Permission"
SET "description" = 'Create, update, disable, and safely delete staff and administrator accounts.'
WHERE "key" = 'users.manage';

UPDATE "Permission"
SET "description" = 'Create, update, and safely delete loan package rules.'
WHERE "key" = 'products.manage';

UPDATE "Permission"
SET "description" = 'Create, update, and delete operating branches.'
WHERE "key" = 'branches.manage';
