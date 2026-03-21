import { useMemo } from 'react';
import { ArrowLeft, ShoppingBag, Loader2, Save } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import ShoppingListItem from './ShoppingListItem';

export default function ShoppingList() {
  const setView = useDesignerStore((s) => s.setView);
  const placedItems = useDesignerStore((s) => s.placedItems);
  const saveDesign = useDesignerStore((s) => s.saveDesign);
  const saving = useDesignerStore((s) => s.saving);

  // Aggregate placed items by productId locally - no API call needed
  const { items, totalItems, totalCost } = useMemo(() => {
    const itemMap = new Map<
      string,
      { productId: string; product: (typeof placedItems)[0]['product']; quantity: number }
    >();
    for (const placed of placedItems) {
      const existing = itemMap.get(placed.productId);
      if (existing) {
        existing.quantity++;
      } else {
        itemMap.set(placed.productId, {
          productId: placed.productId,
          product: placed.product,
          quantity: 1,
        });
      }
    }
    const items = Array.from(itemMap.values());
    const totalItems = placedItems.length;
    const totalCost = items.reduce(
      (sum, i) => sum + (i.product.price ?? 0) * i.quantity,
      0
    );
    return { items, totalItems, totalCost };
  }, [placedItems]);

  return (
    <div className="flex flex-col h-screen w-screen bg-white">
      {/* Header */}
      <div className="flex items-center h-12 px-3 border-b border-gray-200 shrink-0">
        <button
          onClick={() => setView('designer')}
          className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
        >
          <ArrowLeft size={20} className="text-gray-700" />
        </button>
        <ShoppingBag size={18} className="text-[#144525] ml-2" />
        <span className="text-sm font-semibold text-gray-800 ml-1.5">
          Shopping List
        </span>
        <span className="text-xs text-gray-400 ml-2">
          {totalItems} item{totalItems !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Items */}
      <div className="flex-1 overflow-y-auto">
        {items.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64 text-gray-400">
            <ShoppingBag size={40} className="mb-3 opacity-40" />
            <p className="text-sm font-medium">No items yet</p>
            <p className="text-xs mt-1">
              Add furniture to your design to see them here
            </p>
          </div>
        ) : (
          <div className="divide-y divide-gray-100">
            {items.map((item) => (
              <ShoppingListItem key={item.productId} item={item} />
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      {items.length > 0 && (
        <div className="border-t border-gray-200 p-4 space-y-3 shrink-0 bg-white">
          {/* Summary */}
          <div className="flex items-center justify-between">
            <span className="text-xs text-gray-500">
              {totalItems} item{totalItems !== 1 ? 's' : ''} total
            </span>
            <div className="text-right">
              <p className="text-lg font-bold text-gray-900">
                AED{' '}
                {totalCost.toLocaleString(undefined, {
                  minimumFractionDigits: 0,
                  maximumFractionDigits: 0,
                })}
              </p>
              <p className="text-[10px] text-gray-400">Estimated total</p>
            </div>
          </div>

          {/* Save Design button */}
          <button
            onClick={saveDesign}
            disabled={saving}
            className="w-full flex items-center justify-center gap-2 py-3 text-sm font-semibold text-white bg-[#144525] rounded-xl hover:bg-[#1a5a30] transition-colors disabled:opacity-60"
          >
            {saving ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <Save size={18} />
            )}
            Save Design
          </button>
        </div>
      )}
    </div>
  );
}
