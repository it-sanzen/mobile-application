-- Drop existing tables if they exist (careful in production!)
-- DROP TABLE IF EXISTS "sanzenapp"."payment" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."addon_offer" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."timeline_milestone" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."user_property" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."property" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."CompanyNews" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."UnitUpdate" CASCADE;
-- DROP TABLE IF EXISTS "sanzenapp"."Document" CASCADE;

-- Drop enums if they exist
DROP TYPE IF EXISTS "sanzenapp"."PaymentStatus" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."PaymentType" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."AddonCategory" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."MilestoneStatus" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."PropertyStatus" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."PropertyType" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."NewsCategory" CASCADE;
DROP TYPE IF EXISTS "sanzenapp"."UpdateType" CASCADE;

-- Create Enums
CREATE TYPE "sanzenapp"."UpdateType" AS ENUM ('ELECTRICAL', 'PLUMBING', 'CONSTRUCTION', 'INSPECTION', 'MILESTONE', 'GENERAL');
CREATE TYPE "sanzenapp"."NewsCategory" AS ENUM ('ANNOUNCEMENT', 'AWARD', 'EVENT', 'SUSTAINABILITY', 'COMMUNITY');
CREATE TYPE "sanzenapp"."PropertyType" AS ENUM ('VILLA', 'APARTMENT', 'TOWNHOUSE', 'PENTHOUSE');
CREATE TYPE "sanzenapp"."PropertyStatus" AS ENUM ('UNDER_CONSTRUCTION', 'READY', 'HANDOVER_COMPLETE');
CREATE TYPE "sanzenapp"."MilestoneStatus" AS ENUM ('COMPLETED', 'IN_PROGRESS', 'PENDING', 'DELAYED');
CREATE TYPE "sanzenapp"."AddonCategory" AS ENUM ('UPGRADE', 'SMART_HOME', 'OUTDOOR', 'VEHICLE', 'SECURITY', 'OTHER');
CREATE TYPE "sanzenapp"."PaymentStatus" AS ENUM ('PENDING', 'PAID', 'OVERDUE', 'CANCELLED');
CREATE TYPE "sanzenapp"."PaymentType" AS ENUM ('INSTALLMENT', 'MAINTENANCE_FEE', 'SERVICE_CHARGE', 'ADDON_PAYMENT', 'OTHER');

-- Document Table
CREATE TABLE "sanzenapp"."Document" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Document_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "Document_userId_fkey" FOREIGN KEY ("userId") REFERENCES "sanzenapp"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- UnitUpdate Table
CREATE TABLE "sanzenapp"."UnitUpdate" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "updateType" "sanzenapp"."UpdateType" NOT NULL DEFAULT 'GENERAL',
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "time" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isPublished" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "UnitUpdate_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "UnitUpdate_userId_fkey" FOREIGN KEY ("userId") REFERENCES "sanzenapp"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "UnitUpdate_userId_idx" ON "sanzenapp"."UnitUpdate"("userId");
CREATE INDEX "UnitUpdate_publishedAt_idx" ON "sanzenapp"."UnitUpdate"("publishedAt" DESC);
CREATE INDEX "UnitUpdate_isPublished_idx" ON "sanzenapp"."UnitUpdate"("isPublished");
CREATE INDEX "UnitUpdate_updateType_idx" ON "sanzenapp"."UnitUpdate"("updateType");

-- CompanyNews Table
CREATE TABLE "sanzenapp"."CompanyNews" (
    "id" TEXT NOT NULL,
    "category" "sanzenapp"."NewsCategory" NOT NULL DEFAULT 'ANNOUNCEMENT',
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "time" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isPublished" BOOLEAN NOT NULL DEFAULT true,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "CompanyNews_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "CompanyNews_publishedAt_idx" ON "sanzenapp"."CompanyNews"("publishedAt" DESC);
CREATE INDEX "CompanyNews_isPublished_idx" ON "sanzenapp"."CompanyNews"("isPublished");
CREATE INDEX "CompanyNews_category_idx" ON "sanzenapp"."CompanyNews"("category");
CREATE INDEX "CompanyNews_isFeatured_idx" ON "sanzenapp"."CompanyNews"("isFeatured");

-- Property Table
CREATE TABLE "sanzenapp"."property" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "propertyType" "sanzenapp"."PropertyType" NOT NULL,
    "imageUrl" TEXT,
    "bedrooms" INTEGER NOT NULL,
    "area" DOUBLE PRECISION NOT NULL,
    "status" "sanzenapp"."PropertyStatus" NOT NULL DEFAULT 'UNDER_CONSTRUCTION',
    "completionPercentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "currentPhase" TEXT,
    "estimatedCompletion" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "property_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "property_status_idx" ON "sanzenapp"."property"("status");
CREATE INDEX "property_propertyType_idx" ON "sanzenapp"."property"("propertyType");

-- UserProperty Table
CREATE TABLE "sanzenapp"."user_property" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "unitCode" TEXT NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_property_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "user_property_userId_propertyId_key" UNIQUE ("userId", "propertyId"),
    CONSTRAINT "user_property_userId_fkey" FOREIGN KEY ("userId") REFERENCES "sanzenapp"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "user_property_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "sanzenapp"."property"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "user_property_userId_idx" ON "sanzenapp"."user_property"("userId");
CREATE INDEX "user_property_propertyId_idx" ON "sanzenapp"."user_property"("propertyId");

-- TimelineMilestone Table
CREATE TABLE "sanzenapp"."timeline_milestone" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "phase" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "status" "sanzenapp"."MilestoneStatus" NOT NULL DEFAULT 'PENDING',
    "completedDate" TIMESTAMP(3),
    "estimatedDate" TEXT,
    "orderIndex" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "timeline_milestone_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "timeline_milestone_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "sanzenapp"."property"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "timeline_milestone_propertyId_idx" ON "sanzenapp"."timeline_milestone"("propertyId");
CREATE INDEX "timeline_milestone_status_idx" ON "sanzenapp"."timeline_milestone"("status");
CREATE INDEX "timeline_milestone_orderIndex_idx" ON "sanzenapp"."timeline_milestone"("orderIndex");

-- AddonOffer Table
CREATE TABLE "sanzenapp"."addon_offer" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "imageUrl" TEXT,
    "icon" TEXT,
    "price" DOUBLE PRECISION,
    "category" "sanzenapp"."AddonCategory" NOT NULL DEFAULT 'OTHER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "addon_offer_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "addon_offer_isActive_idx" ON "sanzenapp"."addon_offer"("isActive");
CREATE INDEX "addon_offer_category_idx" ON "sanzenapp"."addon_offer"("category");

-- Payment Table
CREATE TABLE "sanzenapp"."payment" (
    "id" TEXT NOT NULL,
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
    "installmentNumber" INTEGER,
    "totalInstallments" INTEGER,
    "percentage" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "payment_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "sanzenapp"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "payment_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "sanzenapp"."property"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX "payment_userId_idx" ON "sanzenapp"."payment"("userId");
CREATE INDEX "payment_propertyId_idx" ON "sanzenapp"."payment"("propertyId");
CREATE INDEX "payment_status_idx" ON "sanzenapp"."payment"("status");
CREATE INDEX "payment_dueDate_idx" ON "sanzenapp"."payment"("dueDate");

-- Insert Sample Data
-- Sample Properties
INSERT INTO "sanzenapp"."property" ("id", "name", "location", "propertyType", "imageUrl", "bedrooms", "area", "status", "completionPercentage", "currentPhase", "estimatedCompletion") VALUES
('prop-1', 'Marina Heights Villa', 'Dubai Marina', 'VILLA', NULL, 4, 3500.0, 'UNDER_CONSTRUCTION', 65.0, 'Interior Finishing', 'Q2 2026'),
('prop-2', 'Palm Jumeirah Apartment', 'Palm Jumeirah', 'APARTMENT', NULL, 2, 1200.0, 'UNDER_CONSTRUCTION', 45.0, 'MEP Installation', 'Q3 2026'),
('prop-3', 'Downtown Penthouse', 'Downtown Dubai', 'PENTHOUSE', NULL, 3, 2500.0, 'READY', 100.0, 'Handover Ready', 'Completed');

-- Sample UserProperties (linking seconduser to properties)
INSERT INTO "sanzenapp"."user_property" ("id", "userId", "propertyId", "unitCode", "isPrimary") VALUES
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 'MH-401', true),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-2', 'PJ-205', false);

-- Sample CompanyNews
INSERT INTO "sanzenapp"."CompanyNews" ("id", "category", "title", "description", "time", "publishedAt", "isPublished", "isFeatured") VALUES
(gen_random_uuid(), 'ANNOUNCEMENT', 'Q1 2026 Construction Update', 'We are pleased to announce significant progress across all our projects this quarter. Marina Heights has reached 65% completion with interior finishing well underway.', '2 days ago', CURRENT_TIMESTAMP - INTERVAL '2 days', true, true),
(gen_random_uuid(), 'AWARD', 'Best Real Estate Developer 2025', 'Sanzen Real Estate has been awarded Best Developer of the Year 2025 by Dubai Property Awards for excellence in sustainable construction.', '1 week ago', CURRENT_TIMESTAMP - INTERVAL '7 days', true, true),
(gen_random_uuid(), 'EVENT', 'Customer Appreciation Event', 'Join us for an exclusive tour of our completed projects and meet the team behind your dream home. March 15, 2026 at Dubai Marina.', '3 days ago', CURRENT_TIMESTAMP - INTERVAL '3 days', true, false),
(gen_random_uuid(), 'SUSTAINABILITY', 'Solar Panel Installation', 'All new properties will feature premium solar panel systems, reducing energy costs by up to 40% and supporting UAE green initiatives.', '5 days ago', CURRENT_TIMESTAMP - INTERVAL '5 days', true, false);

-- Sample UnitUpdates
INSERT INTO "sanzenapp"."UnitUpdate" ("id", "userId", "updateType", "title", "description", "time", "publishedAt", "isPublished") VALUES
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'CONSTRUCTION', 'Kitchen Installation Complete', 'Your premium Italian kitchen has been installed. Marble countertops and all appliances are now in place.', '1 day ago', CURRENT_TIMESTAMP - INTERVAL '1 day', true),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'ELECTRICAL', 'Smart Home System Testing', 'All smart home systems including lighting, climate control, and security have been tested and are operational.', '3 days ago', CURRENT_TIMESTAMP - INTERVAL '3 days', true),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'INSPECTION', 'Final Quality Inspection Scheduled', 'Final quality inspection by Dubai Municipality is scheduled for next week. All systems are ready for inspection.', '5 days ago', CURRENT_TIMESTAMP - INTERVAL '5 days', true);

-- Sample Addon Offers
INSERT INTO "sanzenapp"."addon_offer" ("id", "title", "description", "imageUrl", "icon", "price", "category", "isActive") VALUES
(gen_random_uuid(), 'Premium Kitchen Upgrade', 'Upgrade to premium kitchen with Italian marble countertops, premium appliances, and custom cabinetry', NULL, '🍳', 25000.00, 'UPGRADE', true),
(gen_random_uuid(), 'Smart Home Package', 'Complete smart home automation including lighting, climate control, security system, and voice control', NULL, '🏠', 15000.00, 'SMART_HOME', true),
(gen_random_uuid(), 'Private Pool', 'Infinity edge swimming pool with heating system, LED lighting, and automatic maintenance system', NULL, '🏊', 45000.00, 'OUTDOOR', true),
(gen_random_uuid(), 'Tesla Charging Station', 'High-power wall connector for electric vehicle charging with smart energy management', NULL, '⚡', 3500.00, 'VEHICLE', true),
(gen_random_uuid(), 'Advanced Security System', '24/7 AI-powered surveillance with facial recognition, perimeter sensors, and mobile alerts', NULL, '🔒', 8500.00, 'SECURITY', true);

-- Sample Timeline Milestones for prop-1
INSERT INTO "sanzenapp"."timeline_milestone" ("id", "propertyId", "phase", "title", "description", "status", "completedDate", "estimatedDate", "orderIndex") VALUES
(gen_random_uuid(), 'prop-1', 'Foundation', 'Site Preparation', 'Land clearing, excavation, and foundation work completed', 'COMPLETED', '2025-01-15', NULL, 1),
(gen_random_uuid(), 'prop-1', 'Structure', 'Foundation Completed', 'Foundation and basement structure completed and inspected', 'COMPLETED', '2025-02-28', NULL, 2),
(gen_random_uuid(), 'prop-1', 'Structure', 'Frame Construction', 'Building frame and structural elements completed', 'COMPLETED', '2025-06-15', NULL, 3),
(gen_random_uuid(), 'prop-1', 'Interior', 'MEP Installation', 'Mechanical, Electrical, and Plumbing systems installed', 'COMPLETED', '2025-09-30', NULL, 4),
(gen_random_uuid(), 'prop-1', 'Finishing', 'Interior Finishing', 'Drywall, flooring, painting, and fixtures installation in progress', 'IN_PROGRESS', NULL, 'March 2026', 5),
(gen_random_uuid(), 'prop-1', 'Completion', 'Final Inspection', 'Final building inspection and certificate of occupancy', 'PENDING', NULL, 'May 2026', 6);

-- Sample Payments for seconduser
INSERT INTO "sanzenapp"."payment" ("id", "userId", "propertyId", "amount", "currency", "paymentType", "status", "dueDate", "paidDate", "description", "invoiceNumber", "installmentNumber", "totalInstallments", "percentage") VALUES
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PAID', '2025-01-01', '2024-12-28', 'Initial Down Payment - 10%', 'INV-2025-001', 1, 10, 10.0),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PAID', '2025-04-01', '2025-03-28', 'Second Installment - 10%', 'INV-2025-002', 2, 10, 10.0),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PAID', '2025-07-01', '2025-06-30', 'Third Installment - 10%', 'INV-2025-003', 3, 10, 10.0),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PENDING', '2026-01-01', NULL, 'Fourth Installment - 10%', 'INV-2026-001', 4, 10, 10.0),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PENDING', '2026-04-01', NULL, 'Fifth Installment - 10%', 'INV-2026-002', 5, 10, 10.0),
(gen_random_uuid(), '54f3b7d7-f145-43c0-aa1e-c295025642ee', 'prop-1', 150000.00, 'AED', 'INSTALLMENT', 'PENDING', '2026-07-01', NULL, 'Sixth Installment - 10%', 'INV-2026-003', 6, 10, 10.0);

-- Sample Documents
INSERT INTO "sanzenapp"."Document" ("id", "title", "type", "fileUrl", "userId") VALUES
(gen_random_uuid(), 'Sale Agreement', 'Contract', '/documents/sale-agreement-mh401.pdf', '54f3b7d7-f145-43c0-aa1e-c295025642ee'),
(gen_random_uuid(), 'Payment Receipt - Jan 2025', 'Receipt', '/documents/receipt-jan2025.pdf', '54f3b7d7-f145-43c0-aa1e-c295025642ee'),
(gen_random_uuid(), 'NOC Certificate', 'NOC', '/documents/noc-certificate.pdf', '54f3b7d7-f145-43c0-aa1e-c295025642ee');
