const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
async function main() {
  await prisma.user.update({
    where: { email: 'admin@sanzen.ae' },
    data: { isAdmin: true },
  })
  console.log('SuperAdmin updated')
}
main().catch(e => { console.error(e); process.exit(1) }).finally(async () => { await prisma.$disconnect() })
