import { create } from 'zustand';
import type { FurnitureProduct, PlacedItem, ShowroomTemplate, WishlistPreview } from './types';
import * as api from '../services/api';
import { roomBounds } from '../components/scene/GLBRoom';

export type AppView = 'showroom-picker' | 'designer' | 'shopping-list';

interface UndoEntry {
  placedItems: PlacedItem[];
  selectedItemId: string | null;
}

interface DesignerState {
  // View
  view: AppView;
  setView: (view: AppView) => void;

  // Initialization
  isLoading: boolean;
  _initialized: boolean;
  _initializing: boolean;
  initialize: () => Promise<void>;

  // Showrooms
  showrooms: ShowroomTemplate[];
  selectedShowroom: ShowroomTemplate | null;
  loadShowrooms: (roomType?: string) => Promise<void>;
  selectShowroom: (showroom: ShowroomTemplate) => Promise<void>;

  // Design metadata
  designId: string | null;
  designName: string;
  setDesignName: (name: string) => void;

  // Products / catalog
  products: FurnitureProduct[];
  categories: string[];
  selectedCategory: string;
  searchQuery: string;
  roomTag: string;
  productsLoading: boolean;
  setSelectedCategory: (cat: string) => void;
  setSearchQuery: (q: string) => void;
  loadProducts: (roomTag?: string) => Promise<void>;
  searchProducts: (q: string) => Promise<void>;

  // Baked-in furniture selection (furniture that's part of the GLB room model)
  selectedBakedObject: {
    object: any; // THREE.Object3D reference
    position: [number, number, number];
    name: string;
  } | null;
  selectBakedObject: (obj: { object: any; position: [number, number, number]; name: string } | null) => void;
  removeBakedObject: () => void;

  // Callback set by GLBRoom to handle hiding baked objects (has THREE.js access)
  _onRemoveBaked: ((obj: any) => void) | null;
  _setOnRemoveBaked: (fn: ((obj: any) => void) | null) => void;

  // Track hidden baked object names so they stay hidden across re-renders
  hiddenBakedNames: Set<string>;
  _addHiddenBakedName: (name: string) => void;

  // Replacement position (set when user clicks baked-in furniture to hide it)
  pendingReplacementPosition: [number, number, number] | null;
  setPendingReplacementPosition: (pos: [number, number, number] | null) => void;

  // Placed items in scene
  placedItems: PlacedItem[];
  selectedItemId: string | null;
  selectItem: (id: string | null) => void;
  addItem: (product: FurnitureProduct) => void;
  removeItem: (instanceId: string) => void;
  duplicateItem: (instanceId: string) => void;
  updateItemTransform: (
    instanceId: string,
    updates: Partial<Pick<PlacedItem, 'position' | 'rotation' | 'scale'>>
  ) => void;

  // Undo / Redo
  undoStack: UndoEntry[];
  redoStack: UndoEntry[];
  undo: () => void;
  redo: () => void;

  // Save
  saving: boolean;
  saveDesign: () => Promise<void>;

  // Wishlist
  wishlist: WishlistPreview | null;
  wishlistLoading: boolean;
  loadWishlist: () => Promise<void>;
  saveWishlist: () => Promise<void>;
}

let nextInstanceId = 1;

function pushUndo(state: DesignerState): Partial<DesignerState> {
  return {
    undoStack: [
      ...state.undoStack,
      {
        placedItems: state.placedItems.map((i) => ({ ...i })),
        selectedItemId: state.selectedItemId,
      },
    ],
    redoStack: [],
  };
}

export const useDesignerStore = create<DesignerState>((set, get) => ({
  // View
  view: 'showroom-picker' as AppView,
  setView: (view) => set({ view }),

  // Initialization
  isLoading: true,
  _initialized: false,
  _initializing: false,
  initialize: async () => {
    // Guard against double-initialization (React StrictMode calls useEffect twice)
    if (get()._initializing || get()._initialized) return;
    set({ _initializing: true, isLoading: true });
    const params = new URLSearchParams(window.location.search);
    const designId = params.get('designId');
    const roomType = params.get('roomType');

    // Set token from URL if provided (from Flutter WebView)
    const urlToken = params.get('token');
    if (urlToken) {
      api.setToken(urlToken);
    } else {
      // Auto-login for dev testing
      const token = await api.devAutoLogin();
      if (!token) {
        console.error('No token and auto-login failed');
        set({ isLoading: false, _initializing: false });
        return;
      }
    }

    if (designId) {
      // Load existing design
      try {
        const design = await api.getDesign(designId);
        const d = design as any;
        const showroom = await api.getShowroom(d.showroomId);
        const products = await api.getProducts();
        const productMap = new Map((products as FurnitureProduct[]).map(p => [p.id, p]));
        const placedItems: PlacedItem[] = (d.items || []).map((item: any, i: number) => ({
          instanceId: `item-${i + 1}`,
          productId: item.productId,
          product: productMap.get(item.productId) || item.product,
          position: [item.positionX, item.positionY, item.positionZ] as [number, number, number],
          rotation: [item.rotationX, item.rotationY, item.rotationZ] as [number, number, number],
          scale: [item.scaleX, item.scaleY, item.scaleZ] as [number, number, number],
          colorOption: item.colorOption,
        }));
        nextInstanceId = placedItems.length + 1;
        console.log('[Init] Design loaded:', d.name, 'showroom:', (showroom as any).name);
        set({
          designId,
          designName: d.name || 'My Design',
          selectedShowroom: showroom as ShowroomTemplate,
          placedItems,
          view: 'designer',
          isLoading: false,
          _initialized: true,
          _initializing: false,
        });
        get().loadProducts();
      } catch (e) {
        console.error('Failed to load design', e);
        set({ isLoading: false, _initializing: false });
      }
    } else {
      // Auto-select first showroom for the room type and go straight to designer
      try {
        const rt = roomType || 'LIVING_ROOM';
        const showrooms = await api.getShowrooms({ roomType: rt });
        const allShowrooms = showrooms as ShowroomTemplate[];
        if (allShowrooms.length > 0) {
          // Directly enter designer with first showroom
          await get().selectShowroom(allShowrooms[0]);
          set({ _initialized: true, _initializing: false });
        } else {
          // Fallback: load all showrooms and show picker
          await get().loadShowrooms();
          set({ isLoading: false, _initializing: false });
        }
      } catch (e) {
        console.error('Failed to auto-select room', e);
        await get().loadShowrooms();
        set({ isLoading: false, _initializing: false });
      }
    }
  },

  // Showrooms
  showrooms: [],
  selectedShowroom: null,
  loadShowrooms: async (roomType?) => {
    try {
      const filters = roomType ? { roomType } : undefined;
      const data = await api.getShowrooms(filters);
      set({ showrooms: data as ShowroomTemplate[] });
    } catch (e) {
      console.error('Failed to load showrooms', e);
    }
  },
  selectShowroom: async (showroom) => {
    set({ isLoading: true, selectedShowroom: showroom });
    try {
      const design = await api.createDesign(showroom.id, `My ${showroom.name}`);
      const d = design as any;
      set({
        designId: d.id,
        designName: d.name,
        view: 'designer',
        isLoading: false,
      });
      // Load products filtered by room type tag
      const roomTag = showroom.roomType?.toLowerCase().replace('_', '_') || '';
      get().loadProducts(roomTag);
    } catch (e) {
      console.error('Failed to create design', e);
      set({ isLoading: false });
    }
  },

  // Design metadata
  designId: null,
  designName: 'Untitled Design',
  setDesignName: (name) => set({ designName: name }),

  // Products
  products: [],
  categories: ['All'],
  selectedCategory: 'All',
  searchQuery: '',
  productsLoading: false,
  setSelectedCategory: (cat) => {
    set({ selectedCategory: cat });
    const state = get();
    if (cat === 'All') {
      state.loadProducts();
    } else {
      const filters: Record<string, string> = { category: cat };
      if (state.roomTag) filters.tag = state.roomTag;
      api
        .getProducts(filters)
        .then((products) => set({ products: products as FurnitureProduct[] }))
        .catch(console.error);
    }
  },
  roomTag: '',
  setSearchQuery: (q) => set({ searchQuery: q }),
  loadProducts: async (roomTag?: string) => {
    set({ productsLoading: true });
    if (roomTag) set({ roomTag });
    try {
      const tag = roomTag || get().roomTag;
      const filters: Record<string, string> = {};
      if (tag) filters.tag = tag;

      const [products, categories] = await Promise.all([
        api.getProducts(Object.keys(filters).length > 0 ? filters : undefined),
        api.getProductCategories(),
      ]);
      set({
        products: products as FurnitureProduct[],
        categories: ['All', ...(categories as any[]).map((c: any) => typeof c === 'string' ? c : c.category)],
        productsLoading: false,
      });
    } catch (e) {
      console.error('Failed to load products', e);
      set({ productsLoading: false });
    }
  },
  searchProducts: async (q) => {
    set({ productsLoading: true, searchQuery: q });
    try {
      const products = await api.searchProducts(q);
      set({ products: products as FurnitureProduct[], productsLoading: false });
    } catch (e) {
      console.error('Search failed', e);
      set({ productsLoading: false });
    }
  },

  // Baked-in furniture selection
  selectedBakedObject: null,
  selectBakedObject: (obj) => set({ selectedBakedObject: obj, selectedItemId: obj ? null : get().selectedItemId }),
  removeBakedObject: () => {
    const state = get();
    if (state.selectedBakedObject) {
      const obj = state.selectedBakedObject.object;
      // Hide the object — the actual hiding + sibling cleanup is done via
      // the onRemoveBaked callback set by GLBRoom (which has THREE access)
      if (state._onRemoveBaked) {
        state._onRemoveBaked(obj);
      } else {
        // Fallback: just hide the object directly
        obj.visible = false;
        obj.traverse((child: any) => { child.visible = false; });
      }
      set({
        pendingReplacementPosition: state.selectedBakedObject.position,
        selectedBakedObject: null,
      });
    }
  },

  // Baked removal callback (set by GLBRoom)
  _onRemoveBaked: null,
  _setOnRemoveBaked: (fn) => set({ _onRemoveBaked: fn }),

  // Track hidden baked object names
  hiddenBakedNames: new Set<string>(),
  _addHiddenBakedName: (name: string) => {
    const s = new Set(get().hiddenBakedNames);
    s.add(name);
    set({ hiddenBakedNames: s });
  },

  // Replacement position
  pendingReplacementPosition: null,
  setPendingReplacementPosition: (pos) => set({ pendingReplacementPosition: pos }),

  // Placed items
  placedItems: [],
  selectedItemId: null,
  selectItem: (id) => set({ selectedItemId: id, selectedBakedObject: id ? null : get().selectedBakedObject }),
  addItem: (product) => {
    const state = get();
    const instanceId = `item-${nextInstanceId++}`;
    // Use pending replacement position if available, otherwise room center
    const pos: [number, number, number] = state.pendingReplacementPosition
      ? state.pendingReplacementPosition
      : [
          roomBounds.centerX + (Math.random() - 0.5) * 0.5,
          roomBounds.floorY,
          roomBounds.centerZ + (Math.random() - 0.5) * 0.5,
        ];
    const newItem: PlacedItem = {
      instanceId,
      productId: product.id,
      product,
      position: pos,
      rotation: [0, 0, 0],
      scale: [1, 1, 1],
    };
    set({
      ...pushUndo(state),
      placedItems: [...state.placedItems, newItem],
      selectedItemId: instanceId,
      pendingReplacementPosition: null, // Consume the position
    });
  },
  removeItem: (instanceId) => {
    const state = get();
    set({
      ...pushUndo(state),
      placedItems: state.placedItems.filter((i) => i.instanceId !== instanceId),
      selectedItemId:
        state.selectedItemId === instanceId ? null : state.selectedItemId,
    });
  },
  duplicateItem: (instanceId) => {
    const state = get();
    const item = state.placedItems.find((i) => i.instanceId === instanceId);
    if (!item) return;
    const newId = `item-${nextInstanceId++}`;
    const dup: PlacedItem = {
      ...item,
      instanceId: newId,
      position: [item.position[0] + 0.5, item.position[1], item.position[2] + 0.5],
    };
    set({
      ...pushUndo(state),
      placedItems: [...state.placedItems, dup],
      selectedItemId: newId,
    });
  },
  updateItemTransform: (instanceId, updates) => {
    const state = get();
    set({
      placedItems: state.placedItems.map((i) =>
        i.instanceId === instanceId
          ? {
              ...i,
              ...(updates.position !== undefined && { position: updates.position }),
              ...(updates.rotation !== undefined && { rotation: updates.rotation }),
              ...(updates.scale !== undefined && { scale: updates.scale }),
            }
          : i
      ),
    });
  },

  // Undo / Redo
  undoStack: [],
  redoStack: [],
  undo: () => {
    const state = get();
    if (state.undoStack.length === 0) return;
    const prev = state.undoStack[state.undoStack.length - 1];
    set({
      undoStack: state.undoStack.slice(0, -1),
      redoStack: [
        ...state.redoStack,
        {
          placedItems: state.placedItems.map((i) => ({ ...i })),
          selectedItemId: state.selectedItemId,
        },
      ],
      placedItems: prev.placedItems,
      selectedItemId: prev.selectedItemId,
    });
  },
  redo: () => {
    const state = get();
    if (state.redoStack.length === 0) return;
    const next = state.redoStack[state.redoStack.length - 1];
    set({
      redoStack: state.redoStack.slice(0, -1),
      undoStack: [
        ...state.undoStack,
        {
          placedItems: state.placedItems.map((i) => ({ ...i })),
          selectedItemId: state.selectedItemId,
        },
      ],
      placedItems: next.placedItems,
      selectedItemId: next.selectedItemId,
    });
  },

  // Save
  saving: false,
  saveDesign: async () => {
    const state = get();
    if (!state.designId) return;
    set({ saving: true });
    try {
      const itemsData = state.placedItems.map((i) => ({
        productId: i.productId,
        positionX: i.position[0],
        positionY: i.position[1],
        positionZ: i.position[2],
        rotationX: i.rotation[0],
        rotationY: i.rotation[1],
        rotationZ: i.rotation[2],
        scaleX: i.scale[0],
        scaleY: i.scale[1],
        scaleZ: i.scale[2],
        colorOption: i.colorOption,
      }));
      await api.saveDesignItems(state.designId, itemsData);
    } catch (e) {
      console.error('Save failed', e);
    } finally {
      set({ saving: false });
    }
  },

  // Wishlist
  wishlist: null,
  wishlistLoading: false,
  loadWishlist: async () => {
    const state = get();
    if (!state.designId) {
      // Build local wishlist from placed items
      const itemMap = new Map<string, { product: FurnitureProduct; quantity: number }>();
      for (const placed of state.placedItems) {
        const existing = itemMap.get(placed.productId);
        if (existing) {
          existing.quantity++;
        } else {
          itemMap.set(placed.productId, { product: placed.product, quantity: 1 });
        }
      }
      const items = Array.from(itemMap.values()).map((entry) => ({
        productId: entry.product.id,
        product: entry.product,
        quantity: entry.quantity,
      }));
      const totalCost = items.reduce(
        (sum, i) => sum + i.product.price * i.quantity,
        0
      );
      set({
        wishlist: { items, totalItems: items.length, totalCost },
      });
      return;
    }
    set({ wishlistLoading: true });
    try {
      const data = await api.getWishlistPreview(state.designId);
      set({ wishlist: data as WishlistPreview, wishlistLoading: false });
    } catch (e) {
      console.error('Failed to load wishlist', e);
      set({ wishlistLoading: false });
    }
  },
  saveWishlist: async () => {
    const state = get();
    if (!state.designId) return;
    try {
      await api.saveWishlist(state.designId);
    } catch (e) {
      console.error('Failed to save wishlist', e);
    }
  },
}));
