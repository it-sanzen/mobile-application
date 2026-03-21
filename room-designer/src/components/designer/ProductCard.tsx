import { Suspense, useMemo } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, useGLTF, Environment } from '@react-three/drei';
import { Plus } from 'lucide-react';
import * as THREE from 'three';
import type { FurnitureProduct } from '../../store/types';

interface ProductCardProps {
  product: FurnitureProduct;
  onAdd: (product: FurnitureProduct) => void;
}

function MiniModel({ url }: { url: string }) {
  const { scene } = useGLTF(url);
  const cloned = useMemo(() => {
    const c = scene.clone(true);
    const box = new THREE.Box3().setFromObject(c);
    const size = new THREE.Vector3();
    const center = new THREE.Vector3();
    box.getSize(size);
    box.getCenter(center);

    const maxDim = Math.max(size.x, size.y, size.z);
    if (maxDim > 0) {
      const scale = 2 / maxDim;
      c.scale.setScalar(scale);
      const box2 = new THREE.Box3().setFromObject(c);
      const center2 = new THREE.Vector3();
      box2.getCenter(center2);
      c.position.set(-center2.x, -box2.min.y, -center2.z);
    }

    c.traverse((child: any) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });
    return c;
  }, [scene]);

  return <primitive object={cloned} />;
}

function ModelPreview({ url }: { url: string }) {
  return (
    <Canvas
      camera={{ position: [2, 2, 2], fov: 35 }}
      style={{ background: 'transparent' }}
      gl={{ antialias: true, alpha: true }}
    >
      <ambientLight intensity={0.8} />
      <directionalLight position={[3, 5, 3]} intensity={1} />
      <Suspense fallback={null}>
        <MiniModel url={url} />
        <Environment preset="apartment" />
      </Suspense>
      <OrbitControls enableZoom={false} enablePan={false} autoRotate autoRotateSpeed={2} />
    </Canvas>
  );
}

export default function ProductCard({ product, onAdd }: ProductCardProps) {
  const hasGlb = product.modelUrl && product.modelUrl.endsWith('.glb');

  return (
    <button
      onClick={() => onAdd(product)}
      className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition-all duration-200 group text-left cursor-pointer hover:-translate-y-0.5"
    >
      {/* 3D Preview */}
      <div className="aspect-square relative overflow-hidden bg-gray-50">
        {hasGlb ? (
          <ModelPreview url={product.modelUrl} />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gray-100">
            <span className="text-gray-400 text-xs">No preview</span>
          </div>
        )}

        {/* Hover "+" overlay */}
        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors" />
        <div className="absolute bottom-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <div className="w-8 h-8 rounded-full bg-[#144525] text-white flex items-center justify-center shadow-lg">
            <Plus size={16} strokeWidth={2.5} />
          </div>
        </div>
      </div>

      {/* Info */}
      <div className="p-2.5">
        <p className="text-xs font-bold text-gray-900 truncate leading-tight">
          {product.name}
        </p>
        <p className="text-[13px] text-[#144525] font-semibold mt-1">
          AED {product.price?.toLocaleString(undefined, {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0,
          }) ?? '--'}
        </p>
      </div>
    </button>
  );
}

export function getCategoryColor(category: string): string {
  const colors: Record<string, string> = {
    SOFA: '#8B7355', BED: '#C4A882', TABLE: '#92400e', CHAIR: '#b45309',
    STORAGE: '#6b5b4f', LIGHTING: '#eab308', RUG: '#9f7aea', DECOR: '#ec4899',
    PLANT: '#16a34a', KITCHEN_FIXTURE: '#78716c', BATHROOM_FIXTURE: '#64748b',
  };
  return colors[category?.toUpperCase()] || '#8B7355';
}
