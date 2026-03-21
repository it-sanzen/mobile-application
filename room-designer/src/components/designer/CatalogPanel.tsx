import { useEffect, useCallback } from 'react';
import { Search, ChevronDown } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import ProductCard from './ProductCard';
import LoadingSpinner from '../shared/LoadingSpinner';

const CATEGORY_LABELS: Record<string, string> = {
  All: 'All categories',
  SOFA: 'Sofas',
  BED: 'Beds',
  TABLE: 'Tables',
  CHAIR: 'Chairs',
  STORAGE: 'Storage',
  LIGHTING: 'Lighting',
  RUG: 'Rugs',
  DECOR: 'Decor',
  PLANT: 'Plants',
  KITCHEN_FIXTURE: 'Kitchen Fixtures',
  BATHROOM_FIXTURE: 'Bathroom Fixtures',
};

function formatCategoryLabel(cat: string): string {
  return CATEGORY_LABELS[cat] || cat.charAt(0) + cat.slice(1).toLowerCase().replace(/_/g, ' ');
}

export default function CatalogPanel() {
  const products = useDesignerStore((s) => s.products);
  const categories = useDesignerStore((s) => s.categories);
  const selectedCategory = useDesignerStore((s) => s.selectedCategory);
  const searchQuery = useDesignerStore((s) => s.searchQuery);
  const productsLoading = useDesignerStore((s) => s.productsLoading);
  const setSelectedCategory = useDesignerStore((s) => s.setSelectedCategory);
  const setSearchQuery = useDesignerStore((s) => s.setSearchQuery);
  const loadProducts = useDesignerStore((s) => s.loadProducts);
  const searchProductsFn = useDesignerStore((s) => s.searchProducts);
  const addItem = useDesignerStore((s) => s.addItem);

  // Products are loaded by selectShowroom with roomTag — only load if empty
  useEffect(() => {
    if (products.length === 0 && !productsLoading) {
      loadProducts();
    }
  }, []);

  const handleSearch = useCallback(
    (value: string) => {
      setSearchQuery(value);
      if (value.trim().length > 1) {
        searchProductsFn(value.trim());
      } else if (value.trim().length === 0) {
        loadProducts();
      }
    },
    [setSearchQuery, searchProductsFn, loadProducts]
  );

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Header */}
      <div className="px-4 pt-4 pb-1 shrink-0">
        <h2 className="text-sm font-bold text-gray-900 tracking-tight">Furniture Catalog</h2>
        <p className="text-[11px] text-gray-400 mt-0.5">
          {products.length} product{products.length !== 1 ? 's' : ''}
        </p>
      </div>

      {/* Search input */}
      <div className="px-4 pt-2 pb-2 shrink-0">
        <div className="relative">
          <Search
            size={16}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
          />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => handleSearch(e.target.value)}
            placeholder="Search furniture..."
            className="w-full pl-9 pr-3 py-2.5 text-sm bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-900/10 focus:border-gray-400 transition-colors placeholder:text-gray-400"
          />
        </div>
      </div>

      {/* Category dropdown */}
      <div className="px-4 pb-3 shrink-0">
        <div className="relative">
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="w-full appearance-none px-3 py-2 pr-8 text-sm font-medium text-gray-800 bg-gray-50 border border-gray-200 rounded-xl cursor-pointer focus:outline-none focus:ring-2 focus:ring-gray-900/10 focus:border-gray-400 transition-colors"
          >
            {categories.map((cat) => (
              <option key={cat} value={cat}>
                {formatCategoryLabel(cat)}
              </option>
            ))}
          </select>
          <ChevronDown
            size={16}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"
          />
        </div>
      </div>

      {/* Product grid */}
      <div className="flex-1 overflow-y-auto px-4 pb-4">
        {productsLoading ? (
          <div className="flex items-center justify-center h-32">
            <LoadingSpinner size={28} />
          </div>
        ) : products.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-32 text-gray-400">
            <p className="text-sm">No furniture found</p>
            <p className="text-xs mt-1">Try a different search or category</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {products.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                onAdd={addItem}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
