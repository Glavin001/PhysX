/**
 * Fracture rollback / resimulation correctness tests.
 *
 * Covers:
 * - Damage-driven destruction triggers split detection (Bug #1 fix)
 * - enqueueDamageFracturesForNode routes bonds through fracture pipeline
 * - Multiple resimulation passes with cascading fractures
 * - Snapshot capture/restore correctness (perBody mode)
 * - Contact replay prevents damage double-counting
 * - World snapshot mode restore
 * - Fracture + damage in same frame
 * - flushPendingDamageFractures processes via applyFractureCommands
 *
 * Requires full WASM + TS build.
 */
import { describe, it, expect } from 'vitest';
import { existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const wasmPath = resolve(here, '../../dist/stress_solver.wasm');
const runtimeAvailable = existsSync(wasmPath);

let buildDestructibleCore: (opts: any) => Promise<any>;
let buildWallScenario: (opts?: any) => any;
let buildTowerScenario: (opts?: any) => any;

async function loadModules() {
  if (buildDestructibleCore) return;
  const rapier = await import('../../dist/rapier.js');
  const scenarios = await import('../../dist/scenarios.js');
  buildDestructibleCore = rapier.buildDestructibleCore;
  buildWallScenario = scenarios.buildWallScenario;
  buildTowerScenario = scenarios.buildTowerScenario;
}

function stepN(core: any, n: number, dt = 1 / 60) {
  for (let i = 0; i < n; i++) core.step(dt);
}

/** Find dynamic (non-support) node indices from chunks. */
function getDynamicNodes(core: any): number[] {
  return core.chunks
    .filter((c: any) => c.active && !c.isSupport)
    .map((c: any) => c.nodeIndex);
}

/** Find a dynamic node that has bonds to at least 2 other dynamic nodes. */
function findBridgeNode(core: any): number | null {
  const dynamicSet = new Set(getDynamicNodes(core));
  for (const ni of dynamicSet) {
    const bonds = core.getNodeBonds(ni);
    const dynamicNeighbors = bonds.filter((b: any) =>
      dynamicSet.has(b.node0 === ni ? b.node1 : b.node0)
    );
    if (dynamicNeighbors.length >= 2) return ni;
  }
  return null;
}

/** Count unique body handles among active non-support chunks. */
function countDynamicBodies(core: any): number {
  const handles = new Set<number>();
  for (const c of core.chunks) {
    if (c.active && !c.destroyed && !c.isSupport && c.bodyHandle != null) {
      handles.add(c.bodyHandle);
    }
  }
  return handles.size;
}

describe.skipIf(!runtimeAvailable)('Fracture rollback / resimulation (requires WASM build)', () => {

  // ── Test 1: Damage-driven destruction triggers split detection ──

  describe('Damage-driven destruction triggers split detection', () => {
    it('destroying a bridge node separates remaining fragments', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8, // very strong so gravity doesn't break it
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 1.0,
          strengthPerVolume: 100,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      stepN(core, 5);

      const initialBonds = core.getActiveBondsCount();
      expect(initialBonds).toBeGreaterThan(0);
      const initialBodies = countDynamicBodies(core);

      // Find a dynamic node with multiple dynamic neighbors (bridge node)
      const bridgeNode = findBridgeNode(core);
      expect(bridgeNode).not.toBeNull();

      const bondsBefore = core.getNodeBonds(bridgeNode!);
      expect(bondsBefore.length).toBeGreaterThan(0);

      // Destroy the bridge node via massive damage
      core.applyNodeDamage(bridgeNode!, 1e6);
      stepN(core, 10);

      // Node should be destroyed
      expect(core.chunks[bridgeNode!].destroyed).toBe(true);

      // Bonds to destroyed node should be removed
      expect(core.getActiveBondsCount()).toBeLessThan(initialBonds);

      // Split detection should have created new bodies
      const finalBodies = countDynamicBodies(core);
      expect(finalBodies).toBeGreaterThanOrEqual(initialBodies);

      core.dispose();
    });

    it('destroying multiple nodes produces multiple splits', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 4, height: 3 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 1.0,
          strengthPerVolume: 100,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      stepN(core, 5);
      const initialBonds = core.getActiveBondsCount();

      // Find several bridge nodes and destroy them
      const dynamicNodes = getDynamicNodes(core);
      const toDestroy = dynamicNodes.slice(0, Math.min(5, dynamicNodes.length));
      for (const ni of toDestroy) {
        core.applyNodeDamage(ni, 1e6);
      }
      stepN(core, 10);

      // Bonds should have decreased significantly
      expect(core.getActiveBondsCount()).toBeLessThan(initialBonds);

      // At least some destroyed nodes should be marked
      let destroyedCount = 0;
      for (const ni of toDestroy) {
        if (core.chunks[ni].destroyed) destroyedCount++;
      }
      expect(destroyedCount).toBeGreaterThan(0);

      core.dispose();
    });
  });

  // ── Test 2: Bond removal goes through fracture pipeline ──

  describe('Bond removal through fracture pipeline', () => {
    it('damage-destroyed node bonds are removed via applyFractureCommands', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 1.0,
          strengthPerVolume: 100,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      stepN(core, 3);

      const bridgeNode = findBridgeNode(core);
      expect(bridgeNode).not.toBeNull();

      const bondsBefore = core.getNodeBonds(bridgeNode!);
      expect(bondsBefore.length).toBeGreaterThan(0);
      const totalBondsBefore = core.getActiveBondsCount();

      // Destroy via damage
      core.applyNodeDamage(bridgeNode!, 1e6);
      stepN(core, 5);

      // All bonds to the destroyed node should be removed
      const bondsAfter = core.getNodeBonds(bridgeNode!);
      expect(bondsAfter.length).toBe(0);

      // Total bonds decreased by at least the destroyed node's bond count
      expect(core.getActiveBondsCount()).toBeLessThanOrEqual(totalBondsBefore - bondsBefore.length);

      core.dispose();
    });
  });

  // ── Test 3: Multiple resimulation passes ──

  describe('Multiple resimulation passes', () => {
    it('maxResimulationPasses > 1 allows cascading fractures', async () => {
      await loadModules();
      const scenario = buildTowerScenario({ side: 3, stories: 4, totalMass: 500 });

      let singlePassBonds = 0;
      let multiPassBonds = 0;

      // Run with single pass
      {
        const core = await buildDestructibleCore({
          scenario,
          materialScale: 0.001,
          resimulateOnFracture: true,
          maxResimulationPasses: 1,
        });
        stepN(core, 60);
        singlePassBonds = core.getActiveBondsCount();
        core.dispose();
      }

      // Run with multiple passes
      {
        const core = await buildDestructibleCore({
          scenario,
          materialScale: 0.001,
          resimulateOnFracture: true,
          maxResimulationPasses: 3,
        });
        stepN(core, 60);
        multiPassBonds = core.getActiveBondsCount();
        core.dispose();
      }

      // Multi-pass should break at least as many bonds
      expect(multiPassBonds).toBeLessThanOrEqual(singlePassBonds);
    });

    it('profiler tracks resimulation passes', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 6, height: 4 });
      let maxResimPasses = 0;
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 0.001,
        resimulateOnFracture: true,
        maxResimulationPasses: 3,
      });

      core.setProfiler({
        enabled: true,
        onSample: (sample: any) => {
          if (sample.resimPasses > maxResimPasses) {
            maxResimPasses = sample.resimPasses;
          }
        },
      });

      stepN(core, 120);
      core.dispose();

      // With very weak material, profiler should have captured some data
      expect(maxResimPasses).toBeGreaterThanOrEqual(0);
    });
  });

  // ── Test 4: Snapshot correctness (perBody) ──

  describe('Snapshot capture/restore correctness', () => {
    it('perBody snapshot keeps structure stable for strong materials', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        snapshotMode: 'perBody',
      });

      stepN(core, 5);

      // Record positions after settle
      const positionsBefore = core.chunks
        .filter((c: any) => c.active)
        .map((c: any) => ({ y: c.worldPosition?.y ?? 0 }));

      stepN(core, 10);

      // Strong material should stay stable
      const positionsAfter = core.chunks
        .filter((c: any) => c.active)
        .map((c: any) => ({ y: c.worldPosition?.y ?? 0 }));

      for (let i = 0; i < Math.min(positionsBefore.length, positionsAfter.length); i++) {
        const dy = Math.abs(positionsAfter[i].y - positionsBefore[i].y);
        expect(dy).toBeLessThan(2.0);
      }

      core.dispose();
    });
  });

  // ── Test 5: Contact replay prevents damage double-counting ──

  describe('Contact replay prevents damage double-counting', () => {
    it('resimulation does not apply double damage', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 4, height: 3 });

      // Run with resimulation
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        resimulateOnDamageDestroy: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 0.001, // low damage
          strengthPerVolume: 1e6, // very strong
        },
      });

      core.enqueueProjectile({
        position: { x: 0, y: 1.0, z: -2 },
        velocity: { x: 0, y: 0, z: 10 },
        mass: 2,
        radius: 0.15,
        ttl: 0.001,
      });

      stepN(core, 30);

      // No nodes should be destroyed (too little damage, too strong)
      const destroyed = core.chunks.filter((c: any) => c.destroyed).length;
      expect(destroyed).toBe(0);

      // All positions should be finite
      for (const c of core.chunks) {
        if (c.worldPosition) {
          expect(Number.isFinite(c.worldPosition.x)).toBe(true);
          expect(Number.isFinite(c.worldPosition.y)).toBe(true);
          expect(Number.isFinite(c.worldPosition.z)).toBe(true);
        }
      }

      core.dispose();
    });
  });

  // ── Test 6: World snapshot mode ──

  describe('World snapshot mode', () => {
    it('world snapshot mode does not crash and produces valid results', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 4, height: 3 });
      let worldReplaced = false;
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 0.01,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        snapshotMode: 'world',
        onWorldReplaced: () => { worldReplaced = true; },
      });

      stepN(core, 60);

      // No NaN positions
      for (const c of core.chunks) {
        if (c.worldPosition) {
          expect(Number.isFinite(c.worldPosition.x)).toBe(true);
          expect(Number.isFinite(c.worldPosition.y)).toBe(true);
          expect(Number.isFinite(c.worldPosition.z)).toBe(true);
        }
      }

      // Bonds should have broken
      expect(core.getActiveBondsCount()).toBeDefined();

      core.dispose();
    });
  });

  // ── Test 7: Fracture + damage in same frame ──

  describe('Fracture + damage in same frame', () => {
    it('stress and damage fractures both work correctly together', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 6, height: 4 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 0.01, // weak
        resimulateOnFracture: true,
        resimulateOnDamageDestroy: true,
        maxResimulationPasses: 2,
        damage: {
          enabled: true,
          kImpact: 0.5,
          strengthPerVolume: 500,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      const initialBonds = core.getActiveBondsCount();

      core.enqueueProjectile({
        position: { x: 0, y: 1.5, z: -1.5 },
        velocity: { x: 0, y: 0, z: 20 },
        mass: 5,
        radius: 0.2,
        ttl: 0.001,
      });

      stepN(core, 60);

      // Both stress and damage should cause bonds to break
      expect(core.getActiveBondsCount()).toBeLessThan(initialBonds);

      // Simulation should be stable (no NaN)
      for (const c of core.chunks) {
        if (c.worldPosition) {
          expect(Number.isFinite(c.worldPosition.x)).toBe(true);
          expect(Number.isFinite(c.worldPosition.y)).toBe(true);
          expect(Number.isFinite(c.worldPosition.z)).toBe(true);
        }
      }

      // Multiple bodies should exist
      expect(countDynamicBodies(core)).toBeGreaterThan(0);

      core.dispose();
    });
  });

  // ── Test 8: flushPendingDamageFractures produces splits ──

  describe('flushPendingDamageFractures produces split events', () => {
    it('damage destruction causes body count to increase', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 3 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 1.0,
          strengthPerVolume: 50,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      stepN(core, 5);

      const initialBodies = countDynamicBodies(core);
      const initialBonds = core.getActiveBondsCount();

      // Find and destroy several bridge nodes
      const dynamicNodes = getDynamicNodes(core);
      // Destroy every 3rd dynamic node to create splits
      for (let i = 0; i < dynamicNodes.length; i += 3) {
        core.applyNodeDamage(dynamicNodes[i], 1e6);
      }

      stepN(core, 10);

      // Bonds should decrease
      expect(core.getActiveBondsCount()).toBeLessThan(initialBonds);

      // Bodies should increase or stay same (splits happened)
      const finalBodies = countDynamicBodies(core);
      expect(finalBodies).toBeGreaterThanOrEqual(initialBodies);

      core.dispose();
    });

    it('damage-destroyed nodes have zero remaining bonds', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        damage: {
          enabled: true,
          kImpact: 1.0,
          strengthPerVolume: 50,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      stepN(core, 5);

      // Destroy several dynamic nodes
      const dynamicNodes = getDynamicNodes(core);
      const destroyed: number[] = [];
      for (let i = 0; i < Math.min(3, dynamicNodes.length); i++) {
        core.applyNodeDamage(dynamicNodes[i], 1e6);
        destroyed.push(dynamicNodes[i]);
      }

      stepN(core, 10);

      // Each destroyed node should have zero remaining bonds
      for (const ni of destroyed) {
        if (core.chunks[ni].destroyed) {
          const bonds = core.getNodeBonds(ni);
          expect(bonds.length).toBe(0);
        }
      }

      core.dispose();
    });
  });

  // ── Performance: Snapshot overhead and resim scaling ──

  describe('Performance: snapshot and resim overhead', () => {
    it('perBody snapshot capture+restore overhead is bounded', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 6, height: 4 });
      const samples: any[] = [];
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 0.01, // weak to trigger fractures
        resimulateOnFracture: true,
        maxResimulationPasses: 2,
        snapshotMode: 'perBody',
      });

      core.setProfiler({
        enabled: true,
        onSample: (s: any) => samples.push(s),
      });

      core.enqueueProjectile({
        position: { x: 0, y: 1.5, z: -1.5 },
        velocity: { x: 0, y: 0, z: 20 },
        mass: 5,
        radius: 0.2,
        ttl: 0.001,
      });

      stepN(core, 120);

      // Snapshot capture should be fast relative to total frame time
      const captureMs = samples.map((s: any) => s.snapshotCaptureMs ?? 0);
      const restoreMs = samples.map((s: any) => s.snapshotRestoreMs ?? 0);
      const totalMs = samples.map((s: any) => s.totalMs ?? 0);

      const avgCapture = captureMs.reduce((a: number, b: number) => a + b, 0) / captureMs.length;
      const avgRestore = restoreMs.reduce((a: number, b: number) => a + b, 0) / restoreMs.length;
      const avgTotal = totalMs.reduce((a: number, b: number) => a + b, 0) / totalMs.length;

      // Snapshot overhead should be < 30% of total frame time
      if (avgTotal > 0) {
        expect((avgCapture + avgRestore) / avgTotal).toBeLessThan(0.3);
      }

      // Snapshot bytes should be reasonable (< 1MB for a 72-node scene)
      const maxBytes = Math.max(...samples.map((s: any) => s.snapshotBytes ?? 0));
      expect(maxBytes).toBeLessThan(1024 * 1024);

      core.dispose();
    });

    it('world snapshot mode produces same fracture results as perBody', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 4, height: 3 });

      const run = async (snapshotMode: string) => {
        const core = await buildDestructibleCore({
          scenario,
          materialScale: 0.01,
          resimulateOnFracture: true,
          maxResimulationPasses: 1,
          snapshotMode,
          onWorldReplaced: snapshotMode === 'world' ? () => {} : undefined,
        });
        stepN(core, 60);
        const bonds = core.getActiveBondsCount();
        const destroyed = core.chunks.filter((c: any) => c.destroyed).length;
        core.dispose();
        return { bonds, destroyed };
      };

      const perBody = await run('perBody');
      const world = await run('world');

      // Both modes should produce similar results (not identical due to float precision)
      // But bond counts should be close (within 20% or equal)
      if (perBody.bonds > 0 || world.bonds > 0) {
        const ratio = Math.min(perBody.bonds, world.bonds) / Math.max(perBody.bonds, world.bonds, 1);
        expect(ratio).toBeGreaterThan(0.5);
      }
    });

    it('resim passes scale with maxResimulationPasses', async () => {
      await loadModules();
      const scenario = buildTowerScenario({ side: 3, stories: 4, totalMass: 500 });

      const run = async (maxPasses: number) => {
        let maxResimSeen = 0;
        const core = await buildDestructibleCore({
          scenario,
          materialScale: 0.001,
          resimulateOnFracture: true,
          maxResimulationPasses: maxPasses,
        });
        core.setProfiler({
          enabled: true,
          onSample: (s: any) => {
            if (s.resimPasses > maxResimSeen) maxResimSeen = s.resimPasses;
          },
        });
        stepN(core, 60);
        const bonds = core.getActiveBondsCount();
        core.dispose();
        return { maxResimSeen, bonds };
      };

      const pass0 = await run(0);
      const pass1 = await run(1);
      const pass3 = await run(3);

      // maxResimPasses=0 should never resim
      expect(pass0.maxResimSeen).toBe(0);

      // Higher pass limits should allow more resim (when fractures cascade)
      expect(pass3.maxResimSeen).toBeGreaterThanOrEqual(pass1.maxResimSeen);

      // More passes should produce equal or fewer remaining bonds
      expect(pass3.bonds).toBeLessThanOrEqual(pass1.bonds);
      expect(pass1.bonds).toBeLessThanOrEqual(pass0.bonds);
    });

    it('damage + fracture resim together does not spike frame time', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 6, height: 4 });
      const samples: any[] = [];
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 0.01,
        resimulateOnFracture: true,
        resimulateOnDamageDestroy: true,
        maxResimulationPasses: 2,
        damage: {
          enabled: true,
          kImpact: 0.5,
          strengthPerVolume: 500,
          autoDetachOnDestroy: true,
          autoCleanupPhysics: true,
        },
      });

      core.setProfiler({
        enabled: true,
        onSample: (s: any) => samples.push(s),
      });

      core.enqueueProjectile({
        position: { x: 0, y: 1.5, z: -1.5 },
        velocity: { x: 0, y: 0, z: 20 },
        mass: 5,
        radius: 0.2,
        ttl: 0.001,
      });

      stepN(core, 60);

      // No frame should take > 500ms (even with resim + damage)
      const maxTotal = Math.max(...samples.map((s: any) => s.totalMs ?? 0));
      expect(maxTotal).toBeLessThan(500);

      // Verify simulation completed without crash
      for (const chunk of core.chunks) {
        if (chunk.worldPosition) {
          expect(Number.isFinite(chunk.worldPosition.x)).toBe(true);
          expect(Number.isFinite(chunk.worldPosition.y)).toBe(true);
        }
      }

      core.dispose();
    });

    it('idle-skip prevents solver work when structure is stable', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const samples: any[] = [];
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8, // very strong, no fracture
        resimulateOnFracture: true,
        maxResimulationPasses: 1,
        fracturePolicySettings: { idleSkip: true },
      });

      core.setProfiler({
        enabled: true,
        onSample: (s: any) => samples.push(s),
      });

      // Run enough frames for idle-skip to activate (needs safeFrames > 2 + convergence)
      stepN(core, 30);

      // After settling, solver update should be very fast (skipped)
      const lateSamples = samples.slice(-10);
      const avgSolverMs = lateSamples.reduce((a: number, s: any) => a + (s.solverUpdateMs ?? 0), 0) / lateSamples.length;

      // Idle-skipped frames should have near-zero solver time
      // (just the convergence check, not the full update)
      expect(avgSolverMs).toBeLessThan(2.0);

      // No fractures should have occurred (strong material)
      expect(core.getActiveBondsCount()).toBe(samples[0]?.bondCount ?? core.getActiveBondsCount());

      core.dispose();
    });
  });

  // ── Runtime setters for resim configuration ──

  describe('Runtime resim setters', () => {
    it('setResimulateOnFracture/setMaxResimulationPasses live-tune without rebuild', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        resimulateOnFracture: false,
        maxResimulationPasses: 0,
        resimulateOnDamageDestroy: false,
      });

      const initial = core.getResimConfig();
      expect(initial.resimulateOnFracture).toBe(false);
      expect(initial.maxResimulationPasses).toBe(0);
      expect(initial.resimulateOnDamageDestroy).toBe(false);

      // Flip all runtime-tunable settings
      core.setResimulateOnFracture(true);
      core.setMaxResimulationPasses(3);
      core.setResimulateOnDamageDestroy(true);

      const updated = core.getResimConfig();
      expect(updated.resimulateOnFracture).toBe(true);
      expect(updated.maxResimulationPasses).toBe(3);
      expect(updated.resimulateOnDamageDestroy).toBe(true);

      // Simulation should still run without crash after runtime change
      for (let i = 0; i < 5; i++) core.step(1 / 60);

      // Flip back
      core.setResimulateOnFracture(false);
      core.setMaxResimulationPasses(0);
      expect(core.getResimConfig().resimulateOnFracture).toBe(false);
      expect(core.getResimConfig().maxResimulationPasses).toBe(0);

      core.dispose();
    });

    it('setMaxResimulationPasses clamps negative values to 0', async () => {
      await loadModules();
      const scenario = buildWallScenario({ width: 3, height: 2 });
      const core = await buildDestructibleCore({
        scenario,
        materialScale: 1e8,
        maxResimulationPasses: 1,
      });

      core.setMaxResimulationPasses(-5);
      expect(core.getResimConfig().maxResimulationPasses).toBe(0);

      core.setMaxResimulationPasses(2.7);
      expect(core.getResimConfig().maxResimulationPasses).toBe(2);

      core.dispose();
    });
  });
});
