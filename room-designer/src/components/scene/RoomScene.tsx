import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment } from '@react-three/drei';
import { useDesignerStore } from '../../store/designerStore';
import FurnitureModel from './FurnitureModel';
import ProceduralRoom from './ProceduralRoom';
import GLBRoom, { roomBounds } from './GLBRoom';
import { useCallback, useRef, useState } from 'react';
import { Box, ArrowUpFromLine, Columns3, ChevronDown } from 'lucide-react';
import type { OrbitControls as OrbitControlsImpl } from 'three-stdlib';
import * as THREE from 'three';

const ROOM_DIMS = { width: 6, depth: 5, height: 3 };

export type ViewMode = 'dollhouse' | 'top' | 'front' | 'back' | 'left' | 'right';

function SceneContent({ viewMode }: { viewMode: ViewMode }) {
  const placedItems = useDesignerStore((s) => s.placedItems);
  const selectedItemId = useDesignerStore((s) => s.selectedItemId);
  const selectItem = useDesignerStore((s) => s.selectItem);
  const updateItemTransform = useDesignerStore((s) => s.updateItemTransform);
  const selectedShowroom = useDesignerStore((s) => s.selectedShowroom);
  const controlsRef = useRef<OrbitControlsImpl>(null);

  const dims = ROOM_DIMS;
  const roomModelUrl = selectedShowroom?.modelUrl || null;

  const selectBakedObject = useDesignerStore((s) => s.selectBakedObject);

  const handlePositionChange = useCallback(
    (instanceId: string, position: [number, number, number]) => {
      updateItemTransform(instanceId, { position });
    },
    [updateItemTransform]
  );

  const handleMissedClick = useCallback(() => {
    selectItem(null);
    selectBakedObject(null);
  }, [selectItem, selectBakedObject]);

  // Compute camera constraints based on view mode
  const getControlsProps = () => {
    const base = {
      makeDefault: true,
      enableDamping: true,
      dampingFactor: 0.1,
      minDistance: 1.5,
      maxDistance: 15,
    };

    // Look at floor center of the room
    const lookAt: [number, number, number] = [0, 0.3, 0];

    switch (viewMode) {
      case 'top':
        return {
          ...base,
          target: [0, 0, 0] as [number, number, number],
          minPolarAngle: 0,
          maxPolarAngle: 0.01,
          enableRotate: false,
        };
      case 'front':
      case 'back':
      case 'left':
      case 'right':
        return {
          ...base,
          target: [0, dims.height * 0.4, 0] as [number, number, number],
          enableRotate: false,
        };
      case 'dollhouse':
      default:
        return {
          ...base,
          target: lookAt,
          maxPolarAngle: Math.PI / 2.5,
          minPolarAngle: 0.3,
        };
    }
  };

  const controlsProps = getControlsProps();

  return (
    <>
      {/* Lighting */}
      <ambientLight intensity={0.5} />
      <directionalLight
        position={[8, 12, 8]}
        intensity={1.2}
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
        shadow-camera-far={50}
        shadow-camera-left={-10}
        shadow-camera-right={10}
        shadow-camera-top={10}
        shadow-camera-bottom={-10}
      />
      <directionalLight position={[-4, 8, -4]} intensity={0.3} />
      <hemisphereLight args={['#f0ece6', '#c4a882', 0.3]} />

      {/* Environment for reflections */}
      <Environment preset="apartment" />

      {/* Room - GLB model if available, otherwise procedural */}
      {roomModelUrl ? (
        <>
          <GLBRoom url={roomModelUrl} />
          {/* Invisible floor plane for drag raycasting at floor level */}
          <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, roomBounds.floorY, 0]}>
            <planeGeometry args={[30, 30]} />
            <meshStandardMaterial visible={false} />
          </mesh>
        </>
      ) : (
        <ProceduralRoom
          width={dims.width}
          depth={dims.depth}
          height={dims.height}
          roomType="LIVING_ROOM"
        />
      )}

      {/* Clickable floor for deselect */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, 0.001, 0]}
        onClick={handleMissedClick}
      >
        <planeGeometry args={[dims.width, dims.depth]} />
        <meshStandardMaterial transparent opacity={0} />
      </mesh>

      {/* Camera controls */}
      <OrbitControls
        ref={controlsRef}
        {...controlsProps}
      />

      {/* Placed furniture items */}
      {placedItems.map((item) => (
        <FurnitureModel
          key={item.instanceId}
          item={item}
          isSelected={item.instanceId === selectedItemId}
          onSelect={selectItem}
          onPositionChange={handlePositionChange}
        />
      ))}
    </>
  );
}

function getCameraForView(
  viewMode: ViewMode,
): { position: [number, number, number]; fov: number } {
  const w = ROOM_DIMS.width;
  const h = ROOM_DIMS.height;
  const d = ROOM_DIMS.depth;

  switch (viewMode) {
    case 'dollhouse':
      // IKEA-style: elevated, looking down into the open-front room
      return { position: [0, h * 1.8, d * 1.6], fov: 40 };
    case 'top':
      return { position: [0, Math.max(w, d) * 2, 0.01], fov: 40 };
    case 'front':
      return { position: [0, h * 0.5, d * 1.8], fov: 40 };
    case 'back':
      return { position: [0, h * 0.5, -d * 1.8], fov: 40 };
    case 'left':
      return { position: [-w * 1.8, h * 0.5, 0], fov: 40 };
    case 'right':
      return { position: [w * 1.8, h * 0.5, 0], fov: 40 };
    default:
      return { position: [0, h * 1.8, d * 1.6], fov: 40 };
  }
}

// ViewControls bar at bottom of canvas
function ViewControls({
  viewMode,
  onViewChange,
}: {
  viewMode: ViewMode;
  onViewChange: (mode: ViewMode) => void;
}) {
  const [sideOpen, setSideOpen] = useState(false);

  const sideViews: { label: string; mode: ViewMode }[] = [
    { label: 'Front', mode: 'front' },
    { label: 'Back', mode: 'back' },
    { label: 'Left', mode: 'left' },
    { label: 'Right', mode: 'right' },
  ];

  const isSideView = ['front', 'back', 'left', 'right'].includes(viewMode);
  const currentSideLabel = sideViews.find((v) => v.mode === viewMode)?.label || 'Side';

  return (
    <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-10 flex items-center gap-1 bg-white rounded-full shadow-lg px-1.5 py-1 border border-gray-200">
      {/* Dollhouse */}
      <button
        onClick={() => { onViewChange('dollhouse'); setSideOpen(false); }}
        className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition-colors ${
          viewMode === 'dollhouse'
            ? 'bg-gray-900 text-white'
            : 'text-gray-600 hover:bg-gray-100'
        }`}
      >
        <Box size={14} />
        Dollhouse
      </button>

      {/* Top */}
      <button
        onClick={() => { onViewChange('top'); setSideOpen(false); }}
        className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition-colors ${
          viewMode === 'top'
            ? 'bg-gray-900 text-white'
            : 'text-gray-600 hover:bg-gray-100'
        }`}
      >
        <ArrowUpFromLine size={14} />
        Top view
      </button>

      {/* Side views dropdown */}
      <div className="relative">
        <button
          onClick={() => setSideOpen(!sideOpen)}
          className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition-colors ${
            isSideView
              ? 'bg-gray-900 text-white'
              : 'text-gray-600 hover:bg-gray-100'
          }`}
        >
          <Columns3 size={14} />
          {isSideView ? currentSideLabel : 'Side'}
          <ChevronDown size={12} />
        </button>

        {sideOpen && (
          <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-white rounded-xl shadow-xl border border-gray-200 py-1 min-w-[120px] z-20">
            {sideViews.map((v) => (
              <button
                key={v.mode}
                onClick={() => {
                  onViewChange(v.mode);
                  setSideOpen(false);
                }}
                className={`w-full text-left px-3.5 py-2 text-xs font-medium transition-colors ${
                  viewMode === v.mode
                    ? 'bg-gray-100 text-gray-900'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                {v.label}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default function RoomScene() {
  const [viewMode, setViewMode] = useState<ViewMode>('dollhouse');

  const cam = getCameraForView(viewMode);

  return (
    <div className="w-full h-full relative">
      <Canvas
        key={viewMode}
        shadows
        camera={{ position: cam.position, fov: cam.fov, near: 0.1, far: 100 }}
        style={{ background: '#e8e5e0' }}
        gl={{ antialias: true, toneMapping: THREE.ACESFilmicToneMapping, toneMappingExposure: 1.1 }}
        onPointerMissed={() => {
          useDesignerStore.getState().selectItem(null);
          useDesignerStore.getState().selectBakedObject(null);
        }}
      >
        <SceneContent viewMode={viewMode} />
      </Canvas>

      {/* View controls overlay */}
      <ViewControls viewMode={viewMode} onViewChange={setViewMode} />
    </div>
  );
}
