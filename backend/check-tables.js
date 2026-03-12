const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkTables() {
  try {
    console.log('Checking if tables exist...\n');

    // Try to query each table
    const tests = [
      { name: 'user_property', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."user_property"` },
      { name: 'CompanyNews', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."CompanyNews"` },
      { name: 'UnitUpdate', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."UnitUpdate"` },
      { name: 'Document', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."Document"` },
      { name: 'addon_offer', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."addon_offer"` },
      { name: 'property', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."property"` },
      { name: 'payment', query: async () => await prisma.$queryRaw`SELECT COUNT(*) FROM "sanzenapp"."payment"` },
    ];

    for (const test of tests) {
      try {
        const result = await test.query();
        console.log(`✅ ${test.name}: EXISTS (${result[0].count} rows)`);
      } catch (error) {
        console.log(`❌ ${test.name}: DOES NOT EXIST - ${error.message.substring(0, 100)}`);
      }
    }

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkTables();
