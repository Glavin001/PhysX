/**
 * Tests for hierarchical fracture authoring and graceful WASM fallback.
 *
 * Fracture tests require @dgreenheck/three-pinata (skips gracefully if unavailable).
 */
import { describe, it, expect, beforeAll } from 'vitest';
import * as THREE from 'three';

let pinataAvailable = false;
try {
  require.resolve('@dgreenheck/three-pinata');
  pinataAvailable = true;
} catch {
  pinataAvailable = false;
}

describe('buildHierarchicalFragments (requires three-pinata)', () => {
  beforeAll(async () => {
    if (pinataAvailable) {
      const { ensurePinataLoaded } = await import('../three/pinataFracture');
      await ensurePinataLoaded();
    }
  });

  it.skipIf(!pinataAvailable)('produces a root chunk at index 0 that is non-support', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 2,
    });
    geo.dispose();

    expect(result.chunks.length).toBeGreaterThan(0);
    expect(result.chunks[0].parentIndex).toBe(-1);
    expect(result.chunks[0].isSupport).toBe(false);
  });

  it.skipIf(!pinataAvailable)('support chunks are children of root (parentIndex=0)', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 1,
    });
    geo.dispose();

    const supportChunks = result.chunks.filter(c => c.isSupport);
    expect(supportChunks.length).toBeGreaterThan(0);
    for (const sc of supportChunks) {
      expect(sc.parentIndex).toBe(0);
    }
  });

  it.skipIf(!pinataAvailable)('generates bonds between support-level chunks', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(4, 2, 1, 2, 2, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 6,
      subsupportFragmentCount: 1,
    });
    geo.dispose();

    expect(result.bonds.length).toBeGreaterThan(0);
    for (const bond of result.bonds) {
      expect(bond.node0).toBeGreaterThanOrEqual(1);
      expect(bond.node1).toBeGreaterThanOrEqual(1);
    }
  });

  it.skipIf(!pinataAvailable)('subsupport chunks are children of support chunks', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(3, 3, 1, 2, 2, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 3,
    });
    geo.dispose();

    const subsupport = result.chunks.filter(c => !c.isSupport && c.parentIndex > 0);
    if (subsupport.length > 0) {
      for (const ss of subsupport) {
        const parent = result.chunks[ss.parentIndex];
        expect(parent.isSupport).toBe(true);
      }
    }
  });

  it.skipIf(!pinataAvailable)('root has no geometry; all others do', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 2,
    });
    geo.dispose();

    expect(result.geometries.has(0)).toBe(false);
    for (let i = 1; i < result.chunks.length; i++) {
      expect(result.geometries.has(i)).toBe(true);
    }
  });

  it.skipIf(!pinataAvailable)('halfExtents are positive for all chunks with geometry', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 2,
    });
    geo.dispose();

    for (const [idx] of result.geometries) {
      expect(result.halfExtents.has(idx)).toBe(true);
      const he = result.halfExtents.get(idx)!;
      expect(he.x).toBeGreaterThan(0);
      expect(he.y).toBeGreaterThan(0);
      expect(he.z).toBeGreaterThan(0);
    }
  });

  it.skipIf(!pinataAvailable)('mass computed from volume times density', async () => {
    const { buildHierarchicalFragments } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const density = 1000;
    const result = buildHierarchicalFragments(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 1,
      density,
    });
    geo.dispose();

    for (let i = 1; i < result.chunks.length; i++) {
      const c = result.chunks[i];
      if (c.isSupport) {
        const he = result.halfExtents.get(i)!;
        const expectedVol = he.x * he.y * he.z * 8;
        expect(c.mass).toBeCloseTo(expectedVol * density, 0);
      }
    }
  });
});

describe('buildHierarchicalScenario (requires three-pinata)', () => {
  beforeAll(async () => {
    if (pinataAvailable) {
      const { ensurePinataLoaded } = await import('../three/pinataFracture');
      await ensurePinataLoaded();
    }
  });

  it.skipIf(!pinataAvailable)('returns ScenarioDesc with hierarchicalChunks', async () => {
    const { buildHierarchicalScenario } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalScenario(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 2,
    });
    geo.dispose();

    expect(result.nodes).toBeDefined();
    expect(result.bonds).toBeDefined();
    expect(result.hierarchicalChunks).toBeDefined();
    expect(result.hierarchicalChunks!.length).toBe(result.nodes.length);
  });

  it.skipIf(!pinataAvailable)('ground chunk indices set mass to 0', async () => {
    const { buildHierarchicalScenario } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalScenario(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 1,
      groundChunkIndices: [1, 2],
    });
    geo.dispose();

    expect(result.nodes[1].mass).toBe(0);
    expect(result.nodes[2].mass).toBe(0);
    expect(result.hierarchicalChunks![1].mass).toBe(0);
    expect(result.hierarchicalChunks![2].mass).toBe(0);
    if (result.nodes.length > 3) {
      expect(result.nodes[3].mass).toBeGreaterThan(0);
    }
  });

  it.skipIf(!pinataAvailable)('returns geometries and halfExtents maps', async () => {
    const { buildHierarchicalScenario } = await import('../three/hierarchicalFracture');
    const geo = new THREE.BoxGeometry(2, 2, 2, 1, 1, 1);
    const result = buildHierarchicalScenario(geo, {
      supportFragmentCount: 4,
      subsupportFragmentCount: 1,
    });
    geo.dispose();

    expect(result.geometries).toBeInstanceOf(Map);
    expect(result.halfExtents).toBeInstanceOf(Map);
    expect(result.geometries.size).toBeGreaterThan(0);
  });
});

describe('WASM fallback (optionalCcall)', () => {
  it('optionalCcall returns 0 for missing function', () => {
    // Simulates the behavior in stress.ts when WASM doesn't export hierarchy functions
    const mockModule = {
      ccall: (name: string) => {
        if (name === 'ext_stress_sizeof_hierarchical_chunk_desc') {
          throw new Error('Assertion failed: Cannot call unknown function');
        }
        return 42;
      },
    };

    // Replicate the optionalCcall pattern from stress.ts
    function optionalCcall(mod: any, fnName: string): number {
      try {
        return mod.ccall(fnName, 'number', [], []) as number;
      } catch {
        return 0;
      }
    }

    expect(optionalCcall(mockModule, 'ext_stress_sizeof_hierarchical_chunk_desc')).toBe(0);
    expect(optionalCcall(mockModule, 'some_existing_function')).toBe(42);
  });

  it('createHierarchicalExtSolver guard throws descriptive error when sizes are 0', () => {
    // Simulates what happens in createRuntime when WASM doesn't have hierarchy
    const sizes = { extHierarchicalChunk: 0, extChunkDamage: 0 };

    function guardedCreate(s: typeof sizes) {
      if (!s.extHierarchicalChunk || !s.extChunkDamage) {
        throw new Error(
          'Hierarchical solver not available: WASM module does not export hierarchy functions.',
        );
      }
    }

    expect(() => guardedCreate(sizes)).toThrow('Hierarchical solver not available');
  });
});
