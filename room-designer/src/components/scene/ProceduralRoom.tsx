import { useMemo } from 'react';
import * as THREE from 'three';

interface ProceduralRoomProps {
  width: number;
  depth: number;
  height: number;
  roomType?: string;
}

function createFloorTexture(type: string): THREE.CanvasTexture {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d')!;

  if (type === 'wood') {
    ctx.fillStyle = '#c4a882';
    ctx.fillRect(0, 0, 512, 512);
    for (let i = 0; i < 50; i++) {
      ctx.strokeStyle = `rgba(139, 109, 76, ${0.08 + Math.random() * 0.12})`;
      ctx.lineWidth = 1 + Math.random() * 2;
      ctx.beginPath();
      const y = Math.random() * 512;
      ctx.moveTo(0, y);
      for (let x = 0; x < 512; x += 15) {
        ctx.lineTo(x, y + Math.sin(x * 0.015) * 4 + Math.random() * 2);
      }
      ctx.stroke();
    }
    const plankCount = 8;
    for (let i = 1; i < plankCount; i++) {
      const y = (512 / plankCount) * i;
      ctx.strokeStyle = 'rgba(90, 65, 40, 0.25)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(512, y);
      ctx.stroke();
    }
  } else {
    ctx.fillStyle = '#e8e5e0';
    ctx.fillRect(0, 0, 512, 512);
    const tileSize = 64;
    for (let tx = 0; tx < 512; tx += tileSize) {
      for (let ty = 0; ty < 512; ty += tileSize) {
        const v = Math.random() * 8 - 4;
        ctx.fillStyle = `rgb(${232 + v}, ${229 + v}, ${224 + v})`;
        ctx.fillRect(tx + 1, ty + 1, tileSize - 2, tileSize - 2);
      }
    }
    ctx.strokeStyle = 'rgba(170, 165, 158, 0.5)';
    ctx.lineWidth = 2;
    for (let x = 0; x <= 512; x += tileSize) {
      ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, 512); ctx.stroke();
    }
    for (let y = 0; y <= 512; y += tileSize) {
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(512, y); ctx.stroke();
    }
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(3, 3);
  return texture;
}

function createWallTexture(): THREE.CanvasTexture {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d')!;
  ctx.fillStyle = '#f5f2ee';
  ctx.fillRect(0, 0, 256, 256);
  for (let i = 0; i < 80; i++) {
    ctx.fillStyle = `rgba(${240 + Math.random() * 15}, ${237 + Math.random() * 15}, ${232 + Math.random() * 15}, 0.3)`;
    ctx.fillRect(Math.random() * 256, Math.random() * 256, 3 + Math.random() * 8, 3 + Math.random() * 8);
  }
  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(2, 1);
  return texture;
}

function CeilingLight({ position }: { position: [number, number, number] }) {
  return (
    <group position={position}>
      <mesh rotation={[-Math.PI / 2, 0, 0]}>
        <ringGeometry args={[0.06, 0.1, 32]} />
        <meshStandardMaterial color="#d0ccc6" roughness={0.8} />
      </mesh>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.005, 0]}>
        <circleGeometry args={[0.06, 32]} />
        <meshStandardMaterial color="#fffbe6" emissive="#fffbe6" emissiveIntensity={2} toneMapped={false} />
      </mesh>
      <pointLight position={[0, -0.15, 0]} intensity={0.5} distance={4} decay={2} color="#fff5e0" />
    </group>
  );
}

export default function ProceduralRoom({ width, depth, height, roomType }: ProceduralRoomProps) {
  const floorType = roomType === 'KITCHEN' || roomType === 'BATHROOM' ? 'tile' : 'wood';

  const { floorTexture, wallTexture } = useMemo(
    () => ({ floorTexture: createFloorTexture(floorType), wallTexture: createWallTexture() }),
    [floorType]
  );

  const halfW = width / 2;
  const halfD = depth / 2;
  const wt = 0.08; // wall thickness

  // Ceiling lights
  const lightPositions = useMemo(() => {
    const pos: [number, number, number][] = [];
    const cols = width > 4 ? 3 : 2;
    const rows = depth > 3.5 ? 2 : 1;
    for (let c = 0; c < cols; c++) {
      for (let r = 0; r < rows; r++) {
        pos.push([
          -halfW + (width / (cols + 1)) * (c + 1),
          height - 0.01,
          -halfD + (depth / (rows + 1)) * (r + 1),
        ]);
      }
    }
    return pos;
  }, [width, depth, height, halfW, halfD]);

  // Window on right wall
  const winW = depth * 0.4;
  const winH = height * 0.35;
  const winY = height * 0.35;

  // Door on left wall
  const doorW = 0.9;
  const doorH = 2.1;
  const doorZ = halfD - 0.8; // near front-right corner

  return (
    <group>
      {/* ===== FLOOR ===== */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]} receiveShadow>
        <planeGeometry args={[width, depth]} />
        <meshStandardMaterial map={floorTexture} roughness={0.7} />
      </mesh>

      {/* ===== CEILING ===== */}
      <mesh rotation={[Math.PI / 2, 0, 0]} position={[0, height, 0]}>
        <planeGeometry args={[width, depth]} />
        <meshStandardMaterial color="#fafaf8" roughness={0.9} />
      </mesh>

      {/* Ceiling lights */}
      {lightPositions.map((pos, i) => (
        <CeilingLight key={i} position={pos} />
      ))}

      {/* ===== BACK WALL (-Z) — full wall ===== */}
      <mesh position={[0, height / 2, -halfD]} receiveShadow>
        <boxGeometry args={[width, height, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>

      {/* ===== LEFT WALL (-X) — with door ===== */}
      {/* Section behind door */}
      <mesh position={[-halfW, height / 2, (-halfD + doorZ - doorW / 2) / 2]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[doorZ - doorW / 2 + halfD, height, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Section in front of door */}
      <mesh position={[-halfW, height / 2, (doorZ + doorW / 2 + halfD) / 2]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[halfD - doorZ - doorW / 2, height, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Above door */}
      <mesh position={[-halfW, doorH + (height - doorH) / 2, doorZ]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[doorW, height - doorH, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Door frame */}
      <group position={[-halfW + wt / 2 + 0.001, 0, doorZ]} rotation={[0, Math.PI / 2, 0]}>
        <mesh position={[-doorW / 2 - 0.03, doorH / 2, 0]}>
          <boxGeometry args={[0.06, doorH, 0.03]} />
          <meshStandardMaterial color="#d4cfc8" roughness={0.5} />
        </mesh>
        <mesh position={[doorW / 2 + 0.03, doorH / 2, 0]}>
          <boxGeometry args={[0.06, doorH, 0.03]} />
          <meshStandardMaterial color="#d4cfc8" roughness={0.5} />
        </mesh>
        <mesh position={[0, doorH + 0.03, 0]}>
          <boxGeometry args={[doorW + 0.12, 0.06, 0.03]} />
          <meshStandardMaterial color="#d4cfc8" roughness={0.5} />
        </mesh>
      </group>

      {/* ===== RIGHT WALL (+X) — with window ===== */}
      {/* Below window */}
      <mesh position={[halfW, winY / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[depth, winY, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Above window */}
      <mesh position={[halfW, winY + winH + (height - winY - winH) / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[depth, height - winY - winH, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Left of window */}
      <mesh position={[halfW, winY + winH / 2, -halfD + (halfD - winW / 2) / 2]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[halfD - winW / 2, winH, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Right of window */}
      <mesh position={[halfW, winY + winH / 2, halfD - (halfD - winW / 2) / 2]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[halfD - winW / 2, winH, wt]} />
        <meshStandardMaterial map={wallTexture} roughness={0.85} />
      </mesh>
      {/* Window glass */}
      <mesh position={[halfW - 0.02, winY + winH / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <planeGeometry args={[winW, winH]} />
        <meshPhysicalMaterial color="#c8dff0" transparent opacity={0.25} roughness={0.05} transmission={0.6} thickness={0.05} />
      </mesh>
      {/* Window frame + cross bars */}
      <mesh position={[halfW - 0.01, winY + winH / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[winW + 0.08, 0.03, 0.02]} />
        <meshStandardMaterial color="#d4cfc8" roughness={0.5} />
      </mesh>
      <mesh position={[halfW - 0.01, winY + winH / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[0.03, winH + 0.08, 0.02]} />
        <meshStandardMaterial color="#d4cfc8" roughness={0.5} />
      </mesh>
      {/* Window frame surround */}
      <group position={[halfW - 0.01, winY + winH / 2, 0]} rotation={[0, Math.PI / 2, 0]}>
        <mesh position={[0, winH / 2 + 0.025, 0]}>
          <boxGeometry args={[winW + 0.08, 0.05, 0.025]} />
          <meshStandardMaterial color="#e0ddd8" roughness={0.5} />
        </mesh>
        <mesh position={[0, -winH / 2 - 0.025, 0]}>
          <boxGeometry args={[winW + 0.08, 0.05, 0.025]} />
          <meshStandardMaterial color="#e0ddd8" roughness={0.5} />
        </mesh>
      </group>

      {/* ===== NO FRONT WALL (+Z) — OPEN for dollhouse view ===== */}

      {/* ===== BASEBOARD MOLDING ===== */}
      {/* Back wall */}
      <mesh position={[0, 0.04, -halfD + wt / 2 + 0.008]}>
        <boxGeometry args={[width - wt * 2, 0.08, 0.015]} />
        <meshStandardMaterial color="#e0ddd8" roughness={0.5} />
      </mesh>
      {/* Left wall */}
      <mesh position={[-halfW + wt / 2 + 0.008, 0.04, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[depth - wt * 2, 0.08, 0.015]} />
        <meshStandardMaterial color="#e0ddd8" roughness={0.5} />
      </mesh>
      {/* Right wall */}
      <mesh position={[halfW - wt / 2 - 0.008, 0.04, 0]} rotation={[0, Math.PI / 2, 0]}>
        <boxGeometry args={[depth - wt * 2, 0.08, 0.015]} />
        <meshStandardMaterial color="#e0ddd8" roughness={0.5} />
      </mesh>
    </group>
  );
}
