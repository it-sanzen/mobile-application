const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function createFirstUser() {
    try {
        const hashedPassword = await bcrypt.hash('firstuser123', 10);

        // Check if user exists first to avoid unique constraint errors
        const existingUser = await prisma.user.findUnique({
            where: { email: 'firstuser@gmail.com' }
        });

        if (existingUser) {
            // Update password if exists
            await prisma.user.update({
                where: { email: 'firstuser@gmail.com' },
                data: { password: hashedPassword }
            });
            console.log('✅ Updated existing firstuser@gmail.com with new password');
        } else {
            // Create new user (using only fields defined in schema)
            await prisma.user.create({
                data: {
                    email: 'firstuser@gmail.com',
                    password: hashedPassword,
                    name: 'First User',
                    phone: '+971501234567',
                    isAdmin: false
                }
            });
            console.log('✅ Created new user firstuser@gmail.com');
        }
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await prisma.$disconnect();
    }
}

createFirstUser();
