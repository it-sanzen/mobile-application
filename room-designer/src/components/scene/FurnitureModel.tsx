import { useRef, useState, useCallback, Suspense, useMemo } from 'react';
import { useThree, useFrame, type ThreeEvent } from '@react-three/fiber';
import { Html, useGLTF } from '@react-three/drei';
import * as THREE from 'three';
import type { Group } from 'three';
import type { PlacedItem } from '../../store/types';

// GLB furniture model loader — reports actual rendered size via onSize callback
function GLBFurniture({ url, dims, onSize }: {
  url: string;
  dims: { width: number; height: number; depth: number };
  onSize?: (size: { width: number; height: number; depth: number }) => void;
}) {
  const { scene } = useGLTF(url);
  const cloned = useMemo(() => {
    const c = scene.clone(true);
    const box = new THREE.Box3().setFromObject(c);
    const size = new THREE.Vector3();
    box.getSize(size);

    // Scale GLB model to fit within reasonable room proportions
    const maxModelDim = Math.max(size.x, size.y, size.z, 0.01);
    const maxTargetDim = Math.min(Math.max(dims.width, dims.height, dims.depth, 0.3), 0.8);
    const targetScale = maxTargetDim / maxModelDim;
    c.scale.setScalar(targetScale);

    // Re-compute bounds after scaling
    const box2 = new THREE.Box3().setFromObject(c);
    const center2 = new THREE.Vector3();
    box2.getCenter(center2);
    c.position.set(-center2.x, -box2.min.y, -center2.z);

    c.traverse((child: any) => {
      if (child.isMesh) { child.castShadow = true; child.receiveShadow = true; }
    });

    const finalBox = new THREE.Box3().setFromObject(c);
    const finalSize = new THREE.Vector3();
    finalBox.getSize(finalSize);

    // Report actual size back to parent for wireframe
    if (onSize) {
      onSize({ width: finalSize.x, height: finalSize.y, depth: finalSize.z });
    }

    return c;
  }, [scene, dims.width, dims.height, dims.depth, onSize]);
  return <primitive object={cloned} />;
}

const CATEGORY_COLORS: Record<string, string> = {
  SOFA: '#8B7355',
  BED: '#C4A882',
  TABLE: '#92400e',
  CHAIR: '#b45309',
  STORAGE: '#6b5b4f',
  LIGHTING: '#eab308',
  RUG: '#9f7aea',
  DECOR: '#ec4899',
  PLANT: '#16a34a',
  KITCHEN_FIXTURE: '#78716c',
  BATHROOM_FIXTURE: '#64748b',
};

function getCategoryColor(category: string): string {
  return CATEGORY_COLORS[category?.toUpperCase()] || '#8B7355';
}

// Simple shape based on category for more realistic look
function FurnitureShape({
  dims,
  color,
  category,
}: {
  dims: { width: number; height: number; depth: number };
  color: string;
  category: string;
}) {
  const cat = category?.toUpperCase();

  // Sofa: wider, lower box with back cushion
  if (cat === 'SOFA') {
    const seatH = dims.height * 0.45;
    const backH = dims.height * 0.55;
    return (
      <group>
        {/* Seat */}
        <mesh position={[0, seatH / 2, 0]} castShadow receiveShadow>
          <boxGeometry args={[dims.width, seatH, dims.depth]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        {/* Back cushion */}
        <mesh position={[0, seatH + backH / 2, -dims.depth / 2 + 0.08]} castShadow>
          <boxGeometry args={[dims.width, backH, 0.15]} />
          <meshStandardMaterial color={color} roughness={0.85} />
        </mesh>
        {/* Armrests */}
        <mesh position={[-dims.width / 2 + 0.06, seatH + 0.08, 0]} castShadow>
          <boxGeometry args={[0.12, 0.16, dims.depth * 0.9]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        <mesh position={[dims.width / 2 - 0.06, seatH + 0.08, 0]} castShadow>
          <boxGeometry args={[0.12, 0.16, dims.depth * 0.9]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
      </group>
    );
  }

  // Bed: mattress + headboard
  if (cat === 'BED') {
    const mattressH = dims.height * 0.4;
    return (
      <group>
        {/* Frame */}
        <mesh position={[0, mattressH * 0.3, 0]} castShadow receiveShadow>
          <boxGeometry args={[dims.width, mattressH * 0.6, dims.depth]} />
          <meshStandardMaterial color="#d4c5b0" roughness={0.7} />
        </mesh>
        {/* Mattress */}
        <mesh position={[0, mattressH * 0.6 + mattressH * 0.4 / 2, 0]} castShadow>
          <boxGeometry args={[dims.width - 0.04, mattressH * 0.4, dims.depth - 0.04]} />
          <meshStandardMaterial color="#f5f0ea" roughness={0.9} />
        </mesh>
        {/* Headboard */}
        <mesh position={[0, dims.height * 0.5, -dims.depth / 2 + 0.04]} castShadow>
          <boxGeometry args={[dims.width, dims.height, 0.08]} />
          <meshStandardMaterial color={color} roughness={0.6} />
        </mesh>
      </group>
    );
  }

  // Table: top surface + legs
  if (cat === 'TABLE') {
    const topH = 0.04;
    const legH = dims.height - topH;
    const legSize = 0.04;
    const hw = dims.width / 2 - 0.06;
    const hd = dims.depth / 2 - 0.06;
    return (
      <group>
        <mesh position={[0, dims.height - topH / 2, 0]} castShadow receiveShadow>
          <boxGeometry args={[dims.width, topH, dims.depth]} />
          <meshStandardMaterial color={color} roughness={0.5} />
        </mesh>
        {[[-hw, -hd], [hw, -hd], [-hw, hd], [hw, hd]].map(([x, z], i) => (
          <mesh key={i} position={[x, legH / 2, z]} castShadow>
            <boxGeometry args={[legSize, legH, legSize]} />
            <meshStandardMaterial color={color} roughness={0.5} />
          </mesh>
        ))}
      </group>
    );
  }

  // Chair: seat + back + legs
  if (cat === 'CHAIR') {
    const seatH = dims.height * 0.5;
    const legSize = 0.03;
    const hw = dims.width / 2 - 0.04;
    const hd = dims.depth / 2 - 0.04;
    return (
      <group>
        <mesh position={[0, seatH, 0]} castShadow receiveShadow>
          <boxGeometry args={[dims.width, 0.04, dims.depth]} />
          <meshStandardMaterial color={color} roughness={0.6} />
        </mesh>
        <mesh position={[0, seatH + dims.height * 0.3, -dims.depth / 2 + 0.02]} castShadow>
          <boxGeometry args={[dims.width, dims.height * 0.5, 0.04]} />
          <meshStandardMaterial color={color} roughness={0.6} />
        </mesh>
        {[[-hw, -hd], [hw, -hd], [-hw, hd], [hw, hd]].map(([x, z], i) => (
          <mesh key={i} position={[x, seatH / 2, z]} castShadow>
            <boxGeometry args={[legSize, seatH, legSize]} />
            <meshStandardMaterial color={color} roughness={0.5} />
          </mesh>
        ))}
      </group>
    );
  }

  // Rug: flat plane on floor
  if (cat === 'RUG') {
    return (
      <mesh position={[0, 0.005, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[dims.width, dims.depth]} />
        <meshStandardMaterial color={color} roughness={0.95} side={THREE.DoubleSide} />
      </mesh>
    );
  }

  // Plant: cylinder pot + sphere foliage
  if (cat === 'PLANT') {
    return (
      <group>
        <mesh position={[0, dims.height * 0.2, 0]} castShadow>
          <cylinderGeometry args={[dims.width * 0.3, dims.width * 0.25, dims.height * 0.4, 16]} />
          <meshStandardMaterial color="#8B6F47" roughness={0.8} />
        </mesh>
        <mesh position={[0, dims.height * 0.6, 0]} castShadow>
          <sphereGeometry args={[dims.width * 0.45, 16, 12]} />
          <meshStandardMaterial color="#2d6a30" roughness={0.9} />
        </mesh>
      </group>
    );
  }

  // Lighting: cylinder base + sphere bulb
  if (cat === 'LIGHTING') {
    return (
      <group>
        <mesh position={[0, dims.height * 0.02, 0]} castShadow>
          <cylinderGeometry args={[dims.width * 0.35, dims.width * 0.4, 0.04, 16]} />
          <meshStandardMaterial color="#333" roughness={0.3} metalness={0.5} />
        </mesh>
        <mesh position={[0, dims.height * 0.5, 0]} castShadow>
          <cylinderGeometry args={[0.02, 0.02, dims.height * 0.9, 8]} />
          <meshStandardMaterial color="#555" roughness={0.3} metalness={0.5} />
        </mesh>
        <mesh position={[0, dims.height * 0.9, 0]} castShadow>
          <coneGeometry args={[dims.width * 0.3, dims.height * 0.25, 16]} />
          <meshStandardMaterial color="#f5f0e8" roughness={0.8} emissive="#fff5e0" emissiveIntensity={0.3} />
        </mesh>
      </group>
    );
  }

  // Default: simple rounded box
  return (
    <mesh castShadow receiveShadow>
      <boxGeometry args={[dims.width, dims.height, dims.depth]} />
      <meshStandardMaterial color={color} roughness={0.7} />
    </mesh>
  );
}

interface FurnitureModelProps {
  item: PlacedItem;
  isSelected: boolean;
  onSelect: (instanceId: string) => void;
  onPositionChange: (instanceId: string, position: [number, number, number]) => void;
}

// Floor plane for drag raycasting — offset by floorY
function getFloorPlane() {
  return new THREE.Plane(new THREE.Vector3(0, 1, 0), -roomBounds.floorY);
}
const _raycaster = new THREE.Raycaster();
const _surfaceRaycaster = new THREE.Raycaster();
const _mouse = new THREE.Vector2();
const _intersection = new THREE.Vector3();

import { roomBounds, roomSceneObject } from './GLBRoom';
const DRAG_LIFT = 0.05;

export default function FurnitureModel({
  item,
  isSelected,
  onSelect,
  onPositionChange,
}: FurnitureModelProps) {
  const groupRef = useRef<Group>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [hovered, setHovered] = useState(false);
  // Actual rendered size from GLB model (for accurate wireframe)
  const [actualSize, setActualSize] = useState<{ width: number; height: number; depth: number } | null>(null);
  const { camera, gl } = useThree();

  // Offset between cursor hit and item position, stored on drag start
  const dragOffset = useRef<{ x: number; z: number }>({ x: 0, z: 0 });
  // Smoothed Y for lift animation
  const liftY = useRef(0);

  const rawDims = item.product.dimensions ?? { width: 0.6, height: 0.6, depth: 0.6 };
  // For display size (wireframe, label), cap to match the GLB scaling cap of 0.8
  const maxRaw = Math.max(rawDims.width, rawDims.height, rawDims.depth, 0.3);
  const displayScale = Math.min(maxRaw, 0.8) / maxRaw;
  const dims = {
    width: rawDims.width * displayScale,
    height: rawDims.height * displayScale,
    depth: rawDims.depth * displayScale,
  };
  const color = getCategoryColor(item.product.category);

  // Smoothly animate the lift on drag
  useFrame((_state, delta) => {
    const targetY = isDragging ? DRAG_LIFT : 0;
    liftY.current += (targetY - liftY.current) * Math.min(1, delta * 12);
    if (groupRef.current) {
      groupRef.current.position.y = item.position[1] + liftY.current;
    }
  });

  // Get the XZ position on the floor plane from screen coordinates
  const getFloorHit = useCallback(
    (clientX: number, clientY: number): THREE.Vector3 | null => {
      const rect = gl.domElement.getBoundingClientRect();
      _mouse.x = ((clientX - rect.left) / rect.width) * 2 - 1;
      _mouse.y = -((clientY - rect.top) / rect.height) * 2 + 1;
      _raycaster.setFromCamera(_mouse, camera);
      return _raycaster.ray.intersectPlane(getFloorPlane(), _intersection);
    },
    [camera, gl.domElement]
  );

  // Given an XZ position, cast downward to find the floor surface Y
  // During drag, we want the floor level (lowest upward-facing surface), not ceiling
  const getSurfaceY = useCallback(
    (x: number, z: number): number => {
      if (!roomSceneObject) return roomBounds.floorY;
      _surfaceRaycaster.set(
        new THREE.Vector3(x, 10, z),
        new THREE.Vector3(0, -1, 0)
      );
      const hits = _surfaceRaycaster.intersectObject(roomSceneObject, true);
      if (hits.length > 0) {
        // Filter for upward-facing surfaces (floor, tables, counters — not ceiling undersides)
        const upwardHits = hits.filter(h => h.face && h.face.normal.y > 0.5);
        if (upwardHits.length > 0) {
          // Return the LOWEST upward-facing surface (the floor)
          // Unless item is being dragged over a table, in which case return the highest
          // For simplicity, return the floor (last upward hit)
          return upwardHits[upwardHits.length - 1].point.y;
        }
      }
      return roomBounds.floorY;
    },
    []
  );

  const handlePointerDown = useCallback(
    (e: ThreeEvent<PointerEvent>) => {
      e.stopPropagation();
      onSelect(item.instanceId);

      // Compute offset between hit point on floor and item's current position
      const hit = getFloorHit(e.clientX, e.clientY);
      if (hit) {
        dragOffset.current = {
          x: item.position[0] - hit.x,
          z: item.position[2] - hit.z,
        };
      } else {
        dragOffset.current = { x: 0, z: 0 };
      }

      setIsDragging(true);
      (gl.domElement as HTMLElement).style.cursor = 'grabbing';
      // Capture pointer so we get move/up even if cursor leaves the mesh
      (e.target as Element)?.setPointerCapture?.(e.pointerId);
    },
    [item.instanceId, item.position, onSelect, gl.domElement, getFloorHit]
  );

  const handlePointerMove = useCallback(
    (e: ThreeEvent<PointerEvent>) => {
      if (!isDragging) return;
      e.stopPropagation();

      const hit = getFloorHit(e.clientX, e.clientY);
      if (hit) {
        const x = Math.max(roomBounds.minX, Math.min(roomBounds.maxX, hit.x + dragOffset.current.x));
        const z = Math.max(roomBounds.minZ, Math.min(roomBounds.maxZ, hit.z + dragOffset.current.z));
        // Raycast downward at the target XZ to find the surface (floor, table, counter)
        const surfaceY = getSurfaceY(x, z);
        onPositionChange(item.instanceId, [x, surfaceY, z]);
      }
    },
    [isDragging, item.instanceId, onPositionChange, getFloorHit, getSurfaceY]
  );

  const handlePointerUp = useCallback(
    (e: ThreeEvent<PointerEvent>) => {
      if (isDragging) {
        setIsDragging(false);
        (gl.domElement as HTMLElement).style.cursor = hovered ? 'grab' : 'auto';
        (e.target as Element)?.releasePointerCapture?.(e.pointerId);
      }
    },
    [isDragging, hovered, gl.domElement]
  );

  return (
    <group
      ref={groupRef}
      position={item.position}
      rotation={item.rotation}
      scale={item.scale}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerOver={() => {
        setHovered(true);
        if (!isDragging) (gl.domElement as HTMLElement).style.cursor = 'grab';
      }}
      onPointerOut={() => {
        setHovered(false);
        if (!isDragging) (gl.domElement as HTMLElement).style.cursor = 'auto';
      }}
    >
      {/* Furniture: GLB model if available, otherwise shaped fallback */}
      {item.product.modelUrl && item.product.modelUrl.includes('/models/') ? (
        <Suspense fallback={<FurnitureShape dims={dims} color={color} category={item.product.category} />}>
          <GLBFurniture url={item.product.modelUrl} dims={dims} onSize={setActualSize} />
        </Suspense>
      ) : (
        <FurnitureShape dims={dims} color={color} category={item.product.category} />
      )}

      {/* Yellow selection outline — use actual GLB size if available */}
      {isSelected && (() => {
        const s = actualSize || dims;
        return (
          <>
            <mesh position={[0, s.height / 2, 0]}>
              <boxGeometry args={[s.width + 0.02, s.height + 0.02, s.depth + 0.02]} />
              <meshBasicMaterial color="#ffcc00" wireframe />
            </mesh>
            <mesh position={[0, s.height / 2, 0]}>
              <boxGeometry args={[s.width + 0.03, s.height + 0.03, s.depth + 0.03]} />
              <meshBasicMaterial color="#ffcc00" transparent opacity={0.06} />
            </mesh>
          </>
        );
      })()}

      {/* Product name label */}
      {(isSelected || hovered) && (
        <Html
          position={[0, (actualSize?.height || dims.height) + 0.1, 0]}
          center
          distanceFactor={5}
          style={{ pointerEvents: 'none' }}
        >
          <div className="bg-gray-900/90 text-white text-[10px] px-2.5 py-1 rounded-lg whitespace-nowrap font-medium shadow-lg">
            {item.product.name}
            {item.product.price > 0 && (
              <span className="ml-1.5 text-yellow-300 text-[9px]">
                AED {item.product.price.toLocaleString()}
              </span>
            )}
          </div>
        </Html>
      )}
    </group>
  );
}
