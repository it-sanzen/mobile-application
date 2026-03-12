const { PrismaClient } = require('@prisma/client');
const p = new PrismaClient();

p.user.findMany().then(users => {
    console.log('\n=== Users in Database ===');
    if (users.length === 0) {
        console.log('No users found!');
    } else {
        users.forEach(u => {
            console.log(`  ID: ${u.id}`);
            console.log(`  Name: ${u.name}`);
            console.log(`  Email: ${u.email}`);
            console.log('  ---');
        });
        console.log(`Total: ${users.length} user(s)`);
    }
    p.$disconnect();
}).catch(err => {
    console.error('Error:', err.message);
    p.$disconnect();
});
