-- =====================================================
-- Add Installment Fields to Payment Table
-- =====================================================

-- Add new columns to payment table
ALTER TABLE "sanzenapp"."payment"
ADD COLUMN "installmentNumber" INTEGER,
ADD COLUMN "totalInstallments" INTEGER,
ADD COLUMN "percentage" DOUBLE PRECISION;

-- Update existing installment payments with installment details
UPDATE "sanzenapp"."payment"
SET
  "installmentNumber" = 1,
  "totalInstallments" = 10,
  "percentage" = 10.0
WHERE "description" LIKE '%Q1 2024%' AND "paymentType" = 'INSTALLMENT';

UPDATE "sanzenapp"."payment"
SET
  "installmentNumber" = 2,
  "totalInstallments" = 10,
  "percentage" = 10.0
WHERE "description" LIKE '%Q2 2024%' AND "paymentType" = 'INSTALLMENT';

UPDATE "sanzenapp"."payment"
SET
  "installmentNumber" = 3,
  "totalInstallments" = 10,
  "percentage" = 10.0
WHERE "description" LIKE '%Q3 2024%' AND "paymentType" = 'INSTALLMENT';

UPDATE "sanzenapp"."payment"
SET
  "installmentNumber" = 4,
  "totalInstallments" = 10,
  "percentage" = 10.0
WHERE "description" LIKE '%Q4 2024%' AND "paymentType" = 'INSTALLMENT';

-- Verify the updates
SELECT
    "installmentNumber",
    "totalInstallments",
    "percentage",
    "amount",
    "status",
    "description"
FROM "sanzenapp"."payment"
WHERE "paymentType" = 'INSTALLMENT'
ORDER BY "installmentNumber" ASC;
