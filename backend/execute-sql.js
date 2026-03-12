const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Read DATABASE_URL from .env
const envContent = fs.readFileSync(path.join(__dirname, '.env'), 'utf-8');
const databaseUrlMatch = envContent.match(/DATABASE_URL=(.+)/);

if (!databaseUrlMatch) {
  console.error('DATABASE_URL not found in .env file');
  process.exit(1);
}

// Remove pgbouncer parameter and sslmode for direct connection
let databaseUrl = databaseUrlMatch[1].trim();
databaseUrl = databaseUrl.replace('&pgbouncer=true', '').replace('?pgbouncer=true&', '?');
databaseUrl = databaseUrl.replace('&sslmode=require', '').replace('?sslmode=require&', '?');
databaseUrl = databaseUrl.replace('&sslmode=require', '').replace('sslmode=require&', '');
databaseUrl = databaseUrl.replace('sslmode=require', '');

console.log('Connecting to database...');

// Set process env to bypass SSL verification
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const pool = new Pool({
  connectionString: databaseUrl
});

async function executeSql() {
  const client = await pool.connect();

  try {
    // Read the SQL file
    const sqlContent = fs.readFileSync(path.join(__dirname, 'create-all-tables.sql'), 'utf-8');

    console.log('Executing SQL script...');
    console.log('This may take a moment...\n');

    // Execute the SQL
    await client.query(sqlContent);

    console.log('✅ Success! All tables created and sample data inserted.');
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

  } catch (error) {
    console.error('❌ Error executing SQL:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

executeSql()
  .then(() => {
    console.log('\n🎉 Database setup complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('\n❌ Setup failed:', err);
    process.exit(1);
  });
