import { ArrowLeft, Save, Loader2, ShoppingCart, Undo2, Redo2 } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import { notifyBackPressed } from '../../services/flutter-bridge';

export default function TopBar() {
  const designName = useDesignerStore((s) => s.designName);
  const saving = useDesignerStore((s) => s.saving);
  const saveDesign = useDesignerStore((s) => s.saveDesign);
  const placedItems = useDesignerStore((s) => s.placedItems);
  const setView = useDesignerStore((s) => s.setView);
  const undoStack = useDesignerStore((s) => s.undoStack);
  const redoStack = useDesignerStore((s) => s.redoStack);
  const undo = useDesignerStore((s) => s.undo);
  const redo = useDesignerStore((s) => s.redo);

  // Calculate total from all placed items: sum of each product's price
  const totalCost = placedItems.reduce(
    (sum, item) => sum + (item.product.price ?? 0),
    0
  );
  const itemCount = placedItems.length;

  return (
    <div className="flex items-center h-12 px-3 bg-white border-b border-gray-200 shrink-0">
      {/* Left section */}
      <div className="flex items-center gap-2 min-w-0 flex-1">
        <button
          onClick={notifyBackPressed}
          className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors shrink-0"
          title="Back"
        >
          <ArrowLeft size={20} className="text-gray-700" />
        </button>

        <span className="text-sm font-medium text-gray-800 truncate">
          {designName || 'Untitled Design'}
        </span>
      </div>

      {/* Center section - undo/redo */}
      <div className="flex items-center gap-1">
        <button
          onClick={undo}
          disabled={undoStack.length === 0}
          className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
          title="Undo"
        >
          <Undo2 size={16} className="text-gray-600" />
        </button>
        <button
          onClick={redo}
          disabled={redoStack.length === 0}
          className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
          title="Redo"
        >
          <Redo2 size={16} className="text-gray-600" />
        </button>
      </div>

      {/* Right section */}
      <div className="flex items-center gap-2.5 shrink-0 ml-3">
        {/* Item count + total */}
        {itemCount > 0 && (
          <span className="text-sm font-semibold text-gray-800 hidden sm:inline">
            {itemCount} item{itemCount !== 1 ? 's' : ''} &middot; AED{' '}
            {totalCost.toLocaleString(undefined, {
              minimumFractionDigits: 0,
              maximumFractionDigits: 0,
            })}
          </span>
        )}

        {/* Save */}
        <button
          onClick={saveDesign}
          disabled={saving}
          className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-50"
          title="Save design"
        >
          {saving ? (
            <Loader2 size={18} className="animate-spin text-gray-500" />
          ) : (
            <Save size={18} className="text-gray-600" />
          )}
        </button>

        {/* Shopping list / Summary */}
        <button
          onClick={() => setView('shopping-list')}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-gray-900 text-white text-xs font-medium hover:bg-gray-800 transition-colors"
          title="Shopping list"
        >
          <ShoppingCart size={14} />
          <span className="hidden sm:inline">Summary</span>
          {itemCount > 0 && (
            <span className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-white/20 text-[10px] font-bold">
              {itemCount}
            </span>
          )}
        </button>
      </div>
    </div>
  );
}
