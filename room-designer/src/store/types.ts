export interface ShowroomTemplate {
  id: string;
  name: string;
  description: string;
  roomType: string;
  style: string;
  furnishingLevel: string;
  thumbnailUrl: string;
  modelUrl: string;
  floorDimensions: { width: number; depth: number };
  defaultItems: DesignItemData[];
  previewImages: string[];
}

export interface FurnitureProduct {
  id: string;
  name: string;
  description: string;
  category: string;
  subcategory: string;
  brand: string;
  price: number;
  currency: string;
  thumbnailUrl: string;
  modelUrl: string;
  dimensions: { width: number; height: number; depth: number };
  colorOptions: string[];
  tags: string[];
  isFeatured: boolean;
}

export interface UserDesign {
  id: string;
  userId: string;
  showroomId: string;
  name: string;
  thumbnailUrl: string;
  sceneState: unknown;
  createdAt: string;
  updatedAt: string;
  showroom?: ShowroomTemplate;
  items?: DesignItemData[];
}

export interface DesignItemData {
  productId: string;
  positionX: number;
  positionY: number;
  positionZ: number;
  rotationX: number;
  rotationY: number;
  rotationZ: number;
  scaleX: number;
  scaleY: number;
  scaleZ: number;
  colorOption?: string;
}

export interface PlacedItem {
  instanceId: string;
  productId: string;
  product: FurnitureProduct;
  position: [number, number, number];
  rotation: [number, number, number];
  scale: [number, number, number];
  colorOption?: string;
}

export interface WishlistPreview {
  items: WishlistPreviewItem[];
  totalItems: number;
  totalCost: number;
}

export interface WishlistPreviewItem {
  productId: string;
  product: FurnitureProduct;
  quantity: number;
}
