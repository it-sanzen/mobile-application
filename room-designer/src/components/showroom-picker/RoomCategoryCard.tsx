import {
  Sofa,
  Bed,
  ChefHat,
  Bath,
  Monitor,
  UtensilsCrossed,
  ChevronDown,
  type LucideIcon,
} from 'lucide-react';
import type { ShowroomTemplate } from '../../store/types';
import ShowroomCard from './ShowroomCard';

interface RoomCategoryCardProps {
  roomType: string;
  count: number;
  isExpanded: boolean;
  onTap: () => void;
  showrooms: ShowroomTemplate[];
  onSelectShowroom: (showroom: ShowroomTemplate) => void;
}

const categoryMeta: Record<string, { icon: LucideIcon; gradient: string }> = {
  LIVING_ROOM: {
    icon: Sofa,
    gradient: 'from-[#144525] to-[#1e6b3a]',
  },
  BEDROOM: {
    icon: Bed,
    gradient: 'from-[#2d1b4e] to-[#4a2d7a]',
  },
  KITCHEN: {
    icon: ChefHat,
    gradient: 'from-[#7a3b1e] to-[#a85d3a]',
  },
  BATHROOM: {
    icon: Bath,
    gradient: 'from-[#1b3a4e] to-[#2d5f7a]',
  },
  OFFICE: {
    icon: Monitor,
    gradient: 'from-[#3a3a3a] to-[#5a5a5a]',
  },
  DINING_ROOM: {
    icon: UtensilsCrossed,
    gradient: 'from-[#4e3b1b] to-[#7a5d2d]',
  },
};

function formatRoomType(type: string): string {
  return type
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

export default function RoomCategoryCard({
  roomType,
  count,
  isExpanded,
  onTap,
  showrooms,
  onSelectShowroom,
}: RoomCategoryCardProps) {
  const meta = categoryMeta[roomType] ?? {
    icon: Sofa,
    gradient: 'from-[#144525] to-[#1e6b3a]',
  };
  const Icon = meta.icon;

  return (
    <div className="flex flex-col">
      {/* Category header card */}
      <button
        onClick={onTap}
        className={`
          relative flex items-center gap-4 rounded-2xl p-5
          bg-gradient-to-br ${meta.gradient}
          text-white shadow-md hover:shadow-lg
          transition-all duration-200 hover:-translate-y-0.5
          w-full text-left cursor-pointer
          ${isExpanded ? 'rounded-b-none' : ''}
        `}
      >
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white/15 backdrop-blur-sm">
          <Icon className="h-6 w-6" />
        </div>

        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold leading-tight">
            {formatRoomType(roomType)}
          </h3>
          <p className="mt-0.5 text-sm text-white/70">
            {count} {count === 1 ? 'style' : 'styles'} available
          </p>
        </div>

        <ChevronDown
          className={`h-5 w-5 shrink-0 text-white/60 transition-transform duration-200 ${
            isExpanded ? 'rotate-180' : ''
          }`}
        />
      </button>

      {/* Expanded showroom grid */}
      {isExpanded && (
        <div className="rounded-b-2xl border border-t-0 border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900 p-4">
          {showrooms.length === 0 ? (
            <p className="py-6 text-center text-sm text-gray-400">
              No showrooms available for this room type.
            </p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {showrooms.map((showroom) => (
                <ShowroomCard
                  key={showroom.id}
                  showroom={showroom}
                  onSelect={onSelectShowroom}
                />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
