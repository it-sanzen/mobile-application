import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding Sukoon by Sanzen demo data...\n');

  // ─── 1. Addon Offers ───────────────────────────────────────────────
  console.log('Deleting existing addon offers...');
  await prisma.addonOffer.deleteMany();

  console.log('Creating addon offers...');
  const addonOffers = [
    {
      title: 'Private Swimming Pool',
      description:
        'Transform your backyard into a luxury oasis with a custom-designed infinity pool, complete with LED lighting, heating system, and automated maintenance.',
      imageUrl: 'assets/images/pool_addon.png',
      icon: '🏊',
      price: 85000,
      category: 'OUTDOOR' as const,
      isActive: true,
    },
    {
      title: 'Smart Home Automation',
      description:
        'Control your entire villa with one touch. Includes smart lighting, climate control, security cameras, automated blinds, and voice assistant integration.',
      imageUrl: 'assets/images/home_automation_addon.png',
      icon: '🏠',
      price: 45000,
      category: 'SMART_HOME' as const,
      isActive: true,
    },
    {
      title: 'Modular Kitchen Design',
      description:
        'Premium Italian modular kitchen with quartz countertops, soft-close cabinets, built-in appliances, and a breakfast island with waterfall edge.',
      imageUrl: 'assets/images/kitchen_design_addon.png',
      icon: '🍳',
      price: 65000,
      category: 'UPGRADE' as const,
      isActive: true,
    },
    {
      title: 'EV Charging Station',
      description:
        'Future-proof your villa with a Level 2 home EV charging station. Compatible with all electric vehicles, includes smart app monitoring.',
      imageUrl: 'assets/images/ev_charger_addon.png',
      icon: '⚡',
      price: 12000,
      category: 'VEHICLE' as const,
      isActive: true,
    },
    {
      title: 'Solar Energy System',
      description:
        '20kW rooftop solar panel system with battery storage. Reduce your electricity bills by up to 80% while contributing to a greener future.',
      imageUrl: 'assets/images/solar_solutions_addon.png',
      icon: '☀️',
      price: 55000,
      category: 'OTHER' as const,
      isActive: true,
    },
    {
      title: 'Home Security System',
      description:
        'Advanced 24/7 security with facial recognition cameras, smart door locks, motion sensors, and real-time alerts to your phone.',
      icon: '🔒',
      price: 28000,
      category: 'SECURITY' as const,
      isActive: true,
    },
  ];

  for (const offer of addonOffers) {
    await prisma.addonOffer.create({ data: offer });
  }
  console.log(`  ✅ Created ${addonOffers.length} addon offers\n`);

  // ─── 2. Company News ───────────────────────────────────────────────
  console.log('Deleting existing company news...');
  await prisma.companyNews.deleteMany();

  console.log('Creating company news...');
  const now = new Date();
  const companyNews = [
    {
      category: 'ANNOUNCEMENT' as const,
      title: 'Sukoon by Sanzen Phase 1 Sold Out',
      description:
        'We are delighted to announce that all Phase 1 villas at Sukoon by Sanzen have been sold out within the first month of launch. Phase 2 reservations are now open.',
      time: '2 days ago',
      publishedAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000),
      isPublished: true,
      isFeatured: true,
    },
    {
      category: 'AWARD' as const,
      title: 'Sanzen Wins Best Developer Award 2026',
      description:
        'Sanzen has been recognized as the Best Emerging Developer at the Ajman Real Estate Awards 2026 for our innovative approach to sustainable luxury living.',
      time: '1 week ago',
      publishedAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
      isPublished: true,
      isFeatured: false,
    },
    {
      category: 'EVENT' as const,
      title: 'Sukoon Villa Open Day — March 28',
      description:
        'Visit our show villa at Al Jurf, Ajman. Experience the Sukoon lifestyle firsthand with guided tours, interior design consultations, and exclusive early-bird offers.',
      time: '3 days ago',
      publishedAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
      isPublished: true,
      isFeatured: true,
    },
    {
      category: 'SUSTAINABILITY' as const,
      title: 'Green Building Certification Achieved',
      description:
        'Sukoon by Sanzen has received the prestigious Estidama Pearl Rating for our commitment to sustainable construction, energy efficiency, and water conservation.',
      time: '5 days ago',
      publishedAt: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000),
      isPublished: true,
      isFeatured: false,
    },
    {
      category: 'COMMUNITY' as const,
      title: 'Residents Community Group Launch',
      description:
        'Join the Sukoon Residents WhatsApp community! Connect with your future neighbors, get exclusive updates, and participate in community events.',
      time: '1 day ago',
      publishedAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000),
      isPublished: true,
      isFeatured: false,
    },
  ];

  for (const news of companyNews) {
    await prisma.companyNews.create({ data: news });
  }
  console.log(`  ✅ Created ${companyNews.length} company news items\n`);

  // ─── 3. Payment Schedule ───────────────────────────────────────────
  console.log('Looking up test buyer and property...');

  const buyer = await prisma.user.findUnique({
    where: { email: 'buyer@test.com' },
  });

  if (!buyer) {
    console.log('  ⚠️  Test buyer (buyer@test.com) not found. Skipping payment seeding.');
  } else {
    // Find the first property, or the first property assigned to the buyer
    const userProperty = await prisma.userProperty.findFirst({
      where: { userId: buyer.id },
      include: { property: true },
    });

    let propertyId: string | undefined;
    if (userProperty) {
      propertyId = userProperty.propertyId;
      console.log(`  Found buyer's property: ${userProperty.property.name}`);
    } else {
      const firstProperty = await prisma.property.findFirst();
      if (firstProperty) {
        propertyId = firstProperty.id;
        console.log(`  Using first property: ${firstProperty.name}`);
      }
    }

    if (!propertyId) {
      console.log('  ⚠️  No properties found. Skipping payment seeding.');
    } else {
      console.log('Deleting existing payments for test buyer...');
      await prisma.payment.deleteMany({ where: { userId: buyer.id } });

      console.log('Creating payment schedule...');

      const payments = [
        // 9 installments
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PAID' as const,
          dueDate: new Date('2026-01-15'),
          paidDate: new Date('2026-01-14'),
          description: 'Booking Fee (10%)',
          invoiceNumber: 'SNZ-2026-001',
          installmentNumber: 1,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PAID' as const,
          dueDate: new Date('2026-03-15'),
          paidDate: new Date('2026-03-12'),
          description: '1st Installment (10%)',
          invoiceNumber: 'SNZ-2026-002',
          installmentNumber: 2,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2026-06-15'),
          description: '2nd Installment (10%)',
          invoiceNumber: 'SNZ-2026-003',
          installmentNumber: 3,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2026-09-15'),
          description: '3rd Installment (10%)',
          invoiceNumber: 'SNZ-2026-004',
          installmentNumber: 4,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2026-12-15'),
          description: '4th Installment (10%)',
          invoiceNumber: 'SNZ-2026-005',
          installmentNumber: 5,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2027-03-15'),
          description: '5th Installment (10%)',
          invoiceNumber: 'SNZ-2026-006',
          installmentNumber: 6,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 250000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2027-06-15'),
          description: '6th Installment (10%)',
          invoiceNumber: 'SNZ-2026-007',
          installmentNumber: 7,
          totalInstallments: 9,
          percentage: 10,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 375000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2027-09-15'),
          description: '7th Installment (15%)',
          invoiceNumber: 'SNZ-2026-008',
          installmentNumber: 8,
          totalInstallments: 9,
          percentage: 15,
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 375000,
          currency: 'AED',
          paymentType: 'INSTALLMENT' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2027-12-15'),
          description: 'Handover (15%)',
          invoiceNumber: 'SNZ-2026-009',
          installmentNumber: 9,
          totalInstallments: 9,
          percentage: 15,
        },
        // Additional charges
        {
          userId: buyer.id,
          propertyId,
          amount: 8500,
          currency: 'AED',
          paymentType: 'MAINTENANCE_FEE' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2026-04-15'),
          description: 'Annual Maintenance Fee',
          invoiceNumber: 'SNZ-2026-010',
        },
        {
          userId: buyer.id,
          propertyId,
          amount: 12000,
          currency: 'AED',
          paymentType: 'SERVICE_CHARGE' as const,
          status: 'PENDING' as const,
          dueDate: new Date('2026-07-15'),
          description: 'Community Service Charge',
          invoiceNumber: 'SNZ-2026-011',
        },
      ];

      for (const payment of payments) {
        await prisma.payment.create({ data: payment });
      }
      console.log(`  ✅ Created ${payments.length} payments\n`);
    }
  }

  console.log('🎉 Sukoon by Sanzen seed data complete!');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
