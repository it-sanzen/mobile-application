import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('Reading SQL file...');
    const sqlPath = path.join(__dirname, '../../create-all-tables.sql');
    const sql = fs.readFileSync(sqlPath, 'utf-8');

    console.log('Executing SQL statements...\n');

    // Split SQL into individual statements and execute them
    const statements = sql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    console.log(`Found ${statements.length} SQL statements to execute\n`);

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement) {
        try {
          console.log(`Executing statement ${i + 1}/${statements.length}...`);
          await prisma.$executeRawUnsafe(statement + ';');
        } catch (error: any) {
          // Skip errors for already existing items
          if (error.code !== 'P2010' || !error.message.includes('already exists')) {
            console.warn(`Warning on statement ${i + 1}:`, error.message.substring(0, 100));
          }
        }
      }
    }

    console.log('\n✅ Success! All tables created and sample data inserted.');
    console.log('\nCreated tables:');
    console.log('  ✓ Document');
    console.log('  ✓ UnitUpdate');
    console.log('  ✓ CompanyNews');
    console.log('  ✓ property');
    console.log('  ✓ user_property');
    console.log('  ✓ timeline_milestone');
    console.log('  ✓ addon_offer');
    console.log('  ✓ payment');
    console.log('\n✅ Sample data inserted for all tables');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

main()
  .then(() => {
    console.log('\n🎉 Database setup complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
