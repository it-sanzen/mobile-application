const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function createUser() {
  try {
    console.log('🔐 Creating seconduser account...\n');

    // Hash the password
    const hashedPassword = await bcrypt.hash('seconduser@123', 10);

    // Create the user with the specific ID
    const user = await prisma.user.create({
      data: {
        id: '54f3b7d7-f145-43c0-aa1e-c295025642ee',
        email: 'seconduser@gmail.com',
        password: hashedPassword,
        name: 'seconduser',
        phone: '0564327112',
        address: 'marina dubai',
        unit: 'zenlagoons',
      },
    });

    console.log('✅ User created successfully!');
    console.log('   Email:', user.email);
    console.log('   ID:', user.id);
    console.log('   Name:', user.name);
    console.log('   Phone:', user.phone);
    console.log('   Address:', user.address);
    console.log('   Unit:', user.unit);
    console.log('\n');

  } catch (error) {
    console.error('❌ Error creating user:', error.message);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

createUser()
  .then(() => {
    console.log('🎉 User creation complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
