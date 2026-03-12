const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function seed() {
    console.log('--- Seeding Dummy Admin Data ---');

    console.log('1. Fetching a User...');
    const user = await prisma.user.findFirst();

    console.log('2. Fetching a Property...');
    const property = await prisma.property.findFirst();

    if (!user) {
        console.log('No user found! Creating a dummy user...');
        // We'll just rely on existing if possible.
    }
    if (!property) {
        console.log('No property found!');
    }

    try {
        console.log('3. Seeding Company News...');
        await prisma.companyNews.create({
            data: {
                title: 'Welcome to the New Admin Panel',
                description: 'We have successfully launched the new content management system allowing administrators to deploy real-time updates directly to the mobile app.',
                time: '1 min read',
                category: 'ANNOUNCEMENT',
                isPublished: true,
                isFeatured: true
            }
        });

        if (user) {
            console.log('4. Seeding targeted Unit Update for user:', user.email);
            await prisma.unitUpdate.create({
                data: {
                    userId: user.id,
                    updateType: 'CONSTRUCTION',
                    title: 'Your unit is 50% complete!',
                    description: 'The structural walls have been fully erected and plumbing is scheduled for next week.',
                    time: 'Just now',
                    isPublished: true
                }
            });
        }

        if (property) {
            console.log('5. Seeding Timeline Milestone for property:', property.name);
            await prisma.timelineMilestone.create({
                data: {
                    propertyId: property.id,
                    phase: 'Foundations',
                    title: 'Concrete Sub-structure',
                    description: 'The primary underground reinforced concrete structure has been poured and cured.',
                    status: 'COMPLETED',
                    completedDate: new Date(),
                    estimatedDate: 'Q1 2026',
                    orderIndex: 0
                }
            });
            await prisma.timelineMilestone.create({
                data: {
                    propertyId: property.id,
                    phase: 'Superstructure',
                    title: 'First Floor Framing',
                    description: 'Erecting the steel and concrete frame for the first floor elevation.',
                    status: 'IN_PROGRESS',
                    estimatedDate: 'Q2 2026',
                    orderIndex: 1
                }
            });
        }

        console.log('--- Done Seeding! ---');
    } catch (e) {
        console.error('Error seeding data:', e);
    } finally {
        await prisma.$disconnect();
    }
}

seed();
