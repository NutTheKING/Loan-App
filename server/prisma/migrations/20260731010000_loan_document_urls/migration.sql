ALTER TABLE "LoanDocument"
ADD COLUMN "url" TEXT;

UPDATE "LoanDocument"
SET "url" = '/api/v1/loans/' || "loanId" || '/documents/' || "id";

ALTER TABLE "LoanDocument"
ALTER COLUMN "url" SET NOT NULL;

CREATE UNIQUE INDEX "LoanDocument_url_key" ON "LoanDocument"("url");
