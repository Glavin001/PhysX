/**
 * Hierarchical fracture authoring for multi-level destruction.
 *
 * Takes a Three.js BufferGeometry and produces a hierarchical chunk tree
 * suitable for Blast's native subsupport cascade. The result contains:
 * - A root chunk (non-support, non-visible)
 * - Support-level chunks (connected by bonds, participate in stress)
 * - Subsupport chunks (children of support, revealed by chunk damage)
 *
 * Reuses fractureGeometry() from pinataFracture.ts for each fracture level.
 */
import * as THREE from 'three';
import type { Vec3, ScenarioBond, ScenarioDesc, HierarchicalScenarioChunk } from '../rapier/types';
import type { FragmentInfo, BondDetectionOptions } from './fracture';
import { computeBondsFromFragments } from './fracture';
import type { PinataModule, FractureGeometryOptions } from './pinataFracture';
import { fractureGeometry, fractureGeometryAsync } from './pinataFracture';
import { recenterGeometry, ensurePlainAttributes, prepareGeometryForFracture } from './geometryUtils';

export type HierarchicalFractureOptions = {
  /** Number of support-level fragments. Default: 12 */
  supportFragmentCount?: number;
  /** Number of subsupport fragments per support chunk. Default: 4 */
  subsupportFragmentCount?: number;
  /** Minimum half-extent to avoid degenerate physics shapes. Default: 0.05 */
  minHalfExtent?: number;
  /** Voronoi tessellation mode. Default: '3D' */
  voronoiMode?: '3D' | '2.5D';
  /** World offset for fragment positions. Default: {x:0, y:0, z:0} */
  worldOffset?: Vec3;
  /** Pre-imported three-pinata module (recommended for browser ESM). */
  pinata?: PinataModule;
  /** Bond detection options for support-level bonds. */
  bondOptions?: BondDetectionOptions;
  /** Density (kg/m³) for mass computation from volume. Default: 2400 (concrete) */
  density?: number;
};

export type HierarchicalFractureResult = {
  /** Chunk descriptions with parent-child hierarchy and support flags. */
  chunks: HierarchicalScenarioChunk[];
  /** Bonds between support-level chunks. Indices reference chunk array. */
  bonds: ScenarioBond[];
  /** Geometry per chunk, keyed by chunk index. Root (index 0) has no geometry. */
  geometries: Map<number, THREE.BufferGeometry>;
  /** Half-extents per chunk for collider sizing. */
  halfExtents: Map<number, Vec3>;
};

/**
 * Fracture geometry into a hierarchical chunk tree.
 *
 * Algorithm:
 * 1. Fracture input geometry into `supportFragmentCount` pieces (support level)
 * 2. For each support piece, fracture again into `subsupportFragmentCount` sub-pieces
 * 3. Build chunk tree: root → support → subsupport
 * 4. Compute bonds between adjacent support chunks
 *
 * @returns Chunk tree, bonds, and geometries indexed by chunk ID
 */
export function buildHierarchicalFragments(
  geometry: THREE.BufferGeometry,
  options?: HierarchicalFractureOptions,
): HierarchicalFractureResult {
  const {
    supportFragmentCount = 12,
    subsupportFragmentCount = 4,
    minHalfExtent = 0.05,
    voronoiMode = '3D',
    worldOffset = { x: 0, y: 0, z: 0 },
    pinata,
    bondOptions,
    density = 2400,
  } = options ?? {};

  // Step 1: Fracture into support-level fragments.
  const supportFragments = fractureGeometry(geometry, {
    fragmentCount: supportFragmentCount,
    voronoiMode,
    worldOffset,
    minHalfExtent,
    pinata,
  });

  // Build chunks array. Index 0 = root chunk.
  const chunks: HierarchicalScenarioChunk[] = [];
  const geometries = new Map<number, THREE.BufferGeometry>();
  const halfExtents = new Map<number, Vec3>();

  // Root chunk (non-support, non-visible).
  chunks.push({
    centroid: { x: 0, y: 0, z: 0 },
    mass: 0,
    volume: 1,
    parentIndex: -1,
    isSupport: false,
  });

  // Step 2: Add support-level chunks (children of root).
  const supportStartIndex = 1;
  for (const frag of supportFragments) {
    const chunkIndex = chunks.length;
    const vol = frag.halfExtents.x * frag.halfExtents.y * frag.halfExtents.z * 8;
    chunks.push({
      centroid: frag.worldPosition,
      mass: vol * density,
      volume: vol,
      parentIndex: 0, // child of root
      isSupport: true,
    });
    geometries.set(chunkIndex, frag.geometry);
    halfExtents.set(chunkIndex, frag.halfExtents);
  }

  // Step 3: For each support chunk, fracture into subsupport children.
  if (subsupportFragmentCount > 1) {
    for (let si = 0; si < supportFragments.length; si++) {
      const supportChunkIndex = supportStartIndex + si;
      const supportFrag = supportFragments[si];

      let subFragments: FragmentInfo[];
      try {
        subFragments = fractureGeometry(supportFrag.geometry, {
          fragmentCount: subsupportFragmentCount,
          voronoiMode,
          worldOffset: supportFrag.worldPosition,
          minHalfExtent,
          pinata,
        });
      } catch {
        // If sub-fracture fails (geometry too small), skip subsupport for this chunk.
        continue;
      }

      if (subFragments.length < 2) {
        // Fracture didn't produce meaningful sub-pieces, keep support chunk as leaf.
        continue;
      }

      for (const subFrag of subFragments) {
        const chunkIndex = chunks.length;
        const vol = subFrag.halfExtents.x * subFrag.halfExtents.y * subFrag.halfExtents.z * 8;
        chunks.push({
          centroid: subFrag.worldPosition,
          mass: vol * density,
          volume: vol,
          parentIndex: supportChunkIndex,
          isSupport: false, // subsupport
        });
        geometries.set(chunkIndex, subFrag.geometry);
        halfExtents.set(chunkIndex, subFrag.halfExtents);
      }
    }
  }

  // Step 4: Compute bonds between support-level chunks.
  // Bond indices must reference chunk indices in the `chunks` array.
  const supportOnlyFragments = supportFragments.map((f, i) => ({
    ...f,
    isSupport: false, // all dynamic for bond detection
    _chunkIndex: supportStartIndex + i,
  }));

  const rawBonds = computeBondsFromFragments(supportOnlyFragments, bondOptions);

  // Map fragment-relative indices back to chunk indices.
  const bonds: ScenarioBond[] = rawBonds.map(b => ({
    node0: supportOnlyFragments[b.node0]._chunkIndex,
    node1: supportOnlyFragments[b.node1]._chunkIndex,
    centroid: b.centroid,
    normal: b.normal,
    area: b.area,
  }));

  return { chunks, bonds, geometries, halfExtents };
}

/**
 * Async version of buildHierarchicalFragments that handles dynamic import
 * of three-pinata.
 */
export async function buildHierarchicalFragmentsAsync(
  geometry: THREE.BufferGeometry,
  options?: HierarchicalFractureOptions,
): Promise<HierarchicalFractureResult> {
  // Ensure pinata is loaded for async usage
  if (!options?.pinata) {
    const { ensurePinataLoaded } = await import('./pinataFracture');
    await ensurePinataLoaded();
  }
  return buildHierarchicalFragments(geometry, options);
}

/**
 * Build a complete ScenarioDesc from hierarchical fragments.
 * Convenience function that combines fracture + scenario creation.
 */
export function buildHierarchicalScenario(
  geometry: THREE.BufferGeometry,
  options?: HierarchicalFractureOptions & {
    /** Indices of support chunks to pin as ground anchors (mass=0). */
    groundChunkIndices?: number[];
  },
): ScenarioDesc & { geometries: Map<number, THREE.BufferGeometry>; halfExtents: Map<number, Vec3> } {
  const result = buildHierarchicalFragments(geometry, options);
  const groundSet = new Set(options?.groundChunkIndices ?? []);

  // Build nodes from chunks (for compatibility with existing core).
  const nodes = result.chunks.map((c, i) => ({
    centroid: c.centroid,
    mass: groundSet.has(i) ? 0 : (c.mass ?? 1),
    volume: c.volume ?? 1,
  }));

  return {
    nodes,
    bonds: result.bonds,
    hierarchicalChunks: result.chunks.map((c, i) => ({
      ...c,
      mass: groundSet.has(i) ? 0 : (c.mass ?? 1),
    })),
    geometries: result.geometries,
    halfExtents: result.halfExtents,
  };
}
