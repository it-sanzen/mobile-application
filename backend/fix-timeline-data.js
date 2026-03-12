const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log('Fetching a real property from the database...');
    const property = await prisma.property.findFirst();

    if (!property) {
        console.log('No properties found! Cannot map timelines.');
        return;
    }

    console.log(`Found Property: ${property.name} (${property.id})`);

    console.log('Searching for orphaned or dummy timeline milestones...');
    const updateResult = await prisma.timelineMilestone.updateMany({
        where: {
            propertyId: 'prop-1'
        },
        data: {
            propertyId: property.id
        }
    });

    console.log(`Successfully relinked ${updateResult.count} milestones to Property ${property.name}!`);

    // Also check if there are milestones with other property IDs that might need linking.
    const allMilestones = await prisma.timelineMilestone.findMany({ select: { id: true, propertyId: true, title: true } });
    console.log('Current DB Milestones mapping:', allMilestones);
}

main().catch(console.error).finally(() => prisma.$disconnect());
