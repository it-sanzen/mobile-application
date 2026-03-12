-- Sample Timeline Milestones for a property
-- First, we need a property ID. Let's get it from an existing property
-- Replace 'YOUR_PROPERTY_ID' with an actual property ID from your database

-- Sample Timeline Milestones
INSERT INTO "sanzenapp"."TimelineMilestone" (
    id, "propertyId", phase, title, description, status, "completedDate",
    "estimatedDate", "orderIndex", "createdAt", "updatedAt"
) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),  -- Gets first property
    'Foundation',
    'Site Preparation',
    'Land clearing, excavation, and foundation work completed',
    'COMPLETED',
    '2024-01-15',
    NULL,
    1,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),
    'Structure',
    'Foundation Completed',
    'Foundation and basement structure completed and inspected',
    'COMPLETED',
    '2024-02-28',
    NULL,
    2,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),
    'Structure',
    'Frame Construction',
    'Building frame and structural elements in progress',
    'IN_PROGRESS',
    NULL,
    'Q2 2024',
    3,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),
    'Interior',
    'MEP Installation',
    'Mechanical, Electrical, and Plumbing systems to be installed',
    'PENDING',
    NULL,
    'Q3 2024',
    4,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),
    'Finishing',
    'Interior Finishing',
    'Drywall, flooring, painting, and fixtures installation',
    'PENDING',
    NULL,
    'Q4 2024',
    5,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM "sanzenapp"."Property" LIMIT 1),
    'Completion',
    'Final Inspection',
    'Final building inspection and certificate of occupancy',
    'PENDING',
    NULL,
    'Q1 2025',
    6,
    NOW(),
    NOW()
);

-- Sample Addon Offers
INSERT INTO "sanzenapp"."AddonOffer" (
    id, title, description, "imageUrl", icon, price, category, "isActive", "createdAt", "updatedAt"
) VALUES
(
    gen_random_uuid(),
    'Premium Kitchen Upgrade',
    'Upgrade to premium kitchen with Italian marble countertops, premium appliances, and custom cabinetry',
    NULL,
    '🍳',
    25000.00,
    'UPGRADE',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Smart Home Package',
    'Complete smart home automation including lighting, climate control, security system, and voice control',
    NULL,
    '🏠',
    15000.00,
    'SMART_HOME',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Private Pool',
    'Infinity edge swimming pool with heating system, LED lighting, and automatic maintenance system',
    NULL,
    '🏊',
    45000.00,
    'OUTDOOR',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Tesla Charging Station',
    'High-power wall connector for electric vehicle charging with smart energy management',
    NULL,
    '⚡',
    3500.00,
    'VEHICLE',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Advanced Security System',
    '24/7 AI-powered surveillance with facial recognition, perimeter sensors, and mobile alerts',
    NULL,
    '🔒',
    8500.00,
    'SECURITY',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Home Cinema',
    'Professional home theater with 4K projector, Dolby Atmos sound system, and acoustic treatment',
    NULL,
    '🎬',
    18000.00,
    'UPGRADE',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Rooftop Garden',
    'Landscaped rooftop garden with irrigation system, outdoor kitchen, and seating area',
    NULL,
    '🌿',
    12000.00,
    'OUTDOOR',
    TRUE,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Wine Cellar',
    'Climate-controlled wine cellar with custom racking for 500+ bottles and tasting area',
    NULL,
    '🍷',
    22000.00,
    'UPGRADE',
    TRUE,
    NOW(),
    NOW()
);
