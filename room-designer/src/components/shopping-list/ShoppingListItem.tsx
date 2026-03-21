import { useState } from 'react';
import type { WishlistPreviewItem } from '../../store/types';
import { getServerUrl } from '../../services/api';

const CATEGORY_COLORS: Record<string, string> = {
  SOFA: '#3b82f6',
  CHAIR: '#f97316',
  TABLE: '#92400e',
  BED: '#8b5cf6',
  STORAGE: '#6b7280',
  LIGHTING: '#eab308',
  DECOR: '#ec4899',
  RUG: '#14b8a6',
  PLANT: '#22c55e',
  OUTDOOR: '#22c55e',
};

const CATEGORY_LABELS: Record<string, string> = {
  SOFA: 'Sofa',
  BED: 'Bed',
  TABLE: 'Table',
  CHAIR: 'Chair',
  STORAGE: 'Storage',
  LIGHTING: 'Lighting',
  RUG: 'Rug',
  DECOR: 'Decor',
  PLANT: 'Plant',
};

function getThumbnailUrl(url: string | undefined): string | null {
  if (!url) return null;
  if (url.startsWith('http')) return url;
  return `${getServerUrl()}${url.startsWith('/') ? '' : '/'}${url}`;
}

interface ShoppingListItemProps {
  item: WishlistPreviewItem;
}

export default function ShoppingListItem({ item }: ShoppingListItemProps) {
  const { product, quantity } = item;
  const [imgError, setImgError] = useState(false);
  const lineTotal = (product.price ?? 0) * quantity;
  const color = CATEGORY_COLORS[product.category?.toUpperCase()] || '#6b7280';
  const categoryLabel =
    CATEGORY_LABELS[product.category?.toUpperCase()] ||
    product.category?.charAt(0) + product.category?.slice(1).toLowerCase();
  const thumbnailUrl = getThumbnailUrl(product.thumbnailUrl);
  const showImage = thumbnailUrl && !imgError;

  return (
    <div className="flex items-center gap-3 py-3 px-4 hover:bg-gray-50 transition-colors">
      {/* Thumbnail */}
      <div
        className="w-14 h-14 rounded-lg flex items-center justify-center shrink-0 overflow-hidden"
        style={{ backgroundColor: showImage ? '#f9f9f9' : `${color}15` }}
      >
        {showImage ? (
          <img
            src={thumbnailUrl}
            alt={product.name}
            className="w-full h-full object-contain p-1"
            onError={() => setImgError(true)}
          />
        ) : (
          <div
            className="w-7 h-7 rounded"
            style={{ backgroundColor: color, opacity: 0.5 }}
          />
        )}
      </div>

      {/* Name + category */}
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-gray-800 truncate">
          {product.name}
        </p>
        <span
          className="inline-block text-[10px] font-medium px-1.5 py-0.5 rounded-full mt-0.5"
          style={{ backgroundColor: `${color}15`, color }}
        >
          {categoryLabel}
        </span>
      </div>

      {/* Quantity badge */}
      <div className="flex items-center justify-center w-7 h-7 rounded-full bg-gray-100 text-xs font-semibold text-gray-700 shrink-0">
        {quantity}x
      </div>

      {/* Price */}
      <div className="text-right shrink-0 w-24">
        <p className="text-sm font-semibold text-gray-800">
          AED {lineTotal.toLocaleString()}
        </p>
        {quantity > 1 && (
          <p className="text-[10px] text-gray-400">
            AED {(product.price ?? 0).toLocaleString()} ea
          </p>
        )}
      </div>
    </div>
  );
}
