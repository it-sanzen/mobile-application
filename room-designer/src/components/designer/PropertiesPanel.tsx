import { X, Copy, Trash2 } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import { getCategoryColor } from './ProductCard';

export default function PropertiesPanel() {
  const selectedItemId = useDesignerStore((s) => s.selectedItemId);
  const placedItems = useDesignerStore((s) => s.placedItems);
  const updateItemTransform = useDesignerStore((s) => s.updateItemTransform);
  const duplicateItem = useDesignerStore((s) => s.duplicateItem);
  const removeItem = useDesignerStore((s) => s.removeItem);
  const selectItem = useDesignerStore((s) => s.selectItem);

  const item = placedItems.find((i) => i.instanceId === selectedItemId);
  if (!item) return null;

  const rotationYDeg = Math.round(
    ((item.rotation[1] * 180) / Math.PI + 360) % 360
  );
  const scaleVal = item.scale[0];
  const color = getCategoryColor(item.product.category);

  return (
    <div className="absolute right-0 top-0 bottom-0 w-64 bg-white border-l border-gray-200 shadow-xl z-20 flex flex-col md:relative md:shadow-none">
      {/* Header */}
      <div className="flex items-center justify-between p-3 border-b border-gray-200">
        <span className="text-sm font-semibold text-gray-800">Properties</span>
        <button
          onClick={() => selectItem(null)}
          className="p-1 rounded hover:bg-gray-100 transition-colors"
        >
          <X size={18} className="text-gray-500" />
        </button>
      </div>

      {/* Product info */}
      <div className="p-3 border-b border-gray-200">
        <div className="flex items-center gap-3">
          <div
            className="w-12 h-12 rounded-lg flex items-center justify-center shrink-0"
            style={{ backgroundColor: `${color}20` }}
          >
            {item.product.thumbnailUrl ? (
              <img
                src={item.product.thumbnailUrl}
                alt={item.product.name}
                className="w-full h-full object-cover rounded-lg"
              />
            ) : (
              <div
                className="w-7 h-7 rounded"
                style={{ backgroundColor: color, opacity: 0.6 }}
              />
            )}
          </div>
          <div className="min-w-0">
            <p className="text-sm font-medium text-gray-800 truncate">
              {item.product.name}
            </p>
            <p className="text-xs text-gray-500">{item.product.category}</p>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="flex-1 overflow-y-auto p-3 space-y-4">
        {/* Rotation Y */}
        <div>
          <label className="flex items-center justify-between text-xs font-medium text-gray-600 mb-1.5">
            <span>Rotation Y</span>
            <span className="text-gray-400">{rotationYDeg}°</span>
          </label>
          <input
            type="range"
            min="0"
            max="360"
            value={rotationYDeg}
            onChange={(e) => {
              const deg = Number(e.target.value);
              const rad = (deg * Math.PI) / 180;
              updateItemTransform(item.instanceId, {
                rotation: [item.rotation[0], rad, item.rotation[2]],
              });
            }}
            className="w-full h-1.5 bg-gray-200 rounded-full appearance-none cursor-pointer accent-[#144525]"
          />
        </div>

        {/* Scale */}
        <div>
          <label className="flex items-center justify-between text-xs font-medium text-gray-600 mb-1.5">
            <span>Scale</span>
            <span className="text-gray-400">{scaleVal.toFixed(2)}x</span>
          </label>
          <input
            type="range"
            min="0.5"
            max="2.0"
            step="0.05"
            value={scaleVal}
            onChange={(e) => {
              const s = Number(e.target.value);
              updateItemTransform(item.instanceId, {
                scale: [s, s, s],
              });
            }}
            className="w-full h-1.5 bg-gray-200 rounded-full appearance-none cursor-pointer accent-[#144525]"
          />
        </div>
      </div>

      {/* Actions */}
      <div className="p-3 border-t border-gray-200 space-y-2">
        <button
          onClick={() => duplicateItem(item.instanceId)}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
        >
          <Copy size={16} />
          Duplicate
        </button>
        <button
          onClick={() => removeItem(item.instanceId)}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm font-medium text-red-600 bg-red-50 rounded-lg hover:bg-red-100 transition-colors"
        >
          <Trash2 size={16} />
          Delete
        </button>
      </div>
    </div>
  );
}
