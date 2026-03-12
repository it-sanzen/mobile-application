const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function updateFirstUserData() {
    try {
        console.log('🌱 Starting data update for firstuser@gmail.com...\n');

        // 1. Get user ID
        const user = await prisma.user.findUnique({
            where: { email: 'firstuser@gmail.com' },
            include: { userProperties: true }
        });

        if (!user) {
            console.error('❌ User firstuser@gmail.com not found!');
            return;
        }

        const userId = user.id;
        const propertyId = user.userProperties.length > 0 ? user.userProperties[0].propertyId : null;

        if (!propertyId) {
            console.error('❌ No property found for this user. Did the Zenlagoon script run successfully?');
            return;
        }

        // 2. Update User Profile with Address Details
        console.log('Updating user address details...');
        await prisma.user.update({
            where: { id: userId },
            data: {
                phone: '+971 50 123 4567',
                address: 'Downtown Dubai, UAE',
                unit: 'Boulevard Heights, Apt 1404',
            }
        });

        // 3. Add 3 Documents
        console.log('Adding 3 Documents (Sales Offer, Reservation Form, SPA)...');

        const documentsToAdd = [
            {
                title: 'Sales Offer',
                fileUrl: '/uploads/documents/dummy-sales-offer.pdf',
                fileType: 'pdf',
                category: 'Sales',
                description: 'Initial sales offer documentation'
            },
            {
                title: 'Reservation Form',
                fileUrl: '/uploads/documents/dummy-reservation-form.pdf',
                fileType: 'pdf',
                category: 'Legal',
                description: 'Signed reservation agreement'
            },
            {
                title: 'Sales and Purchase Agreement (SPA)',
                fileUrl: '/uploads/documents/dummy-spa.pdf',
                fileType: 'pdf',
                category: 'Legal',
                description: 'Finalized SPA documentation'
            }
        ];

        for (const doc of documentsToAdd) {
            await prisma.document.create({
                data: {
                    userId,
                    propertyId,
                    title: doc.title,
                    fileUrl: doc.fileUrl,
                    fileType: doc.fileType,
                    category: doc.category,
                    description: doc.description
                }
            });
        }

        // 4. Create dummy files on disk to pass the download file existence check
        const fs = require('fs');
        const path = require('path');

        // Using the same path logic as in the documents service
        const uploadPath = path.join(__dirname, 'uploads', 'documents');

        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }

        for (const doc of documentsToAdd) {
            const filePath = path.join(__dirname, doc.fileUrl);
            // Create an empty dummy file if it doesn't exist
            if (!fs.existsSync(filePath)) {
                fs.writeFileSync(filePath, 'Dummy PDF content for testing');
            }
        }

        console.log('✅ Updated address details');
        console.log('✅ Created 3 documents and dummy files on disk');
        console.log('🎉 Data successfully updated for firstuser!');
    } catch (error) {
        console.error('❌ Error updating data:', error);
    } finally {
        await prisma.$disconnect();
    }
}

updateFirstUserData();
