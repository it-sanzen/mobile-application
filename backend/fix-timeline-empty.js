const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const propertyId = '3c3833b2-622c-46a2-b505-42cb749177c5';

    const existingMilestones = await prisma.timelineMilestone.count({ where: { propertyId } });

    if (existingMilestones > 0) {
        console.log('Milestones already exist for this property!');
        return;
    }

    console.log(`Injecting construction milestones for New Property: ${propertyId}`);

    await prisma.timelineMilestone.createMany({
        data: [
            {
                propertyId,
                phase: 'Foundations',
                title: 'Site Preparation & Excavation',
                description: 'Clearing the site and preparing the foundation trench.',
                status: 'COMPLETED',
                completedDate: new Date('2026-01-15'),
                orderIndex: 1,
            },
            {
                propertyId,
                phase: 'Foundations',
                title: 'Concrete Pouring',
                description: 'Pouring the main concrete foundation and curing.',
                status: 'COMPLETED',
                completedDate: new Date('2026-02-20'),
                orderIndex: 2,
            },
            {
                propertyId,
                phase: 'Structure',
                title: 'Steel Framework',
                description: 'Erecting the primary steel framework of the villa.',
                status: 'IN_PROGRESS',
                estimatedDate: 'Mid March 2026',
                orderIndex: 3,
            },
            {
                propertyId,
                phase: 'MEP',
                title: 'Mechanical & Plumbing Rough-In',
                description: 'Installing internal pipes and HVAC ducting.',
                status: 'PENDING',
                estimatedDate: 'May 2026',
                orderIndex: 4,
            },
            {
                propertyId,
                phase: 'Finishing',
                title: 'Interior Painting & Fixtures',
                description: 'Final coat of paint and luxury fixture installation.',
                status: 'PENDING',
                estimatedDate: 'August 2026',
                orderIndex: 5,
            }
        ]
    });

    console.log('Successfully injected 5 Timeline Milestones into the live database!');
}

main().catch(console.error).finally(() => prisma.$disconnect());
