-- =====================================================
-- COMPLETE PAYMENT SETUP & TABLE RENAMING
-- Run this file in your PostgreSQL client
-- =====================================================

-- Set the schema
SET search_path TO sanzenapp;

-- =====================================================
-- STEP 1: Rename existing tables to lowercase
-- =====================================================

-- Rename Property table if it exists with uppercase
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'sanzenapp' AND table_name = 'Property') THEN
        ALTER TABLE "Property" RENAME TO property;
    END IF;
END $$;

-- Rename UserProperty table if it exists with mixed case
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'sanzenapp' AND table_name = 'UserProperty') THEN
        ALTER TABLE "UserProperty" RENAME TO user_property;
    END IF;
END $$;

-- Rename TimelineMilestone table if it exists with mixed case
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'sanzenapp' AND table_name = 'TimelineMilestone') THEN
        ALTER TABLE "TimelineMilestone" RENAME TO timeline_milestone;
    END IF;
END $$;

-- Rename AddonOffer table if it exists with mixed case
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'sanzenapp' AND table_name = 'AddonOffer') THEN
        ALTER TABLE "AddonOffer" RENAME TO addon_offer;
    END IF;
END $$;

-- =====================================================
-- STEP 2: Create Payment Enums
-- =====================================================

-- Create PaymentStatus enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PaymentStatus') THEN
        CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'OVERDUE', 'CANCELLED');
    END IF;
END $$;

-- Create PaymentType enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PaymentType') THEN
        CREATE TYPE "PaymentType" AS ENUM ('INSTALLMENT', 'MAINTENANCE_FEE', 'SERVICE_CHARGE', 'ADDON_PAYMENT', 'OTHER');
    END IF;
END $$;

-- =====================================================
-- STEP 3: Create Payment Table
-- =====================================================

CREATE TABLE IF NOT EXISTS payment (
    id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    "userId" VARCHAR(255) NOT NULL,
    "propertyId" VARCHAR(255),
    amount DOUBLE PRECISION NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'AED',
    "paymentType" "PaymentType" NOT NULL,
    status "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "dueDate" TIMESTAMP,
    "paidDate" TIMESTAMP,
    description TEXT,
    "invoiceNumber" VARCHAR(255),
    "receiptUrl" TEXT,
    "installmentNumber" INTEGER,
    "totalInstallments" INTEGER,
    percentage DOUBLE PRECISION,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT fk_payment_user FOREIGN KEY ("userId") REFERENCES "User"(id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_property FOREIGN KEY ("propertyId") REFERENCES property(id) ON DELETE SET NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_payment_userId ON payment("userId");
CREATE INDEX IF NOT EXISTS idx_payment_propertyId ON payment("propertyId");
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment(status);
CREATE INDEX IF NOT EXISTS idx_payment_dueDate ON payment("dueDate");

-- =====================================================
-- STEP 4: Insert Sample Payment Data
-- =====================================================

-- First, let's get a sample user ID and property ID
-- Replace these with actual IDs from your database
DO $$
DECLARE
    v_user_id VARCHAR(255);
    v_property_id VARCHAR(255);
BEGIN
    -- Get first user ID
    SELECT id INTO v_user_id FROM "User" LIMIT 1;

    -- Get first property ID
    SELECT id INTO v_property_id FROM property LIMIT 1;

    -- Only insert if we have valid user and property
    IF v_user_id IS NOT NULL AND v_property_id IS NOT NULL THEN

        -- Payment 1: First Installment (PAID)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", "paidDate", description, "invoiceNumber",
            "installmentNumber", "totalInstallments", percentage,
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            250000.00,
            'AED',
            'INSTALLMENT',
            'PAID',
            '2024-01-15 00:00:00',
            '2024-01-10 14:30:00',
            'First installment payment for villa purchase',
            'INV-2024-001',
            1,
            10,
            10.0,
            NOW(),
            NOW()
        );

        -- Payment 2: Second Installment (PAID)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", "paidDate", description, "invoiceNumber",
            "installmentNumber", "totalInstallments", percentage,
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            250000.00,
            'AED',
            'INSTALLMENT',
            'PAID',
            '2024-04-15 00:00:00',
            '2024-04-12 10:15:00',
            'Second installment payment for villa purchase',
            'INV-2024-002',
            2,
            10,
            10.0,
            NOW(),
            NOW()
        );

        -- Payment 3: Third Installment (PENDING)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", description, "invoiceNumber",
            "installmentNumber", "totalInstallments", percentage,
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            250000.00,
            'AED',
            'INSTALLMENT',
            'PENDING',
            '2026-04-15 00:00:00',
            'Third installment payment for villa purchase',
            'INV-2026-003',
            3,
            10,
            10.0,
            NOW(),
            NOW()
        );

        -- Payment 4: Fourth Installment (PENDING)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", description, "invoiceNumber",
            "installmentNumber", "totalInstallments", percentage,
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            250000.00,
            'AED',
            'INSTALLMENT',
            'PENDING',
            '2026-07-15 00:00:00',
            'Fourth installment payment for villa purchase',
            'INV-2026-004',
            4,
            10,
            10.0,
            NOW(),
            NOW()
        );

        -- Payment 5: Maintenance Fee (OVERDUE)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", description, "invoiceNumber",
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            5000.00,
            'AED',
            'MAINTENANCE_FEE',
            'OVERDUE',
            '2024-12-31 00:00:00',
            'Annual maintenance fee for 2024',
            'INV-2024-MAINT-001',
            NOW(),
            NOW()
        );

        -- Payment 6: Service Charge (PAID)
        INSERT INTO payment (
            id, "userId", "propertyId", amount, currency, "paymentType", status,
            "dueDate", "paidDate", description, "invoiceNumber",
            "createdAt", "updatedAt"
        ) VALUES (
            gen_random_uuid()::text,
            v_user_id,
            v_property_id,
            3500.00,
            'AED',
            'SERVICE_CHARGE',
            'PAID',
            '2024-06-30 00:00:00',
            '2024-06-28 16:45:00',
            'Community service charge Q2 2024',
            'INV-2024-SVC-001',
            NOW(),
            NOW()
        );

        RAISE NOTICE 'Successfully inserted 6 sample payments for user % and property %', v_user_id, v_property_id;
    ELSE
        RAISE NOTICE 'Could not insert sample data - no user or property found';
    END IF;
END $$;

-- =====================================================
-- STEP 5: Verify Setup
-- =====================================================

-- Show table counts
SELECT
    'payment' as table_name,
    COUNT(*) as record_count
FROM payment
UNION ALL
SELECT
    'property' as table_name,
    COUNT(*) as record_count
FROM property
UNION ALL
SELECT
    'user_property' as table_name,
    COUNT(*) as record_count
FROM user_property;

-- Show sample payment data
SELECT
    id,
    amount,
    currency,
    "paymentType",
    status,
    "installmentNumber",
    "totalInstallments",
    percentage,
    "dueDate"
FROM payment
ORDER BY "dueDate";

-- =====================================================
-- Setup Complete!
-- =====================================================
-- You can now test your payment page in the Flutter app
-- =====================================================
