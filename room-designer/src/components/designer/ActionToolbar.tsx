import { useState } from 'react';
import { ShoppingBag, RotateCw, ArrowLeftRight, Copy, Trash2, X } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import type { FurnitureProduct } from '../../store/types';

export default function ActionToolbar() {
  const selectedItemId = useDesignerStore((s) => s.selectedItemId);
  const placedItems = useDesignerStore((s) => s.placedItems);
  const products = useDesignerStore((s) => s.products);
  const updateItemTransform = useDesignerStore((s) => s.updateItemTransform);
  const duplicateItem = useDesignerStore((s) => s.duplicateItem);
  const removeItem = useDesignerStore((s) => s.removeItem);
  const selectItem = useDesignerStore((s) => s.selectItem);
  const setView = useDesignerStore((s) => s.setView);

  // Baked-in furniture selection
  const selectedBakedObject = useDesignerStore((s) => s.selectedBakedObject);
  const removeBakedObject = useDesignerStore((s) => s.removeBakedObject);
  const [showReplace, setShowReplace] = useState(false);
  const [replacements, setReplacements] = useState<FurnitureProduct[]>([]);

  // Handle baked-in furniture (part of GLB room model)
  if (selectedBakedObject && !selectedItemId) {
    const handleBakedRemove = () => {
      removeBakedObject();
    };

    const handleBakedReplace = () => {
      // Show all products to pick a replacement
      setReplacements(products);
      setShowReplace(true);
    };

    const handleBakedSwapWith = (newProduct: FurnitureProduct) => {
      // Remove baked object (hides it + sets pending position)
      removeBakedObject();
      // Add the new product at the baked object's position
      useDesignerStore.getState().addItem(newProduct);
      setShowReplace(false);
    };

    if (showReplace) {
      return (
        <div
          className="absolute bottom-14 left-1/2 -translate-x-1/2 z-20 w-[320px]"
          onPointerDown={(e) => e.stopPropagation()}
          onMouseDown={(e) => e.stopPropagation()}
          onClick={(e) => e.stopPropagation()}
        >
          <div className="bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden">
            <div className="flex items-center justify-between px-4 py-2.5 border-b border-gray-100">
              <span className="text-sm font-semibold text-gray-900">Replace with</span>
              <button onClick={() => setShowReplace(false)} className="text-gray-400 hover:text-gray-600">
                <X size={16} />
              </button>
            </div>
            <div className="max-h-[200px] overflow-y-auto p-2">
              {replacements.length === 0 ? (
                <p className="text-xs text-gray-400 text-center py-4">No alternatives available</p>
              ) : (
                <div className="grid grid-cols-2 gap-2">
                  {replacements.map((p) => (
                    <button
                      key={p.id}
                      onClick={() => handleBakedSwapWith(p)}
                      className="flex flex-col items-center p-2 rounded-xl border border-gray-100 hover:border-[#144525] hover:bg-green-50 transition-colors text-center"
                    >
                      <span className="text-xs font-medium text-gray-900 truncate w-full">{p.name}</span>
                      <span className="text-[10px] text-[#144525] font-semibold mt-0.5">AED {p.price?.toLocaleString()}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      );
    }

    const bakedActions = [
      { icon: ArrowLeftRight, label: 'Replace', onClick: handleBakedReplace },
      { icon: Trash2, label: 'Remove', onClick: handleBakedRemove, danger: true },
    ];

    return (
      <div
        className="absolute bottom-14 left-1/2 -translate-x-1/2 z-20"
        onPointerDown={(e) => e.stopPropagation()}
        onMouseDown={(e) => e.stopPropagation()}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Label showing what's selected */}
        <div className="text-center mb-2">
          <span className="bg-gray-900/90 text-white text-xs px-3 py-1 rounded-full font-medium">
            {selectedBakedObject.name || 'Room furniture'}
          </span>
        </div>
        <div className="flex items-stretch bg-gray-900 rounded-2xl shadow-2xl overflow-hidden">
          {bakedActions.map((action, idx) => (
            <div key={action.label} className="flex items-stretch">
              {idx > 0 && <div className="w-px bg-gray-700 my-2" />}
              <button
                onClick={action.onClick}
                className={`flex flex-col items-center justify-center gap-1 px-5 py-2.5 transition-colors ${
                  action.danger
                    ? 'hover:bg-red-900/50 text-red-400'
                    : 'hover:bg-gray-800 text-white'
                }`}
              >
                <action.icon size={18} />
                <span className="text-[10px] font-medium whitespace-nowrap">{action.label}</span>
              </button>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (!selectedItemId) return null;

  const item = placedItems.find((i) => i.instanceId === selectedItemId);
  if (!item) return null;

  const rotationDeg = Math.round(((item.rotation[1] * 180) / Math.PI) % 360 + 360) % 360;

  const handleRotate = () => {
    updateItemTransform(item.instanceId, {
      rotation: [item.rotation[0], item.rotation[1] + Math.PI / 4, item.rotation[2]],
    });
  };

  const handleReplace = () => {
    // Show same-category products to swap with
    const sameCategory = products.filter(
      (p) => p.category === item.product.category && p.id !== item.product.id
    );
    setReplacements(sameCategory);
    setShowReplace(true);
  };

  const handleSwapWith = (newProduct: FurnitureProduct) => {
    // Replace the item's product while keeping position/rotation
    const store = useDesignerStore.getState();
    const idx = store.placedItems.findIndex((i) => i.instanceId === selectedItemId);
    if (idx >= 0) {
      const updated = [...store.placedItems];
      updated[idx] = {
        ...updated[idx],
        productId: newProduct.id,
        product: newProduct,
      };
      useDesignerStore.setState({ placedItems: updated });
    }
    setShowReplace(false);
  };

  const handleCopy = () => duplicateItem(item.instanceId);

  const handleRemove = () => {
    removeItem(item.instanceId);
    selectItem(null);
  };

  // Replace panel
  if (showReplace) {
    return (
      <div
        className="absolute bottom-14 left-1/2 -translate-x-1/2 z-20 w-[320px]"
        onPointerDown={(e) => e.stopPropagation()}
        onMouseDown={(e) => e.stopPropagation()}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden">
          <div className="flex items-center justify-between px-4 py-2.5 border-b border-gray-100">
            <span className="text-sm font-semibold text-gray-900">Replace with</span>
            <button onClick={() => setShowReplace(false)} className="text-gray-400 hover:text-gray-600">
              <X size={16} />
            </button>
          </div>
          <div className="max-h-[200px] overflow-y-auto p-2">
            {replacements.length === 0 ? (
              <p className="text-xs text-gray-400 text-center py-4">No alternatives available</p>
            ) : (
              <div className="grid grid-cols-2 gap-2">
                {replacements.map((p) => (
                  <button
                    key={p.id}
                    onClick={() => handleSwapWith(p)}
                    className="flex flex-col items-center p-2 rounded-xl border border-gray-100 hover:border-[#144525] hover:bg-green-50 transition-colors text-center"
                  >
                    <span className="text-xs font-medium text-gray-900 truncate w-full">{p.name}</span>
                    <span className="text-[10px] text-[#144525] font-semibold mt-0.5">AED {p.price?.toLocaleString()}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  const actions = [
    { icon: ShoppingBag, label: 'Add to bag', onClick: () => setView('shopping-list'), accent: true },
    { icon: RotateCw, label: `${rotationDeg}°`, onClick: handleRotate },
    { icon: ArrowLeftRight, label: 'Replace', onClick: handleReplace },
    { icon: Copy, label: 'Copy', onClick: handleCopy },
    { icon: Trash2, label: 'Remove', onClick: handleRemove, danger: true },
  ];

  return (
    <div
      className="absolute bottom-14 left-1/2 -translate-x-1/2 z-20"
      onPointerDown={(e) => e.stopPropagation()}
      onMouseDown={(e) => e.stopPropagation()}
      onClick={(e) => e.stopPropagation()}
    >
      <div className="flex items-stretch bg-gray-900 rounded-2xl shadow-2xl overflow-hidden">
        {actions.map((action, idx) => (
          <div key={action.label} className="flex items-stretch">
            {idx > 0 && <div className="w-px bg-gray-700 my-2" />}
            <button
              onClick={action.onClick}
              className={`flex flex-col items-center justify-center gap-1 px-4 py-2 transition-colors ${
                action.danger
                  ? 'hover:bg-red-900/50 text-red-400'
                  : action.accent
                    ? 'hover:bg-emerald-900/40 text-emerald-400'
                    : 'hover:bg-gray-800 text-white'
              }`}
            >
              <action.icon size={16} />
              <span className="text-[9px] font-medium whitespace-nowrap">{action.label}</span>
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
