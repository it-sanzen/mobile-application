const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function seedZenlagoonData() {
    try {
        console.log('🌱 Starting Zenlagoon data seeding for firstuser@gmail.com...\n');

        // 1. Get user ID
        const user = await prisma.user.findUnique({
            where: { email: 'firstuser@gmail.com' }
        });

        if (!user) {
            console.error('❌ User firstuser@gmail.com not found!');
            return;
        }

        const userId = user.id;

        // 2. Create Property
        console.log('Creating Zenlagoon Villa property...');
        const property = await prisma.property.create({
            data: {
                name: 'Zenlagoon Villa',
                location: 'Sharjah Waterfront',
                propertyType: 'VILLA',
                bedrooms: 4,
                area: 4500.0,
                status: 'UNDER_CONSTRUCTION',
                completionPercentage: 35.0,
                currentPhase: 'Structure',
                estimatedCompletion: 'Q4 2027'
            }
        });

        // 3. Link Property to User
        console.log('Linking property to user...');
        await prisma.userProperty.create({
            data: {
                userId,
                propertyId: property.id,
                unitCode: 'ZL-105',
                isPrimary: true
            }
        });

        // 4. Create Unit Updates
        console.log('Creating unit updates and notifications...');
        await prisma.unitUpdate.createMany({
            data: [
                {
                    userId,
                    updateType: 'CONSTRUCTION',
                    title: 'Foundation Completed',
                    description: 'The foundation for Zenlagoon Villa ZL-105 has been successfully laid and inspected. Structural framework is now beginning.',
                    time: '2 weeks ago',
                    isPublished: true,
                },
                {
                    userId,
                    updateType: 'GENERAL',
                    title: 'Upcoming Payment Reminder',
                    description: 'Your next installment of AED 99,554.95 is due on 27/05/2026. Please ensure funds are available.',
                    time: 'Just now',
                    isPublished: true,
                }
            ]
        });

        // 5. Create Payment Schedule
        console.log('Creating payment schedule matching screenshot...');
        const payments = [
            { num: 1, date: new Date('2026-01-27'), percent: 5, amount: 99554.95, status: 'PAID', paidDate: new Date('2026-01-25') },
            { num: 2, date: new Date('2026-02-26'), percent: 5, amount: 99554.95, status: 'PAID', paidDate: new Date('2026-02-24') },
            { num: 3, date: new Date('2026-05-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 4, date: new Date('2026-09-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 5, date: new Date('2027-01-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 6, date: new Date('2027-05-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 7, date: new Date('2027-09-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 8, date: new Date('2028-01-27'), percent: 5, amount: 99554.95, status: 'PENDING', paidDate: null },
            { num: 9, date: null, percent: 60, amount: 1194659.40, status: 'PENDING', paidDate: null },
        ];

        for (const p of payments) {
            await prisma.payment.create({
                data: {
                    userId,
                    propertyId: property.id,
                    amount: p.amount,
                    currency: 'AED',
                    paymentType: 'INSTALLMENT',
                    status: p.status,
                    dueDate: p.date,
                    paidDate: p.paidDate,
                    description: `Installment ${p.num} - ${p.percent}%`,
                    invoiceNumber: `INV-ZL105-00${p.num}`,
                    installmentNumber: p.num,
                    totalInstallments: 9,
                    percentage: p.percent,
                }
            });
        }

        console.log('✅ Created 9 payment installments');
        console.log('🎉 Data successfully seeded for firstuser!');
    } catch (error) {
        console.error('❌ Error seeding data:', error);
    } finally {
        await prisma.$disconnect();
    }
}

seedZenlagoonData();
