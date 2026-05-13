import * as THREE from 'three';
import RAPIER from '@dimforge/rapier3d-compat';

import { loadStressSolver } from '../stress.js';
import { initThree } from './scene.js';
import { buildBridge, spawnLoadVehicle } from './buildBridge.js';
import { setupControls } from './controls.js';
import { updateBridge } from './simulation.js';
import { pushEvent } from './ui.js';
import { GRAVITY_DEFAULT } from './constants.js';
import { toleranceFromExponent, scaleStressLimits } from './utils.js';

// Mutable state referenced by the animation loop.
const state = { world: null, bridge: null };

/**
 * Tear down the current physics world and bridge, then rebuild using the
 * current UI slider values.  Three.js scene, renderer, camera and orbit
 * controls are reused – only the physics bodies and bridge meshes are replaced.
 */
function resetScene(scene, stressRuntime) {
  const oldBridge = state.bridge;
  const oldWorld = state.world;

  // --- read current slider values so they survive the reset ----------------
  const gravitySlider = document.getElementById('gravity-slider');
  const strengthSlider = document.getElementById('strength-slider');
  const iterSlider = document.getElementById('iter-slider');
  const toleranceSlider = document.getElementById('tolerance-slider');

  const gravity = gravitySlider ? parseFloat(gravitySlider.value) : GRAVITY_DEFAULT;
  const strengthScale = strengthSlider ? parseFloat(strengthSlider.value) : oldBridge?.strengthScale;
  const maxIterations = iterSlider ? parseInt(iterSlider.value, 10) : oldBridge?.solverSettings?.maxIterations;
  const toleranceExponent = toleranceSlider ? parseFloat(toleranceSlider.value) : oldBridge?.solverSettings?.toleranceExponent;

  // --- tear down old bridge ------------------------------------------------
  if (oldBridge) {
    // Remove projectile meshes & bodies
    (oldBridge.projectiles || []).forEach((p) => {
      p.mesh?.removeFromParent();
      const body = oldWorld?.getRigidBody(p.bodyHandle);
      if (body) oldWorld.removeRigidBody(body);
    });

    // Remove load vehicle
    if (oldBridge.loadVehicle) {
      oldBridge.loadVehicle.mesh?.removeFromParent();
      const body = oldWorld?.getRigidBody(oldBridge.loadVehicle.bodyHandle);
      if (body) oldWorld.removeRigidBody(body);
    }

    // Remove bridge chunk meshes
    (oldBridge.chunks || []).forEach((chunk) => {
      if (chunk.mesh) {
        chunk.mesh.removeFromParent();
        chunk.mesh.geometry?.dispose();
        chunk.mesh.material?.dispose();
      }
    });

    // Remove split body meshes if any
    (oldBridge.splitBodies || []).forEach((handle) => {
      const body = oldWorld?.getRigidBody(handle);
      if (body) oldWorld.removeRigidBody(body);
    });

    // Dispose debug renderer
    if (oldBridge.debugRenderer) {
      oldBridge.debugRenderer.dispose();
    }
  }

  // Remove any remaining non-light objects from the scene (ground, etc.)
  const toRemove = [];
  scene.traverse((obj) => {
    if (obj !== scene && !(obj instanceof THREE.Light)) {
      toRemove.push(obj);
    }
  });
  toRemove.forEach((obj) => {
    obj.removeFromParent();
    if (obj.geometry) obj.geometry.dispose();
    if (obj.material) obj.material.dispose();
  });

  // Free old Rapier world
  if (oldWorld) {
    oldWorld.free();
  }

  // --- build fresh scene with current settings -----------------------------
  const world = new RAPIER.World(new RAPIER.Vector3(0, gravity, 0));
  const bridge = buildBridge(scene, world, stressRuntime);

  // Apply current UI values
  bridge.activeGravity = gravity;
  if (strengthScale != null) {
    bridge.strengthScale = strengthScale;
    bridge.limits = new bridge.limitsCtor(
      scaleStressLimits(bridge.baseLimits, bridge.strengthScale)
    );
  }
  if (maxIterations != null) {
    bridge.solverSettings.maxIterations = maxIterations;
  }
  if (toleranceExponent != null) {
    bridge.solverSettings.toleranceExponent = toleranceExponent;
  }
  bridge.stressProcessor.setSolverParams({
    maxIterations: bridge.solverSettings.maxIterations,
    tolerance: toleranceFromExponent(bridge.solverSettings.toleranceExponent)
  });

  spawnLoadVehicle(world, bridge);

  state.world = world;
  state.bridge = bridge;

  pushEvent('Bridge reset with current settings');
}

async function init() {
  await RAPIER.init();
  const stressRuntime = await loadStressSolver();

  const { scene, renderer, camera, controls } = initThree();

  state.world = new RAPIER.World(new RAPIER.Vector3(0, GRAVITY_DEFAULT, 0));
  state.bridge = buildBridge(scene, state.world, stressRuntime);

  spawnLoadVehicle(state.world, state.bridge);
  setupControls(state, scene, stressRuntime, resetScene);

  state.bridge.stressProcessor.setSolverParams({
    maxIterations: state.bridge.solverSettings.maxIterations,
    tolerance: toleranceFromExponent(state.bridge.solverSettings.toleranceExponent)
  });

  const clock = new THREE.Clock();

  function loop() {
    const delta = clock.getDelta();
    updateBridge(state.world, state.bridge, delta);
    state.world.step();
    if (state.bridge.debugRenderer?.enabled) {
      state.bridge.debugRenderer.update();
    }
    controls.update();
    renderer.render(scene, camera);
    requestAnimationFrame(loop);
  }

  loop();
}

init().catch((err) => {
  console.error('Failed to initialize bridge demo', err);
  pushEvent(`Initialization failed: ${err.message ?? err}`);
});

