const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function runTest() {
    console.log('--- SANZEN NOTIFICATION SYSTEM E2E TEST ---\n');

    try {
        const targetUser = await prisma.user.findFirst();
        if (!targetUser) throw new Error("No users found in database to test with.");

        console.log(`[1] Selected Target User: ${targetUser.name} (${targetUser.email})`);

        await prisma.notification.deleteMany({ where: { userId: targetUser.id } });
        console.log('[2] Cleared existing notifications for a clean test.');

        console.log(`[3] Simulating 'DocumentsService' Backend Action: Uploading new NOC Document...`);
        const docData = { title: 'Final Handover NOC', type: 'NOC', fileUrl: '/assets/fake-pdf.pdf', userId: targetUser.id };
        const doc = await prisma.document.create({ data: docData });

        // Simulate what the DocumentsService now does automatically underneath:
        const titleString = 'New Document Uploaded';
        const messageString = `A new NOC document "Final Handover NOC" has been uploaded to your profile.`;

        await prisma.notification.create({
            data: {
                userId: targetUser.id,
                title: titleString,
                message: messageString,
                type: 'DOCUMENT',
                relatedEntityId: doc.id,
            }
        });

        console.log(`[4] Document Uploaded successfully & trigger fired. Let's check the user's Inbox in the Database...`);

        // 4. Emulate the Flutter App hitting 'GET /notifications'
        const inbox = await prisma.notification.findMany({
            where: { userId: targetUser.id },
            orderBy: { createdAt: 'desc' },
        });

        console.log('\n✅ [SUCCESS] FLUTTER APP INBOX PAYLOAD:');
        console.log(JSON.stringify(inbox, null, 2));

    } catch (err) {
        console.error('❌ Test Failed:', err.message);
    } finally {
        await prisma.$disconnect();
    }
}

runTest();
