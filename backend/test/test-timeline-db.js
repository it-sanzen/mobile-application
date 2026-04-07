const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const count = await prisma.timelineMilestone.count();
    console.log('Total milestones in DB:', count);

    if (count > 0) {
        const milestones = await prisma.timelineMilestone.findMany({ take: 5 });
        console.log('Sample milestones:', JSON.stringify(milestones, null, 2));
    } else {
        console.log('NO MILESTONES FOUND. The database table is empty!');
    }
}

main().catch(console.error).finally(() => prisma.$disconnect());
