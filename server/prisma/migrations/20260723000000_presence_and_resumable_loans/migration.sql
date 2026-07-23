ALTER TABLE "User"
ADD COLUMN "lastLoginAt" TIMESTAMP(3),
ADD COLUMN "lastSeenAt" TIMESTAMP(3),
ADD COLUMN "lastLogoutAt" TIMESTAMP(3);

ALTER TABLE "Loan"
ADD COLUMN "submittedAt" TIMESTAMP(3);

UPDATE "Loan"
SET "submittedAt" = "createdAt"
WHERE "submittedAt" IS NULL;

DROP INDEX IF EXISTS "Loan_one_pending_per_borrower";

CREATE UNIQUE INDEX "Loan_one_submitted_pending_per_borrower"
ON "Loan"("borrowerId")
WHERE "status" = 'PENDING' AND "submittedAt" IS NOT NULL;

CREATE INDEX "Loan_submittedAt_status_createdAt_idx"
ON "Loan"("submittedAt", "status", "createdAt");

INSERT INTO "Permission" ("key", "name", "description", "category", "sortOrder")
VALUES (
  'customers.manage',
  'Manage customers',
  'Create and update registered customer accounts.',
  'Customers',
  45
)
ON CONFLICT ("key") DO NOTHING;

INSERT INTO "RolePermission" ("role", "permissionId")
SELECT 'ADMIN'::"UserRole", "id"
FROM "Permission"
WHERE "key" = 'customers.manage'
ON CONFLICT DO NOTHING;
