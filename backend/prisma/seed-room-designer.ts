import { PrismaClient, ProductCategory, RoomType, ShowroomStyle, FurnishingLevel } from '@prisma/client';

const prisma = new PrismaClient();

// ─── Furniture Products ────────────────────────────────────────────────────────

interface ProductDef {
  name: string;
  slug: string;
  category: ProductCategory;
  price: number;
  isFeatured: boolean;
  dimensions: { width: number; height: number; depth: number };
  description: string;
  tags: string[];
}

const products: ProductDef[] = [
  // ── SOFA ──
  { name: 'Lounge Sofa', slug: 'loungeSofa', category: 'SOFA', price: 4500, isFeatured: true, dimensions: { width: 2.0, height: 0.85, depth: 0.9 }, description: 'Classic lounge sofa with comfortable cushioning', tags: ['living-room', 'lounge'] },
  { name: 'Corner Sofa', slug: 'loungeSofaCorner', category: 'SOFA', price: 6200, isFeatured: false, dimensions: { width: 2.6, height: 0.85, depth: 2.6 }, description: 'L-shaped corner sofa for spacious living rooms', tags: ['living-room', 'corner'] },
  { name: 'Long Sofa', slug: 'loungeSofaLong', category: 'SOFA', price: 5800, isFeatured: false, dimensions: { width: 2.8, height: 0.85, depth: 0.9 }, description: 'Extended lounge sofa for extra seating', tags: ['living-room', 'lounge'] },
  { name: 'Designer Sofa', slug: 'loungeDesignSofa', category: 'SOFA', price: 7500, isFeatured: false, dimensions: { width: 2.2, height: 0.75, depth: 0.95 }, description: 'Premium designer sofa with modern lines', tags: ['living-room', 'designer', 'premium'] },

  // ── CHAIR ──
  { name: 'Lounge Chair', slug: 'loungeChair', category: 'CHAIR', price: 2200, isFeatured: true, dimensions: { width: 0.8, height: 0.9, depth: 0.85 }, description: 'Comfortable lounge armchair', tags: ['living-room', 'lounge'] },
  { name: 'Relaxation Chair', slug: 'loungeChairRelax', category: 'CHAIR', price: 3100, isFeatured: false, dimensions: { width: 0.85, height: 1.0, depth: 0.9 }, description: 'Ergonomic relaxation armchair with recline', tags: ['living-room', 'relax'] },
  { name: 'Designer Chair', slug: 'loungeDesignChair', category: 'CHAIR', price: 2800, isFeatured: false, dimensions: { width: 0.75, height: 0.85, depth: 0.8 }, description: 'Modern designer accent chair', tags: ['living-room', 'designer'] },
  { name: 'Basic Chair', slug: 'chair', category: 'CHAIR', price: 800, isFeatured: false, dimensions: { width: 0.45, height: 0.85, depth: 0.45 }, description: 'Simple wooden dining chair', tags: ['dining', 'basic'] },
  { name: 'Cushion Chair', slug: 'chairCushion', category: 'CHAIR', price: 950, isFeatured: false, dimensions: { width: 0.48, height: 0.85, depth: 0.48 }, description: 'Dining chair with padded cushion seat', tags: ['dining', 'cushion'] },
  { name: 'Desk Chair', slug: 'chairDesk', category: 'CHAIR', price: 1200, isFeatured: false, dimensions: { width: 0.6, height: 1.1, depth: 0.6 }, description: 'Swivel desk chair with armrests', tags: ['office', 'desk'] },
  { name: 'Modern Cushion Chair', slug: 'chairModernCushion', category: 'CHAIR', price: 1500, isFeatured: false, dimensions: { width: 0.55, height: 0.8, depth: 0.55 }, description: 'Modern upholstered dining chair', tags: ['dining', 'modern'] },

  // ── TABLE ──
  { name: 'Coffee Table', slug: 'tableCoffee', category: 'TABLE', price: 1800, isFeatured: true, dimensions: { width: 1.2, height: 0.45, depth: 0.6 }, description: 'Rectangular wooden coffee table', tags: ['living-room', 'coffee'] },
  { name: 'Glass Coffee Table', slug: 'tableCoffeeGlass', category: 'TABLE', price: 2200, isFeatured: false, dimensions: { width: 1.2, height: 0.42, depth: 0.6 }, description: 'Modern glass-top coffee table', tags: ['living-room', 'glass'] },
  { name: 'Square Coffee Table', slug: 'tableCoffeeSquare', category: 'TABLE', price: 1600, isFeatured: false, dimensions: { width: 0.8, height: 0.45, depth: 0.8 }, description: 'Compact square coffee table', tags: ['living-room', 'coffee'] },
  { name: 'Round Table', slug: 'tableRound', category: 'TABLE', price: 2800, isFeatured: false, dimensions: { width: 1.2, height: 0.75, depth: 1.2 }, description: 'Round dining table for four', tags: ['dining', 'round'] },
  { name: 'Dining Table', slug: 'table', category: 'TABLE', price: 3500, isFeatured: false, dimensions: { width: 1.8, height: 0.75, depth: 0.9 }, description: 'Rectangular dining table for six', tags: ['dining', 'rectangular'] },
  { name: 'Table with Cloth', slug: 'tableCloth', category: 'TABLE', price: 3200, isFeatured: false, dimensions: { width: 1.8, height: 0.75, depth: 0.9 }, description: 'Dining table with decorative cloth', tags: ['dining', 'cloth'] },
  { name: 'Side Table', slug: 'sideTable', category: 'TABLE', price: 900, isFeatured: false, dimensions: { width: 0.45, height: 0.55, depth: 0.45 }, description: 'Small round side table', tags: ['living-room', 'side'] },
  { name: 'Side Table with Drawers', slug: 'sideTableDrawers', category: 'TABLE', price: 1100, isFeatured: false, dimensions: { width: 0.5, height: 0.6, depth: 0.4 }, description: 'Bedside table with storage drawers', tags: ['bedroom', 'storage'] },
  { name: 'Office Desk', slug: 'desk', category: 'TABLE', price: 2400, isFeatured: false, dimensions: { width: 1.4, height: 0.75, depth: 0.7 }, description: 'Standard office work desk', tags: ['office', 'desk'] },
  { name: 'Corner Desk', slug: 'deskCorner', category: 'TABLE', price: 3200, isFeatured: false, dimensions: { width: 1.6, height: 0.75, depth: 1.6 }, description: 'L-shaped corner desk for home office', tags: ['office', 'corner'] },

  // ── BED ──
  { name: 'Double Bed', slug: 'bedDouble', category: 'BED', price: 5500, isFeatured: true, dimensions: { width: 1.6, height: 1.1, depth: 2.1 }, description: 'Queen-size double bed with headboard', tags: ['bedroom', 'queen'] },
  { name: 'Single Bed', slug: 'bedSingle', category: 'BED', price: 3200, isFeatured: false, dimensions: { width: 1.0, height: 1.0, depth: 2.0 }, description: 'Standard single bed frame', tags: ['bedroom', 'single'] },
  { name: 'Bunk Bed', slug: 'bedBunk', category: 'BED', price: 4800, isFeatured: false, dimensions: { width: 1.0, height: 1.8, depth: 2.0 }, description: 'Space-saving bunk bed for kids', tags: ['bedroom', 'kids', 'bunk'] },

  // ── STORAGE ──
  { name: 'Open Bookcase', slug: 'bookcaseOpen', category: 'STORAGE', price: 2100, isFeatured: true, dimensions: { width: 0.8, height: 1.8, depth: 0.35 }, description: 'Open shelf bookcase for display', tags: ['office', 'storage', 'bookcase'] },
  { name: 'Wide Closed Bookcase', slug: 'bookcaseClosedWide', category: 'STORAGE', price: 3500, isFeatured: false, dimensions: { width: 1.2, height: 1.8, depth: 0.4 }, description: 'Wide bookcase with cabinet doors', tags: ['office', 'storage'] },
  { name: 'Closed Bookcase', slug: 'bookcaseClosed', category: 'STORAGE', price: 2800, isFeatured: false, dimensions: { width: 0.8, height: 1.8, depth: 0.4 }, description: 'Bookcase with closed cabinet doors', tags: ['office', 'storage'] },
  { name: 'TV Cabinet', slug: 'cabinetTelevision', category: 'STORAGE', price: 4200, isFeatured: false, dimensions: { width: 1.6, height: 0.5, depth: 0.45 }, description: 'Low TV entertainment cabinet', tags: ['living-room', 'tv', 'media'] },
  { name: 'TV Cabinet with Doors', slug: 'cabinetTelevisionDoors', category: 'STORAGE', price: 4800, isFeatured: false, dimensions: { width: 1.8, height: 0.55, depth: 0.45 }, description: 'TV cabinet with enclosed doors', tags: ['living-room', 'tv', 'media'] },

  // ── LIGHTING ──
  { name: 'Round Floor Lamp', slug: 'lampRoundFloor', category: 'LIGHTING', price: 650, isFeatured: true, dimensions: { width: 0.35, height: 1.6, depth: 0.35 }, description: 'Standing floor lamp with round shade', tags: ['living-room', 'floor-lamp'] },
  { name: 'Square Floor Lamp', slug: 'lampSquareFloor', category: 'LIGHTING', price: 720, isFeatured: false, dimensions: { width: 0.3, height: 1.6, depth: 0.3 }, description: 'Modern floor lamp with square shade', tags: ['living-room', 'floor-lamp'] },
  { name: 'Round Table Lamp', slug: 'lampRoundTable', category: 'LIGHTING', price: 450, isFeatured: false, dimensions: { width: 0.25, height: 0.5, depth: 0.25 }, description: 'Small table lamp with round shade', tags: ['bedroom', 'table-lamp'] },
  { name: 'Square Table Lamp', slug: 'lampSquareTable', category: 'LIGHTING', price: 520, isFeatured: false, dimensions: { width: 0.2, height: 0.45, depth: 0.2 }, description: 'Compact table lamp with square shade', tags: ['bedroom', 'table-lamp'] },
  { name: 'Wall Lamp', slug: 'lampWall', category: 'LIGHTING', price: 380, isFeatured: false, dimensions: { width: 0.15, height: 0.3, depth: 0.2 }, description: 'Wall-mounted sconce light', tags: ['bedroom', 'wall-lamp'] },
  { name: 'Ceiling Fan', slug: 'ceilingFan', category: 'LIGHTING', price: 1200, isFeatured: false, dimensions: { width: 1.2, height: 0.35, depth: 1.2 }, description: 'Ceiling fan with integrated light', tags: ['living-room', 'ceiling'] },

  // ── RUG ──
  { name: 'Round Rug', slug: 'rugRound', category: 'RUG', price: 1800, isFeatured: true, dimensions: { width: 2.0, height: 0.02, depth: 2.0 }, description: 'Circular area rug in neutral tones', tags: ['living-room', 'round'] },
  { name: 'Rectangle Rug', slug: 'rugRectangle', category: 'RUG', price: 2200, isFeatured: false, dimensions: { width: 2.4, height: 0.02, depth: 1.6 }, description: 'Large rectangular area rug', tags: ['living-room', 'rectangle'] },
  { name: 'Square Rug', slug: 'rugSquare', category: 'RUG', price: 1600, isFeatured: false, dimensions: { width: 1.8, height: 0.02, depth: 1.8 }, description: 'Medium square accent rug', tags: ['bedroom', 'square'] },

  // ── DECOR ──
  { name: 'Modern Television', slug: 'televisionModern', category: 'DECOR', price: 8500, isFeatured: true, dimensions: { width: 1.2, height: 0.7, depth: 0.08 }, description: '55-inch modern flat-screen television', tags: ['living-room', 'electronics', 'tv'] },
  { name: 'Computer Monitor', slug: 'computerScreen', category: 'DECOR', price: 3200, isFeatured: false, dimensions: { width: 0.6, height: 0.45, depth: 0.2 }, description: '27-inch computer monitor', tags: ['office', 'electronics'] },
  { name: 'Bluetooth Speaker', slug: 'speaker', category: 'DECOR', price: 1500, isFeatured: false, dimensions: { width: 0.15, height: 0.3, depth: 0.15 }, description: 'Wireless bluetooth speaker', tags: ['living-room', 'electronics', 'audio'] },
  { name: 'Decorative Pillow', slug: 'pillow', category: 'DECOR', price: 180, isFeatured: false, dimensions: { width: 0.4, height: 0.1, depth: 0.4 }, description: 'Soft decorative throw pillow', tags: ['living-room', 'bedroom', 'textile'] },
  { name: 'Long Pillow', slug: 'pillowLong', category: 'DECOR', price: 250, isFeatured: false, dimensions: { width: 0.7, height: 0.1, depth: 0.3 }, description: 'Bolster-style long pillow', tags: ['bedroom', 'textile'] },
  { name: 'Book Stack', slug: 'books', category: 'DECOR', price: 120, isFeatured: false, dimensions: { width: 0.2, height: 0.25, depth: 0.15 }, description: 'Decorative stack of books', tags: ['office', 'decor'] },
  { name: 'Coat Rack', slug: 'coatRackStanding', category: 'DECOR', price: 650, isFeatured: false, dimensions: { width: 0.45, height: 1.75, depth: 0.45 }, description: 'Standing coat and hat rack', tags: ['hallway', 'storage'] },
  { name: 'Trash Can', slug: 'trashcan', category: 'DECOR', price: 80, isFeatured: false, dimensions: { width: 0.3, height: 0.5, depth: 0.3 }, description: 'Modern waste bin', tags: ['office', 'kitchen', 'utility'] },

  // ── PLANT ──
  { name: 'Potted Plant', slug: 'pottedPlant', category: 'PLANT', price: 280, isFeatured: true, dimensions: { width: 0.4, height: 0.8, depth: 0.4 }, description: 'Medium potted indoor plant', tags: ['living-room', 'greenery'] },
  { name: 'Small Plant 1', slug: 'plantSmall1', category: 'PLANT', price: 150, isFeatured: false, dimensions: { width: 0.15, height: 0.25, depth: 0.15 }, description: 'Small succulent desk plant', tags: ['office', 'desk', 'greenery'] },
  { name: 'Small Plant 2', slug: 'plantSmall2', category: 'PLANT', price: 150, isFeatured: false, dimensions: { width: 0.15, height: 0.3, depth: 0.15 }, description: 'Small fern desk plant', tags: ['office', 'desk', 'greenery'] },
  { name: 'Small Plant 3', slug: 'plantSmall3', category: 'PLANT', price: 150, isFeatured: false, dimensions: { width: 0.18, height: 0.2, depth: 0.18 }, description: 'Small cactus desk plant', tags: ['office', 'desk', 'greenery'] },

  // ── KITCHEN_FIXTURE ──
  { name: 'Refrigerator', slug: 'kitchenFridge', category: 'KITCHEN_FIXTURE', price: 6500, isFeatured: true, dimensions: { width: 0.7, height: 1.8, depth: 0.7 }, description: 'Double-door stainless steel refrigerator', tags: ['kitchen', 'appliance'] },
  { name: 'Stove', slug: 'kitchenStove', category: 'KITCHEN_FIXTURE', price: 4200, isFeatured: false, dimensions: { width: 0.6, height: 0.9, depth: 0.6 }, description: 'Four-burner gas stove with oven', tags: ['kitchen', 'appliance'] },
  { name: 'Kitchen Sink', slug: 'kitchenSink', category: 'KITCHEN_FIXTURE', price: 2800, isFeatured: false, dimensions: { width: 0.8, height: 0.9, depth: 0.6 }, description: 'Stainless steel kitchen sink unit', tags: ['kitchen', 'fixture'] },
  { name: 'Kitchen Cabinet', slug: 'kitchenCabinet', category: 'KITCHEN_FIXTURE', price: 3500, isFeatured: false, dimensions: { width: 0.6, height: 0.9, depth: 0.6 }, description: 'Base kitchen cabinet with countertop', tags: ['kitchen', 'storage'] },
  { name: 'Coffee Machine', slug: 'kitchenCoffeeMachine', category: 'KITCHEN_FIXTURE', price: 2200, isFeatured: false, dimensions: { width: 0.3, height: 0.4, depth: 0.35 }, description: 'Automatic espresso coffee machine', tags: ['kitchen', 'appliance'] },
  { name: 'Bar Stool', slug: 'stoolBar', category: 'KITCHEN_FIXTURE', price: 800, isFeatured: false, dimensions: { width: 0.4, height: 0.75, depth: 0.4 }, description: 'Modern bar height stool', tags: ['kitchen', 'seating'] },

  // ── BATHROOM_FIXTURE ──
  { name: 'Bathroom Bench', slug: 'bench', category: 'BATHROOM_FIXTURE', price: 1200, isFeatured: true, dimensions: { width: 1.0, height: 0.45, depth: 0.4 }, description: 'Wooden bathroom bench', tags: ['bathroom', 'seating'] },
  { name: 'Cushioned Bench', slug: 'benchCushion', category: 'BATHROOM_FIXTURE', price: 1500, isFeatured: false, dimensions: { width: 1.0, height: 0.48, depth: 0.42 }, description: 'Padded bathroom bench with cushion', tags: ['bathroom', 'seating'] },
];

// ─── Showroom Templates ────────────────────────────────────────────────────────

interface ShowroomDef {
  name: string;
  description: string;
  roomType: RoomType;
  style: ShowroomStyle;
  furnishingLevel: FurnishingLevel;
  floorDimensions: { width: number; length: number };
  modelSlug: string;
  sortOrder: number;
  // slugs of default products for furnished rooms
  defaultProductSlugs?: string[];
}

const showrooms: ShowroomDef[] = [
  // 1. Modern Living Room (EMPTY)
  {
    name: 'Modern Living Room',
    description: 'A sleek modern living room with clean lines and neutral tones',
    roomType: 'LIVING_ROOM', style: 'MODERN', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 6, length: 5 }, modelSlug: 'living-room-modern', sortOrder: 1,
  },
  // 2. Furnished Modern Living
  {
    name: 'Furnished Modern Living',
    description: 'A fully furnished modern living room ready for inspiration',
    roomType: 'LIVING_ROOM', style: 'MODERN', furnishingLevel: 'FULLY_FURNISHED',
    floorDimensions: { width: 6, length: 5 }, modelSlug: 'living-room-modern-furnished', sortOrder: 2,
    defaultProductSlugs: ['loungeSofa', 'loungeSofaCorner', 'tableCoffeeGlass', 'cabinetTelevision', 'televisionModern', 'rugRectangle', 'lampRoundFloor', 'pottedPlant'],
  },
  // 3. Scandinavian Bedroom (EMPTY)
  {
    name: 'Scandinavian Bedroom',
    description: 'A bright Scandinavian bedroom with warm wood accents',
    roomType: 'BEDROOM', style: 'SCANDINAVIAN', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 5, length: 4 }, modelSlug: 'bedroom-scandinavian', sortOrder: 3,
  },
  // 4. Furnished Cozy Bedroom
  {
    name: 'Furnished Cozy Bedroom',
    description: 'A fully furnished cozy Scandinavian bedroom',
    roomType: 'BEDROOM', style: 'SCANDINAVIAN', furnishingLevel: 'FULLY_FURNISHED',
    floorDimensions: { width: 5, length: 4 }, modelSlug: 'bedroom-scandinavian-furnished', sortOrder: 4,
    defaultProductSlugs: ['bedDouble', 'sideTableDrawers', 'sideTableDrawers', 'lampRoundTable', 'lampRoundTable', 'bookcaseOpen', 'rugSquare', 'pottedPlant', 'pillow', 'pillowLong'],
  },
  // 5. Minimalist Kitchen (EMPTY)
  {
    name: 'Minimalist Kitchen',
    description: 'A streamlined minimalist kitchen with clean surfaces',
    roomType: 'KITCHEN', style: 'MINIMALIST', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 4, length: 3.5 }, modelSlug: 'kitchen-minimalist', sortOrder: 5,
  },
  // 6. Furnished Kitchen (SEMI)
  {
    name: 'Furnished Kitchen',
    description: 'A semi-furnished minimalist kitchen with essential appliances',
    roomType: 'KITCHEN', style: 'MINIMALIST', furnishingLevel: 'SEMI_FURNISHED',
    floorDimensions: { width: 4, length: 3.5 }, modelSlug: 'kitchen-minimalist-furnished', sortOrder: 6,
    defaultProductSlugs: ['kitchenFridge', 'kitchenStove', 'kitchenSink', 'kitchenCabinet', 'stoolBar', 'stoolBar'],
  },
  // 7. Modern Bathroom (EMPTY)
  {
    name: 'Modern Bathroom',
    description: 'A modern bathroom with contemporary fixtures',
    roomType: 'BATHROOM', style: 'MODERN', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 3, length: 2.5 }, modelSlug: 'bathroom-modern', sortOrder: 7,
  },
  // 8. Semi-Furnished Bathroom
  {
    name: 'Semi-Furnished Bathroom',
    description: 'A semi-furnished modern bathroom with bench seating',
    roomType: 'BATHROOM', style: 'MODERN', furnishingLevel: 'SEMI_FURNISHED',
    floorDimensions: { width: 3, length: 2.5 }, modelSlug: 'bathroom-modern-furnished', sortOrder: 8,
    defaultProductSlugs: ['bench', 'benchCushion', 'plantSmall1'],
  },
  // 9. Industrial Office (EMPTY)
  {
    name: 'Industrial Office',
    description: 'An industrial-style home office with exposed elements',
    roomType: 'OFFICE', style: 'INDUSTRIAL', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 4, length: 3.5 }, modelSlug: 'office-industrial', sortOrder: 9,
  },
  // 10. Furnished Home Office
  {
    name: 'Furnished Home Office',
    description: 'A fully furnished industrial home office ready to work',
    roomType: 'OFFICE', style: 'INDUSTRIAL', furnishingLevel: 'FULLY_FURNISHED',
    floorDimensions: { width: 4, length: 3.5 }, modelSlug: 'office-industrial-furnished', sortOrder: 10,
    defaultProductSlugs: ['deskCorner', 'chairDesk', 'computerScreen', 'bookcaseClosedWide', 'lampSquareFloor', 'books', 'plantSmall2', 'trashcan'],
  },
  // 11. Traditional Dining (EMPTY)
  {
    name: 'Traditional Dining',
    description: 'A traditional dining room with warm classic ambiance',
    roomType: 'DINING_ROOM', style: 'TRADITIONAL', furnishingLevel: 'EMPTY',
    floorDimensions: { width: 5, length: 4 }, modelSlug: 'dining-traditional', sortOrder: 11,
  },
  // 12. Furnished Dining Room
  {
    name: 'Furnished Dining Room',
    description: 'A fully furnished traditional dining room for family gatherings',
    roomType: 'DINING_ROOM', style: 'TRADITIONAL', furnishingLevel: 'FULLY_FURNISHED',
    floorDimensions: { width: 5, length: 4 }, modelSlug: 'dining-traditional-furnished', sortOrder: 12,
    defaultProductSlugs: ['table', 'chair', 'chair', 'chair', 'chair', 'chairCushion', 'chairCushion', 'rugRectangle', 'lampRoundFloor', 'pottedPlant', 'ceilingFan'],
  },
];

// ─── Main Seed Function ────────────────────────────────────────────────────────

async function main() {
  console.log('🏠 Seeding Room Designer data...\n');

  // ── 1. Delete existing data (idempotent) ──
  console.log('Clearing existing FurnitureProduct and ShowroomTemplate rows...');
  // Delete in dependency order: design items & wishlist items reference products
  await prisma.designItem.deleteMany({});
  await prisma.wishlistItem.deleteMany({});
  await prisma.wishlist.deleteMany({});
  await prisma.userDesign.deleteMany({});
  await prisma.furnitureProduct.deleteMany({});
  await prisma.showroomTemplate.deleteMany({});
  console.log('  Done.\n');

  // ── 2. Seed Furniture Products ──
  console.log('Seeding furniture products...');

  const createdProducts: Record<string, string> = {}; // slug -> id

  for (let i = 0; i < products.length; i++) {
    const p = products[i];
    const record = await prisma.furnitureProduct.create({
      data: {
        name: p.name,
        description: p.description,
        category: p.category,
        price: p.price,
        currency: 'AED',
        thumbnailUrl: `/uploads/furniture/${p.slug}.png`,
        modelUrl: `/uploads/furniture/models/${p.slug}.glb`,
        dimensions: p.dimensions,
        tags: p.tags,
        isActive: true,
        isFeatured: p.isFeatured,
        sortOrder: i + 1,
      },
    });
    createdProducts[p.slug] = record.id;
  }

  console.log(`  Created ${Object.keys(createdProducts).length} furniture products.\n`);

  // ── 3. Seed Showroom Templates ──
  console.log('Seeding showroom templates...');

  let showroomCount = 0;
  for (const s of showrooms) {
    // Build defaultItems JSON from product slugs
    let defaultItems: { productId: string; slug: string }[] | undefined;
    if (s.defaultProductSlugs && s.defaultProductSlugs.length > 0) {
      defaultItems = s.defaultProductSlugs.map((slug) => ({
        productId: createdProducts[slug],
        slug,
      }));
    }

    await prisma.showroomTemplate.create({
      data: {
        name: s.name,
        description: s.description,
        roomType: s.roomType,
        style: s.style,
        furnishingLevel: s.furnishingLevel,
        thumbnailUrl: `/uploads/showrooms/${s.modelSlug}-thumb.png`,
        modelUrl: `/uploads/showrooms/${s.modelSlug}.glb`,
        previewImages: [
          `/uploads/showrooms/${s.modelSlug}-preview-1.png`,
          `/uploads/showrooms/${s.modelSlug}-preview-2.png`,
        ],
        floorDimensions: s.floorDimensions,
        defaultItems: defaultItems ?? undefined,
        isActive: true,
        sortOrder: s.sortOrder,
      },
    });
    showroomCount++;
  }

  console.log(`  Created ${showroomCount} showroom templates.\n`);

  // ── 4. Summary ──
  const productsByCategory: Record<string, number> = {};
  for (const p of products) {
    productsByCategory[p.category] = (productsByCategory[p.category] || 0) + 1;
  }

  const showroomsByType: Record<string, number> = {};
  for (const s of showrooms) {
    showroomsByType[s.roomType] = (showroomsByType[s.roomType] || 0) + 1;
  }

  console.log('═══════════════════════════════════════════');
  console.log('  SEED SUMMARY');
  console.log('═══════════════════════════════════════════');
  console.log(`  Total furniture products: ${products.length}`);
  console.log('  By category:');
  for (const [cat, count] of Object.entries(productsByCategory)) {
    console.log(`    ${cat}: ${count}`);
  }
  console.log(`\n  Total showroom templates: ${showroomCount}`);
  console.log('  By room type:');
  for (const [type, count] of Object.entries(showroomsByType)) {
    console.log(`    ${type}: ${count}`);
  }
  console.log(`\n  Featured products: ${products.filter((p) => p.isFeatured).length}`);
  console.log(`  Furnished showrooms: ${showrooms.filter((s) => s.furnishingLevel !== 'EMPTY').length}`);
  console.log('═══════════════════════════════════════════');
}

main()
  .then(async () => {
    await prisma.$disconnect();
    console.log('\nSeed completed successfully.');
  })
  .catch(async (e) => {
    console.error('Seed failed:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
