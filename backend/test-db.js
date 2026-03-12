const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const user = await prisma.user.findFirst();
    if (!user) {
        console.log('No user found in the database. Cannot create a notification.');
        return;
    }

    const notif = await prisma.notification.create({
        data: {
            userId: user.id,
            title: 'Direct DB Test',
            message: 'If you can read this, the Notification schema is fully operational!',
            type: 'SYSTEM'
        }
    });

    console.log('Successfully created Notification:', notif);
}

main()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
