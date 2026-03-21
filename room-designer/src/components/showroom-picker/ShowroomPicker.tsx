import { useEffect, useMemo } from 'react';
import { Loader2, Sofa, Bed, ChefHat, Bath, Monitor, UtensilsCrossed } from 'lucide-react';
import { useDesignerStore } from '../../store/designerStore';
import type { ShowroomTemplate } from '../../store/types';

const ROOM_CONFIG: Record<string, { icon: typeof Sofa; gradient: string }> = {
  BATHROOM: { icon: Bath, gradient: 'from-[#1a3a4a] to-[#2a5a6a]' },
  BEDROOM: { icon: Bed, gradient: 'from-[#3a1a5a] to-[#5a2a7a]' },
  DINING_ROOM: { icon: UtensilsCrossed, gradient: 'from-[#5a4a1a] to-[#7a6a2a]' },
  KITCHEN: { icon: ChefHat, gradient: 'from-[#6a3a1a] to-[#8a5a2a]' },
  LIVING_ROOM: { icon: Sofa, gradient: 'from-[#144525] to-[#1a6a35]' },
  OFFICE: { icon: Monitor, gradient: 'from-[#3a3a3a] to-[#5a5a5a]' },
};

function formatRoomType(type: string): string {
  return type.split('_').map(w => w.charAt(0) + w.slice(1).toLowerCase()).join(' ');
}

export default function ShowroomPicker() {
  const showrooms = useDesignerStore((s) => s.showrooms);
  const loadShowrooms = useDesignerStore((s) => s.loadShowrooms);
  const selectShowroom = useDesignerStore((s) => s.selectShowroom);
  const isLoading = useDesignerStore((s) => s.isLoading);

  useEffect(() => {
    loadShowrooms();
  }, [loadShowrooms]);

  const categories = useMemo(() => {
    const grouped = new Map<string, ShowroomTemplate[]>();
    for (const s of showrooms) {
      const list = grouped.get(s.roomType) ?? [];
      list.push(s);
      grouped.set(s.roomType, list);
    }
    // For demo: only show Living Room
    return Array.from(grouped.entries())
      .filter(([type]) => type === 'LIVING_ROOM')
      .sort(([a], [b]) => a.localeCompare(b));
  }, [showrooms]);

  // Click a room → directly enter designer with first showroom of that type
  function handleRoomClick(items: ShowroomTemplate[]) {
    if (items.length > 0) {
      selectShowroom(items[0]);
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="mx-auto w-full max-w-5xl px-4 py-10 sm:px-6">
        <div className="mb-10 text-center">
          <h1 className="text-4xl font-bold tracking-tight text-gray-900">
            Choose a Room
          </h1>
          <p className="mt-3 text-gray-500">
            Select a room to start designing your space
          </p>
        </div>

        {isLoading && (
          <div className="flex flex-col items-center justify-center py-20">
            <Loader2 className="h-8 w-8 animate-spin text-[#144525]" />
            <p className="mt-3 text-sm text-gray-400">Loading rooms...</p>
          </div>
        )}

        {!isLoading && categories.length > 0 && (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {categories.map(([roomType, items]) => {
              const config = ROOM_CONFIG[roomType] || ROOM_CONFIG.LIVING_ROOM;
              const Icon = config.icon;
              return (
                <button
                  key={roomType}
                  onClick={() => handleRoomClick(items)}
                  className={`relative overflow-hidden rounded-2xl bg-gradient-to-br ${config.gradient} p-6 text-left text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-[1.02] active:scale-[0.98] min-h-[140px] flex flex-col justify-between`}
                >
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="text-xl font-bold">{formatRoomType(roomType)}</h3>
                      <p className="mt-1 text-sm text-white/70">Tap to start designing</p>
                    </div>
                    <div className="w-12 h-12 rounded-xl bg-white/15 flex items-center justify-center">
                      <Icon size={24} />
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
