ALTER TABLE "Loan" ADD COLUMN "productId" UUID;

UPDATE "Loan"
SET "productId" = (
  SELECT "id"
  FROM "LoanProduct"
  WHERE "isDefault" = true
  ORDER BY "createdAt" ASC
  LIMIT 1
)
WHERE "productId" IS NULL;

ALTER TABLE "Loan"
ADD CONSTRAINT "Loan_productId_fkey"
FOREIGN KEY ("productId") REFERENCES "LoanProduct"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX "Loan_productId_idx" ON "Loan"("productId");
CREATE UNIQUE INDEX "Loan_one_pending_per_borrower"
ON "Loan"("borrowerId") WHERE "status" = 'PENDING';

CREATE TABLE "Permission" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "key" VARCHAR(80) NOT NULL,
  "name" VARCHAR(120) NOT NULL,
  "description" TEXT,
  "category" VARCHAR(80) NOT NULL,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Permission_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Permission_key_key" ON "Permission"("key");
CREATE INDEX "Permission_category_sortOrder_idx" ON "Permission"("category", "sortOrder");

CREATE TABLE "RolePermission" (
  "role" "UserRole" NOT NULL,
  "permissionId" UUID NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "RolePermission_pkey" PRIMARY KEY ("role", "permissionId"),
  CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId")
    REFERENCES "Permission"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "RolePermission_permissionId_idx" ON "RolePermission"("permissionId");

CREATE TABLE "UserPermission" (
  "userId" UUID NOT NULL,
  "permissionId" UUID NOT NULL,
  "granted" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "UserPermission_pkey" PRIMARY KEY ("userId", "permissionId"),
  CONSTRAINT "UserPermission_userId_fkey" FOREIGN KEY ("userId")
    REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "UserPermission_permissionId_fkey" FOREIGN KEY ("permissionId")
    REFERENCES "Permission"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "UserPermission_permissionId_idx" ON "UserPermission"("permissionId");

CREATE TABLE "DeviceToken" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "token" TEXT NOT NULL,
  "platform" VARCHAR(24) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "userId" UUID NOT NULL,
  CONSTRAINT "DeviceToken_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "DeviceToken_userId_fkey" FOREIGN KEY ("userId")
    REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "DeviceToken_token_key" ON "DeviceToken"("token");
CREATE INDEX "DeviceToken_userId_lastSeenAt_idx" ON "DeviceToken"("userId", "lastSeenAt");

INSERT INTO "Permission" ("key", "name", "description", "category", "sortOrder") VALUES
  ('dashboard.view', 'View dashboard', 'View management overview and activity.', 'Overview', 10),
  ('loans.read', 'View loan applications', 'View customer loan applications and documents.', 'Loans', 20),
  ('loans.review', 'Review loan applications', 'Approve or reject pending loan applications.', 'Loans', 30),
  ('customers.read', 'View customers', 'View registered customer accounts.', 'Customers', 40),
  ('users.manage', 'Manage users', 'Create and update customer, staff, and admin accounts.', 'Administration', 50),
  ('permissions.manage', 'Assign permissions', 'Assign database permissions to back-office users.', 'Administration', 60),
  ('products.read', 'View loan packages', 'View all configured loan packages.', 'Configuration', 70),
  ('products.manage', 'Manage loan packages', 'Create and update loan package rules.', 'Configuration', 80),
  ('repayments.read', 'View repayments', 'View EMI schedules and repayment status.', 'Finance', 90),
  ('transactions.read', 'View transactions', 'View account and loan transactions.', 'Finance', 100),
  ('reports.read', 'View reports', 'View portfolio and collection reports.', 'Reports', 110),
  ('branches.read', 'View branches', 'View operating branches.', 'Configuration', 120),
  ('branches.manage', 'Manage branches', 'Create and update operating branches.', 'Configuration', 130)
ON CONFLICT ("key") DO NOTHING;

INSERT INTO "RolePermission" ("role", "permissionId")
SELECT 'ADMIN'::"UserRole", "id" FROM "Permission"
ON CONFLICT DO NOTHING;

INSERT INTO "RolePermission" ("role", "permissionId")
SELECT 'STAFF'::"UserRole", "id" FROM "Permission"
WHERE "key" IN (
  'dashboard.view', 'loans.read', 'loans.review', 'customers.read',
  'products.read', 'repayments.read', 'transactions.read',
  'reports.read', 'branches.read'
)
ON CONFLICT DO NOTHING;
