-- =====================================================
-- CREATE PAYMENT TABLE ONLY (Simplified)
-- Copy and paste this into your PostgreSQL client
-- =====================================================

-- Set schema to sanzenapp
SET search_path TO sanzenapp;

-- Create PaymentStatus enum if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PaymentStatus') THEN
        CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'OVERDUE', 'CANCELLED');
    END IF;
END $$;

-- Create PaymentType enum if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PaymentType') THEN
        CREATE TYPE "PaymentType" AS ENUM ('INSTALLMENT', 'MAINTENANCE_FEE', 'SERVICE_CHARGE', 'ADDON_PAYMENT', 'OTHER');
    END IF;
END $$;

-- Create payment table
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

    CONSTRAINT fk_payment_user FOREIGN KEY ("userId") REFERENCES "User"(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_payment_userId ON payment("userId");
CREATE INDEX IF NOT EXISTS idx_payment_propertyId ON payment("propertyId");
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment(status);
CREATE INDEX IF NOT EXISTS idx_payment_dueDate ON payment("dueDate");

-- Insert sample data
DO $$
DECLARE
    v_user_id VARCHAR(255);
    v_property_id VARCHAR(255);
BEGIN
    -- Get first user ID
    SELECT id INTO v_user_id FROM "User" LIMIT 1;

    -- Get first property ID (try both uppercase and lowercase table names)
    BEGIN
        SELECT id INTO v_property_id FROM property LIMIT 1;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            SELECT id INTO v_property_id FROM "Property" LIMIT 1;
        EXCEPTION WHEN OTHERS THEN
            v_property_id := NULL;
        END;
    END;

    -- Only insert if we have a valid user
    IF v_user_id IS NOT NULL THEN

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
            'First installment payment for property purchase',
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
            'Second installment payment for property purchase',
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
            'Third installment payment for property purchase',
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
            'Fourth installment payment for property purchase',
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

        RAISE NOTICE 'Successfully created payment table and inserted 6 sample payments';
    ELSE
        RAISE NOTICE 'Payment table created but no sample data inserted (no user found)';
    END IF;
END $$;

-- Verify
SELECT COUNT(*) as total_payments FROM payment;
