import { useState } from 'react';
import type { ShowroomTemplate } from '../../store/types';

interface ShowroomCardProps {
  showroom: ShowroomTemplate;
  onSelect: (showroom: ShowroomTemplate) => void;
}

const furnishingColors: Record<string, { bg: string; text: string }> = {
  EMPTY: { bg: 'bg-gray-100 dark:bg-gray-700', text: 'text-gray-600 dark:text-gray-300' },
  SEMI_FURNISHED: { bg: 'bg-amber-50 dark:bg-amber-900/30', text: 'text-amber-700 dark:text-amber-300' },
  FULLY_FURNISHED: { bg: 'bg-emerald-50 dark:bg-emerald-900/30', text: 'text-emerald-700 dark:text-emerald-300' },
};

function formatFurnishing(level: string): string {
  switch (level) {
    case 'EMPTY': return 'Empty';
    case 'SEMI_FURNISHED': return 'Semi-Furnished';
    case 'FULLY_FURNISHED': return 'Fully Furnished';
    default: return level;
  }
}

export default function ShowroomCard({ showroom, onSelect }: ShowroomCardProps) {
  const furnishing = furnishingColors[showroom.furnishingLevel] ?? furnishingColors.EMPTY;
  const [imgError, setImgError] = useState(false);

  const roomIcons: Record<string, string> = {
    LIVING_ROOM: '🛋️', BEDROOM: '🛏️', KITCHEN: '🍳', BATHROOM: '🛁', OFFICE: '💻', DINING_ROOM: '🍽️',
  };

  return (
    <button
      onClick={() => onSelect(showroom)}
      className="group relative flex flex-col overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm hover:shadow-md transition-all duration-200 hover:-translate-y-0.5 text-left w-full"
    >
      {/* Thumbnail */}
      <div className="relative aspect-[4/3] w-full overflow-hidden">
        {showroom.thumbnailUrl && !imgError ? (
          <img
            src={showroom.thumbnailUrl}
            alt={showroom.name}
            onError={() => setImgError(true)}
            className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
          />
        ) : (
          <div className="h-full w-full bg-gradient-to-br from-[#144525] to-[#0E552B] flex flex-col items-center justify-center gap-1">
            <span className="text-4xl">{roomIcons[showroom.roomType] || '🏠'}</span>
            <span className="text-white/70 text-xs font-medium">{showroom.style}</span>
          </div>
        )}
      </div>

      {/* Info */}
      <div className="flex flex-col gap-2 p-3">
        <h4 className="text-sm font-semibold text-gray-900 dark:text-gray-100 leading-tight truncate">
          {showroom.name}
        </h4>

        <div className="flex flex-wrap gap-1.5">
          {/* Style badge */}
          <span className="inline-flex items-center rounded-full bg-[#C2A563]/15 px-2 py-0.5 text-xs font-medium text-[#C2A563]">
            {showroom.style}
          </span>

          {/* Furnishing level badge */}
          <span
            className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${furnishing.bg} ${furnishing.text}`}
          >
            {formatFurnishing(showroom.furnishingLevel)}
          </span>
        </div>
      </div>
    </button>
  );
}
