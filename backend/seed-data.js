const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seed() {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Properties already exist, so we skip creating them
    console.log('⏭️  Skipping property creation (already exists)\n');

    // Link properties to seconduser
    console.log('Linking properties to user...');
    await prisma.userProperty.create({
      data: {
        userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        propertyId: 'prop-1',
        unitCode: 'MH-401',
        isPrimary: true,
      },
    });

    await prisma.userProperty.create({
      data: {
        userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        propertyId: 'prop-2',
        unitCode: 'PJ-205',
        isPrimary: false,
      },
    });
    console.log('✅ Linked 2 properties to user\n');

    // Create Company News
    console.log('Creating company news...');
    await prisma.companyNews.createMany({
      data: [
        {
          category: 'ANNOUNCEMENT',
          title: 'Q1 2026 Construction Update',
          description: 'We are pleased to announce significant progress across all our projects this quarter. Marina Heights has reached 65% completion with interior finishing well underway.',
          time: '2 days ago',
          isPublished: true,
          isFeatured: true,
        },
        {
          category: 'AWARD',
          title: 'Best Real Estate Developer 2025',
          description: 'Sanzen Real Estate has been awarded Best Developer of the Year 2025 by Dubai Property Awards for excellence in sustainable construction.',
          time: '1 week ago',
          isPublished: true,
          isFeatured: true,
        },
        {
          category: 'EVENT',
          title: 'Customer Appreciation Event',
          description: 'Join us for an exclusive tour of our completed projects and meet the team behind your dream home. March 15, 2026 at Dubai Marina.',
          time: '3 days ago',
          isPublished: true,
          isFeatured: false,
        },
        {
          category: 'SUSTAINABILITY',
          title: 'Solar Panel Installation',
          description: 'All new properties will feature premium solar panel systems, reducing energy costs by up to 40% and supporting UAE green initiatives.',
          time: '5 days ago',
          isPublished: true,
          isFeatured: false,
        },
      ],
    });
    console.log('✅ Created 4 company news items\n');

    // Create Unit Updates
    console.log('Creating unit updates...');
    await prisma.unitUpdate.createMany({
      data: [
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          updateType: 'CONSTRUCTION',
          title: 'Kitchen Installation Complete',
          description: 'Your premium Italian kitchen has been installed. Marble countertops and all appliances are now in place.',
          time: '1 day ago',
          isPublished: true,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          updateType: 'ELECTRICAL',
          title: 'Smart Home System Testing',
          description: 'All smart home systems including lighting, climate control, and security have been tested and are operational.',
          time: '3 days ago',
          isPublished: true,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          updateType: 'INSPECTION',
          title: 'Final Quality Inspection Scheduled',
          description: 'Final quality inspection by Dubai Municipality is scheduled for next week. All systems are ready for inspection.',
          time: '5 days ago',
          isPublished: true,
        },
      ],
    });
    console.log('✅ Created 3 unit updates\n');

    // Create Addon Offers
    console.log('Creating addon offers...');
    await prisma.addonOffer.createMany({
      data: [
        {
          title: 'Premium Kitchen Upgrade',
          description: 'Upgrade to premium kitchen with Italian marble countertops, premium appliances, and custom cabinetry',
          icon: '🍳',
          price: 25000.00,
          category: 'UPGRADE',
          isActive: true,
        },
        {
          title: 'Smart Home Package',
          description: 'Complete smart home automation including lighting, climate control, security system, and voice control',
          icon: '🏠',
          price: 15000.00,
          category: 'SMART_HOME',
          isActive: true,
        },
        {
          title: 'Private Pool',
          description: 'Infinity edge swimming pool with heating system, LED lighting, and automatic maintenance system',
          icon: '🏊',
          price: 45000.00,
          category: 'OUTDOOR',
          isActive: true,
        },
        {
          title: 'Tesla Charging Station',
          description: 'High-power wall connector for electric vehicle charging with smart energy management',
          icon: '⚡',
          price: 3500.00,
          category: 'VEHICLE',
          isActive: true,
        },
        {
          title: 'Advanced Security System',
          description: '24/7 AI-powered surveillance with facial recognition, perimeter sensors, and mobile alerts',
          icon: '🔒',
          price: 8500.00,
          category: 'SECURITY',
          isActive: true,
        },
      ],
    });
    console.log('✅ Created 5 addon offers\n');

    // Create Timeline Milestones
    console.log('Creating timeline milestones...');
    await prisma.timelineMilestone.createMany({
      data: [
        {
          propertyId: 'prop-1',
          phase: 'Foundation',
          title: 'Site Preparation',
          description: 'Land clearing, excavation, and foundation work completed',
          status: 'COMPLETED',
          completedDate: new Date('2025-01-15'),
          orderIndex: 1,
        },
        {
          propertyId: 'prop-1',
          phase: 'Structure',
          title: 'Foundation Completed',
          description: 'Foundation and basement structure completed and inspected',
          status: 'COMPLETED',
          completedDate: new Date('2025-02-28'),
          orderIndex: 2,
        },
        {
          propertyId: 'prop-1',
          phase: 'Structure',
          title: 'Frame Construction',
          description: 'Building frame and structural elements completed',
          status: 'COMPLETED',
          completedDate: new Date('2025-06-15'),
          orderIndex: 3,
        },
        {
          propertyId: 'prop-1',
          phase: 'Interior',
          title: 'MEP Installation',
          description: 'Mechanical, Electrical, and Plumbing systems installed',
          status: 'COMPLETED',
          completedDate: new Date('2025-09-30'),
          orderIndex: 4,
        },
        {
          propertyId: 'prop-1',
          phase: 'Finishing',
          title: 'Interior Finishing',
          description: 'Drywall, flooring, painting, and fixtures installation in progress',
          status: 'IN_PROGRESS',
          estimatedDate: 'March 2026',
          orderIndex: 5,
        },
        {
          propertyId: 'prop-1',
          phase: 'Completion',
          title: 'Final Inspection',
          description: 'Final building inspection and certificate of occupancy',
          status: 'PENDING',
          estimatedDate: 'May 2026',
          orderIndex: 6,
        },
      ],
    });
    console.log('✅ Created 6 timeline milestones\n');

    // Create Payments
    console.log('Creating payments...');
    await prisma.payment.createMany({
      data: [
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PAID',
          dueDate: new Date('2025-01-01'),
          paidDate: new Date('2024-12-28'),
          description: 'Initial Down Payment - 10%',
          invoiceNumber: 'INV-2025-001',
          installmentNumber: 1,
          totalInstallments: 10,
          percentage: 10.0,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PAID',
          dueDate: new Date('2025-04-01'),
          paidDate: new Date('2025-03-28'),
          description: 'Second Installment - 10%',
          invoiceNumber: 'INV-2025-002',
          installmentNumber: 2,
          totalInstallments: 10,
          percentage: 10.0,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PAID',
          dueDate: new Date('2025-07-01'),
          paidDate: new Date('2025-06-30'),
          description: 'Third Installment - 10%',
          invoiceNumber: 'INV-2025-003',
          installmentNumber: 3,
          totalInstallments: 10,
          percentage: 10.0,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PENDING',
          dueDate: new Date('2026-01-01'),
          description: 'Fourth Installment - 10%',
          invoiceNumber: 'INV-2026-001',
          installmentNumber: 4,
          totalInstallments: 10,
          percentage: 10.0,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PENDING',
          dueDate: new Date('2026-04-01'),
          description: 'Fifth Installment - 10%',
          invoiceNumber: 'INV-2026-002',
          installmentNumber: 5,
          totalInstallments: 10,
          percentage: 10.0,
        },
        {
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
          propertyId: 'prop-1',
          amount: 150000.00,
          currency: 'AED',
          paymentType: 'INSTALLMENT',
          status: 'PENDING',
          dueDate: new Date('2026-07-01'),
          description: 'Sixth Installment - 10%',
          invoiceNumber: 'INV-2026-003',
          installmentNumber: 6,
          totalInstallments: 10,
          percentage: 10.0,
        },
      ],
    });
    console.log('✅ Created 6 payments\n');

    // Create Documents
    console.log('Creating documents...');
    await prisma.document.createMany({
      data: [
        {
          title: 'Sale Agreement',
          type: 'Contract',
          fileUrl: '/documents/sale-agreement-mh401.pdf',
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        },
        {
          title: 'Payment Receipt - Jan 2025',
          type: 'Receipt',
          fileUrl: '/documents/receipt-jan2025.pdf',
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        },
        {
          title: 'NOC Certificate',
          type: 'NOC',
          fileUrl: '/documents/noc-certificate.pdf',
          userId: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        },
      ],
    });
    console.log('✅ Created 3 documents\n');

    console.log('🎉 Database seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

seed();
