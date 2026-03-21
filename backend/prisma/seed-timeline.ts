import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Find a property with milestones
  const property = await prisma.property.findFirst({
    include: { timelineMilestones: { orderBy: { orderIndex: 'asc' } } },
  });

  if (!property) {
    console.log('No properties found. Creating a test property...');
    const newProperty = await prisma.property.create({
      data: {
        name: 'Zen Lagoons Villa - Type A',
        location: 'Al Jurf, Ajman',
        propertyType: 'VILLA',
        bedrooms: 4,
        area: 3200,
        status: 'UNDER_CONSTRUCTION',
        completionPercentage: 45,
        currentPhase: 'Structure',
        estimatedCompletion: 'Q4 2027',
      },
    });
    console.log('Created property:', newProperty.id);

    // Create milestones
    const milestones = [
      { phase: 'Phase 1', title: 'Land Preparation', description: 'Site clearing, grading & soil testing', status: 'COMPLETED' as const, completionPercentage: 100, estimatedDate: 'Q1 2026', orderIndex: 0, completedDate: new Date('2026-01-15') },
      { phase: 'Phase 2', title: 'Foundation', description: 'Piling, raft foundation & waterproofing', status: 'COMPLETED' as const, completionPercentage: 100, estimatedDate: 'Q2 2026', orderIndex: 1, completedDate: new Date('2026-03-01') },
      { phase: 'Phase 3', title: 'Structure', description: 'Columns, slabs & structural framework', status: 'IN_PROGRESS' as const, completionPercentage: 65, estimatedDate: 'Q3 2026', orderIndex: 2 },
      { phase: 'Phase 4', title: 'MEP Rough-in', description: 'Mechanical, electrical & plumbing rough installation', status: 'PENDING' as const, completionPercentage: 0, estimatedDate: 'Q1 2027', orderIndex: 3 },
      { phase: 'Phase 5', title: 'Interior Finishing', description: 'Flooring, painting, fixtures & cabinetry', status: 'PENDING' as const, completionPercentage: 0, estimatedDate: 'Q3 2027', orderIndex: 4 },
      { phase: 'Phase 6', title: 'Handover', description: 'Final inspection, snagging & key handover', status: 'PENDING' as const, completionPercentage: 0, estimatedDate: 'Q4 2027', orderIndex: 5 },
    ];

    for (const m of milestones) {
      await prisma.timelineMilestone.create({
        data: { ...m, propertyId: newProperty.id },
      });
    }
    console.log('Created 6 milestones');

    // Re-fetch with milestones
    return seed(newProperty.id);
  }

  console.log(`Found property: ${property.name} (${property.id}) with ${property.timelineMilestones.length} milestones`);

  // Update milestones with completion percentages if they don't have them
  for (const m of property.timelineMilestones) {
    if (m.status === 'COMPLETED' && m.completionPercentage === 0) {
      await prisma.timelineMilestone.update({ where: { id: m.id }, data: { completionPercentage: 100 } });
    }
    if (m.status === 'IN_PROGRESS' && m.completionPercentage === 0) {
      await prisma.timelineMilestone.update({ where: { id: m.id }, data: { completionPercentage: 65 } });
    }
  }

  await seed(property.id);
}

async function seed(propertyId: string) {
  const milestones = await prisma.timelineMilestone.findMany({
    where: { propertyId },
    orderBy: { orderIndex: 'asc' },
  });

  if (milestones.length === 0) {
    console.log('No milestones found');
    return;
  }

  // Clear old seed data
  for (const m of milestones) {
    await prisma.milestoneUpdate.deleteMany({ where: { milestoneId: m.id } });
    await prisma.milestonePhoto.deleteMany({ where: { milestoneId: m.id } });
  }
  console.log('Cleared old updates/photos');

  // Milestone 0 (Phase 1 - Land Preparation - COMPLETED)
  if (milestones[0]) {
    await prisma.milestoneUpdate.create({
      data: {
        milestoneId: milestones[0].id,
        notes: 'Site clearing completed. All vegetation removed, soil testing passed with excellent load-bearing capacity. Ready for foundation work.',
        createdAt: new Date('2026-01-10T09:30:00'),
        photos: {
          create: [
            { milestoneId: milestones[0].id, photoUrl: '/uploads/timeline/site-clearing.jpg', photoType: 'PROGRESS' },
          ],
        },
      },
    });
    console.log('Seeded Phase 1 update');
  }

  // Milestone 1 (Phase 2 - Foundation - COMPLETED)
  if (milestones[1]) {
    await prisma.milestoneUpdate.create({
      data: {
        milestoneId: milestones[1].id,
        notes: 'Concrete pouring for raft foundation completed. Curing period started. Waterproofing membrane applied to basement walls.',
        createdAt: new Date('2026-02-20T14:15:00'),
        photos: {
          create: [
            { milestoneId: milestones[1].id, photoUrl: '/uploads/timeline/concrete-pouring.jpg', photoType: 'PROGRESS' },
          ],
        },
      },
    });
    console.log('Seeded Phase 2 update');
  }

  // Milestone 2 (Phase 3 - Structure - IN PROGRESS) - Multiple updates
  if (milestones[2]) {
    await prisma.milestoneUpdate.create({
      data: {
        milestoneId: milestones[2].id,
        notes: 'Ground floor steel columns erected. First floor slab formwork in progress. Concrete strength test: 42 MPa — exceeds requirement.',
        createdAt: new Date('2026-03-10T11:00:00'),
        photos: {
          create: [
            { milestoneId: milestones[2].id, photoUrl: '/uploads/timeline/construction-columns.jpg', photoType: 'PROGRESS' },
            { milestoneId: milestones[2].id, photoUrl: '/uploads/timeline/villa-structure.jpg', photoType: 'PROGRESS' },
          ],
        },
      },
    });

    await prisma.milestoneUpdate.create({
      data: {
        milestoneId: milestones[2].id,
        notes: 'First floor slab poured successfully. Steel reinforcement delivery confirmed for next phase. On track for Q3 completion.',
        createdAt: new Date('2026-03-15T16:30:00'),
        photos: {
          create: [
            { milestoneId: milestones[2].id, photoUrl: '/uploads/timeline/building-progress.jpg', photoType: 'PROGRESS' },
          ],
        },
      },
    });

    // Before/After photos for structure phase
    await prisma.milestonePhoto.create({
      data: {
        milestoneId: milestones[2].id,
        photoUrl: '/uploads/timeline/foundation-concrete.jpg',
        photoType: 'BEFORE',
        caption: 'Foundation stage',
      },
    });
    await prisma.milestonePhoto.create({
      data: {
        milestoneId: milestones[2].id,
        photoUrl: '/uploads/timeline/construction-columns.jpg',
        photoType: 'AFTER',
        caption: 'Structure in progress',
      },
    });

    console.log('Seeded Phase 3 updates + before/after photos');
  }

  // Create a test user + userProperty if none exists
  let testUser = await prisma.user.findFirst({ where: { email: 'buyer@test.com' } });
  if (!testUser) {
    testUser = await prisma.user.create({
      data: {
        email: 'buyer@test.com',
        password: '$2b$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ12', // hashed placeholder
        name: 'Test Buyer',
      },
    });
    console.log('Created test buyer user:', testUser.id);
  }

  const existingUP = await prisma.userProperty.findFirst({
    where: { userId: testUser.id, propertyId },
  });
  if (!existingUP) {
    await prisma.userProperty.create({
      data: {
        userId: testUser.id,
        propertyId,
        unitCode: 'VILLA-A-101',
        isPrimary: true,
      },
    });
    console.log('Assigned property to test buyer');
  }

  console.log('\nSeed complete! Test credentials:');
  console.log('  Email: buyer@test.com');
  console.log('  Property ID:', propertyId);
  console.log('  Milestones:', milestones.length);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
