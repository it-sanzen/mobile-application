-- =====================================================
-- Sanzen Payment Module & Table Rename Migration
-- =====================================================

-- First, rename existing tables to lowercase
-- Note: We need to rename in the correct order to avoid FK constraint issues

ALTER TABLE "sanzenapp"."TimelineMilestone" RENAME TO "timeline_milestone";
ALTER TABLE "sanzenapp"."AddonOffer" RENAME TO "addon_offer";
ALTER TABLE "sanzenapp"."UserProperty" RENAME TO "user_property";
ALTER TABLE "sanzenapp"."Property" RENAME TO "property";

-- Create Payment Status Enum
CREATE TYPE "sanzenapp"."PaymentStatus" AS ENUM ('PENDING', 'PAID', 'OVERDUE', 'CANCELLED');

-- Create Payment Type Enum
CREATE TYPE "sanzenapp"."PaymentType" AS ENUM ('INSTALLMENT', 'MAINTENANCE_FEE', 'SERVICE_CHARGE', 'ADDON_PAYMENT', 'OTHER');

-- Create Payment Table
CREATE TABLE "sanzenapp"."payment" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "propertyId" TEXT,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'AED',
    "paymentType" "sanzenapp"."PaymentType" NOT NULL,
    "status" "sanzenapp"."PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "dueDate" TIMESTAMP(3),
    "paidDate" TIMESTAMP(3),
    "description" TEXT,
    "invoiceNumber" TEXT,
    "receiptUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "sanzenapp"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "payment_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "sanzenapp"."property"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- Create indexes for Payment table
CREATE INDEX "payment_userId_idx" ON "sanzenapp"."payment"("userId");
CREATE INDEX "payment_propertyId_idx" ON "sanzenapp"."payment"("propertyId");
CREATE INDEX "payment_status_idx" ON "sanzenapp"."payment"("status");
CREATE INDEX "payment_dueDate_idx" ON "sanzenapp"."payment"("dueDate");

-- Insert sample payment data
INSERT INTO "sanzenapp"."payment" (
    "id", "userId", "propertyId", "amount", "currency", "paymentType",
    "status", "dueDate", "paidDate", "description", "invoiceNumber",
    "createdAt", "updatedAt"
) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    45000.00,
    'AED',
    'INSTALLMENT',
    'PAID',
    '2024-01-15',
    '2024-01-10',
    'Q1 2024 Installment Payment',
    'INV-2024-001',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    45000.00,
    'AED',
    'INSTALLMENT',
    'PAID',
    '2024-04-15',
    '2024-04-12',
    'Q2 2024 Installment Payment',
    'INV-2024-002',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    45000.00,
    'AED',
    'INSTALLMENT',
    'PENDING',
    '2024-07-15',
    NULL,
    'Q3 2024 Installment Payment',
    'INV-2024-003',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    45000.00,
    'AED',
    'INSTALLMENT',
    'OVERDUE',
    '2024-10-15',
    NULL,
    'Q4 2024 Installment Payment',
    'INV-2024-004',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    2500.00,
    'AED',
    'MAINTENANCE_FEE',
    'PAID',
    '2024-06-01',
    '2024-05-28',
    'Annual Maintenance Fee 2024',
    'INV-2024-M001',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."User" LIMIT 1),
    (SELECT id FROM "sanzenapp"."property" LIMIT 1),
    1200.00,
    'AED',
    'SERVICE_CHARGE',
    'PENDING',
    '2024-12-01',
    NULL,
    'Property Management Fee - Q4 2024',
    'INV-2024-S001',
    NOW(),
    NOW()
);

-- Query to verify the data
SELECT
    p."id",
    p."paymentType",
    p."status",
    p."amount",
    p."dueDate",
    p."description"
FROM "sanzenapp"."payment" p
ORDER BY p."dueDate" ASC;
