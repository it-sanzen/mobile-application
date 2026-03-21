import { Suspense, useMemo, useCallback, useEffect, useRef } from 'react';
import { useGLTF } from '@react-three/drei';
import { useFrame, type ThreeEvent } from '@react-three/fiber';
import * as THREE from 'three';
import { useDesignerStore } from '../../store/designerStore';

export const roomBounds = { minX: -2, maxX: 2, minZ: -2, maxZ: 2, floorY: 0, centerX: 0, centerZ: 0 };

// Shared reference to the room scene object for surface raycasting (floor, tables, etc.)
export let roomSceneObject: THREE.Object3D | null = null;

interface GLBRoomModelProps {
  url: string;
}

// Module-level set to track hidden object UUIDs (persists across re-renders)
const hiddenObjectUUIDs = new Set<string>();

function GLBRoomModel({ url }: GLBRoomModelProps) {
  const { scene } = useGLTF(url);

  const { cloned, sceneRef } = useMemo(() => {
    const c = scene.clone(true);

    c.traverse((child: any) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });

    // Scale to fit ~5 units
    const box = new THREE.Box3().setFromObject(c);
    const size = new THREE.Vector3();
    box.getSize(size);
    const scale = 5 / Math.max(size.x, size.z, 0.01);
    c.scale.setScalar(scale);

    // Center horizontally, place bottom at Y=0
    const box2 = new THREE.Box3().setFromObject(c);
    const center2 = new THREE.Vector3();
    box2.getCenter(center2);
    c.position.set(-center2.x, -box2.min.y, -center2.z);

    // Get final bounds after positioning
    const box3 = new THREE.Box3().setFromObject(c);
    const size3 = new THREE.Vector3();
    box3.getSize(size3);

    // Find the floor by raycasting down from center after positioning
    // We need updateMatrixWorld first
    c.updateMatrixWorld(true);
    const floorRaycaster = new THREE.Raycaster();
    const center3 = new THREE.Vector3();
    box3.getCenter(center3);
    floorRaycaster.set(
      new THREE.Vector3(center3.x, box3.max.y - 0.01, center3.z),
      new THREE.Vector3(0, -1, 0)
    );
    const floorHits = floorRaycaster.intersectObject(c, true);
    // Find the lowest upward-facing surface (the floor, not ceiling/shelves)
    let floorY = 0.01;
    const upwardHits = floorHits.filter(h => h.face && h.face.normal.y > 0.5);
    if (upwardHits.length > 0) {
      // The last upward-facing hit is the floor (lowest)
      floorY = upwardHits[upwardHits.length - 1].point.y;
    } else if (floorHits.length > 0) {
      // Fallback: use the last hit (lowest surface)
      floorY = floorHits[floorHits.length - 1].point.y;
    }
    console.log('[Room] Floor raycast hits:', floorHits.length, 'upward:', upwardHits.length, 'floorY:', floorY.toFixed(3));

    // Per-axis insets (10% of each axis, not X for both)
    const insetX = size3.x * 0.1;
    const insetZ = size3.z * 0.1;
    roomBounds.minX = box3.min.x + insetX;
    roomBounds.maxX = box3.max.x - insetX;
    roomBounds.minZ = box3.min.z + insetZ;
    roomBounds.maxZ = box3.max.z - insetZ;
    roomBounds.floorY = floorY;
    roomBounds.centerX = (roomBounds.minX + roomBounds.maxX) / 2;
    roomBounds.centerZ = (roomBounds.minZ + roomBounds.maxZ) / 2;

    console.log('[Room] floorY:', floorY.toFixed(3));
    console.log('[Room] size:', size3.x.toFixed(2), 'x', size3.y.toFixed(2), 'x', size3.z.toFixed(2));
    console.log('[Room] bounds X:', roomBounds.minX.toFixed(2), 'to', roomBounds.maxX.toFixed(2), '| Z:', roomBounds.minZ.toFixed(2), 'to', roomBounds.maxZ.toFixed(2));
    console.log('[Room] center:', roomBounds.centerX.toFixed(2), roomBounds.centerZ.toFixed(2));

    // Re-apply hidden state for objects that were previously removed.
    // We match by object name since UUIDs change after clone.
    if (hiddenObjectUUIDs.size > 0) {
      console.log('[Room] Re-applying hidden state for', hiddenObjectUUIDs.size, 'tracked objects');
      c.traverse((child: any) => {
        if (child.name && hiddenObjectUUIDs.has(child.name)) {
          child.visible = false;
          if (child.isMesh) child.raycast = () => {};
        }
      });
    }

    return { cloned: c, sceneRef: c };
  }, [scene]);

  // Expose room scene for surface raycasting by other components
  useEffect(() => {
    roomSceneObject = cloned;
    return () => { roomSceneObject = null; };
  }, [cloned]);

  // Register the baked object removal callback
  const setOnRemoveBaked = useDesignerStore((s) => s._setOnRemoveBaked);
  useEffect(() => {
    const handleRemove = (obj: THREE.Object3D) => {
      // Hide the selected object and ALL its descendants.
      // No bounding-box expansion — only remove what the user clicked.
      // If they want to remove another piece, they click it separately.
      const hideObj = (o: THREE.Object3D) => {
        o.visible = false;
        if (o.name) hiddenObjectUUIDs.add(o.name);
        o.traverse((child: any) => {
          child.visible = false;
          if (child.name) hiddenObjectUUIDs.add(child.name);
          if (child.isMesh) child.raycast = () => {};
        });
      };

      hideObj(obj);
      console.log('[Room] Hidden:', obj.name || obj.type);
    };

    setOnRemoveBaked(handleRemove);
    return () => setOnRemoveBaked(null);
  }, [setOnRemoveBaked, cloned]);

  // Selection highlight box
  const highlightRef = useRef<THREE.Mesh>(null);
  const selectedBakedObject = useDesignerStore((s) => s.selectedBakedObject);
  const selectBakedObject = useDesignerStore((s) => s.selectBakedObject);

  // Animate selection highlight pulse
  useFrame((state) => {
    if (highlightRef.current && selectedBakedObject) {
      const t = state.clock.elapsedTime;
      highlightRef.current.material = highlightRef.current.material as THREE.MeshBasicMaterial;
      (highlightRef.current.material as THREE.MeshBasicMaterial).opacity = 0.08 + Math.sin(t * 3) * 0.04;
    }
  });

  const handleClick = useCallback((e: ThreeEvent<MouseEvent>) => {
    e.stopPropagation();
    const obj = e.object;
    if (!obj) return;

    const roomWidth = roomBounds.maxX - roomBounds.minX;
    const roomDepth = roomBounds.maxZ - roomBounds.minZ;
    // "Too large" = covers most of the room footprint (walls, floor, entire scene)
    const isTooBig = (o: THREE.Object3D) => {
      const b = new THREE.Box3().setFromObject(o);
      const s = new THREE.Vector3();
      b.getSize(s);
      return s.x > roomWidth * 0.75 && s.z > roomDepth * 0.75;
    };

    console.log('[Room Click] Hit:', obj.name || obj.uuid.substring(0, 8));

    // Skip clicks on walls/floor
    if (isTooBig(obj)) {
      console.log('[Room Click] Skipped — wall/floor');
      selectBakedObject(null);
      return;
    }

    // Get the size of the clicked mesh to use as reference
    const clickedBox = new THREE.Box3().setFromObject(obj);
    const clickedSize = new THREE.Vector3();
    clickedBox.getSize(clickedSize);
    const clickedFootprint = clickedSize.x * clickedSize.z;

    // Build ancestor chain: chain[0] = clicked mesh, chain[last] = direct child of sceneRef
    const chain: THREE.Object3D[] = [];
    let node: THREE.Object3D | null = obj;
    while (node && node !== sceneRef) {
      chain.push(node);
      node = node.parent;
    }

    // Walk UP the chain from clicked mesh toward scene root.
    // Stop if a parent is room structure OR if its footprint suddenly jumps
    // (meaning it groups multiple separate furniture pieces together).
    let target: THREE.Object3D = obj;
    let prevFootprint = clickedFootprint;
    for (let i = 1; i < chain.length; i++) {
      if (isTooBig(chain[i])) break;
      const b = new THREE.Box3().setFromObject(chain[i]);
      const s = new THREE.Vector3();
      b.getSize(s);
      const footprint = s.x * s.z;
      // If parent's footprint is more than 3x the previous level,
      // it likely groups multiple furniture pieces — stop here
      if (footprint > prevFootprint * 3 && i > 1) break;
      target = chain[i];
      prevFootprint = footprint;
    }

    // If we only got the single clicked mesh, try immediate parent
    if (target === obj && obj.parent && obj.parent !== sceneRef) {
      const parentBox = new THREE.Box3().setFromObject(obj.parent);
      const parentSize = new THREE.Vector3();
      parentBox.getSize(parentSize);
      const parentFootprint = parentSize.x * parentSize.z;
      // Only use parent if it's not too much bigger (< 3x footprint)
      if (!isTooBig(obj.parent) && parentFootprint < clickedFootprint * 3) {
        target = obj.parent;
      }
    }

    const targetBox = new THREE.Box3().setFromObject(target);
    const targetSize = new THREE.Vector3();
    targetBox.getSize(targetSize);
    const worldPos = new THREE.Vector3();
    targetBox.getCenter(worldPos);

    if (isTooBig(target)) {
      console.log('[Room Click] Skipped — room structure');
      selectBakedObject(null);
      return;
    }

    // Debug: log the ancestor chain so we can see the scene tree
    console.log('[Room Click] Ancestor chain:');
    chain.forEach((c, i) => {
      const b = new THREE.Box3().setFromObject(c);
      const s = new THREE.Vector3();
      b.getSize(s);
      const marker = c === target ? ' <<<< SELECTED' : '';
      console.log(`  [${i}] ${c.type} "${c.name || '-'}" size: ${s.x.toFixed(2)}x${s.y.toFixed(2)}x${s.z.toFixed(2)} children: ${c.children.length}${marker}`);
    });

    console.log('[Room Click] Selected:', target.name || 'group',
      'size:', targetSize.x.toFixed(2), 'x', targetSize.y.toFixed(2), 'x', targetSize.z.toFixed(2),
      'at:', worldPos.x.toFixed(2), worldPos.y.toFixed(2), worldPos.z.toFixed(2));

    // Select the baked-in furniture (don't hide it yet — user must click Delete/Replace)
    selectBakedObject({
      object: target,
      position: [worldPos.x, roomBounds.floorY, worldPos.z],
      name: target.name || 'Furniture',
    });
  }, [sceneRef, selectBakedObject]);

  // Compute highlight box for selected baked object
  const highlightInfo = useMemo(() => {
    if (!selectedBakedObject) return null;
    const box = new THREE.Box3().setFromObject(selectedBakedObject.object);
    const size = new THREE.Vector3();
    box.getSize(size);
    const center = new THREE.Vector3();
    box.getCenter(center);
    return { size, center };
  }, [selectedBakedObject]);

  return (
    <>
      <primitive object={cloned} onClick={handleClick} />
      {/* Yellow selection highlight for baked-in furniture */}
      {highlightInfo && (
        <>
          <mesh
            position={[highlightInfo.center.x, highlightInfo.center.y, highlightInfo.center.z]}
          >
            <boxGeometry args={[
              highlightInfo.size.x + 0.03,
              highlightInfo.size.y + 0.03,
              highlightInfo.size.z + 0.03,
            ]} />
            <meshBasicMaterial color="#ffcc00" wireframe />
          </mesh>
          <mesh
            ref={highlightRef}
            position={[highlightInfo.center.x, highlightInfo.center.y, highlightInfo.center.z]}
          >
            <boxGeometry args={[
              highlightInfo.size.x + 0.04,
              highlightInfo.size.y + 0.04,
              highlightInfo.size.z + 0.04,
            ]} />
            <meshBasicMaterial color="#ffcc00" transparent opacity={0.08} />
          </mesh>
        </>
      )}
    </>
  );
}

function LoadingFallback() {
  return (
    <mesh position={[0, 0.5, 0]}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="#e0ddd8" wireframe />
    </mesh>
  );
}

interface GLBRoomProps {
  url: string;
}

export default function GLBRoom({ url }: GLBRoomProps) {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <GLBRoomModel url={url} />
    </Suspense>
  );
}
