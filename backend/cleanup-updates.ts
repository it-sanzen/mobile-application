import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const result = await prisma.unitUpdate.deleteMany({
        where: {
            title: 'Upcoming Payment Reminder'
        }
    });
    console.log(`Deleted ${result.count} stray payment reminders from Unit Updates table.`);
}

main()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
