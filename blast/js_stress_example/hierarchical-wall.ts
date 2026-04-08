/**
 * Hierarchical Wall Demo
 *
 * Multi-level destruction using Blast's native chunk hierarchy.
 * The wall fractures at two levels:
 *   1. Support level — large pieces connected by stress bonds
 *   2. Subsupport level — detail fragments revealed by chunk damage
 *
 * Click to shoot projectiles (breaks bonds via stress).
 * Use "Shatter Pieces" to apply chunk damage and reveal sub-fragments.
 */

import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import Stats from 'three/addons/libs/stats.module.js';
import * as pinata from '@dgreenheck/three-pinata';
import { buildDestructibleCore } from 'blast-stress-solver/rapier';
import type { DestructibleCore } from 'blast-stress-solver/rapier';
import {
  createDestructibleThreeBundle,
  RapierDebugRenderer,
  buildHierarchicalFragments,
} from 'blast-stress-solver/three';
import type { DestructibleThreeBundle } from 'blast-stress-solver/three';

// ── Config ────────────────────────────────────────────────────

const CONFIG = {
  wall: {
    span: 6.0,
    height: 3.0,
    thickness: 0.32,
    supportFragments: 10,
    subsupportFragments: 4,
    density: 2400,
  },
  projectile: {
    radius: 0.35,
    mass: 15_000,
    speed: 20,
  },
  solver: {
    gravity: -9.81,
    materialScale: 1e8,
  },
  physics: {
    debrisCollisionMode: 'all' as string,
    friction: 0.25,
    restitution: 0.0,
    contactForceScale: 30,
  },
  hierarchy: {
    autoShatter: false,
    chunkDamageAmount: 100,
  },
};

// ── Three.js setup ────────────────────────────────────────────

const canvas = document.getElementById('demo-canvas') as HTMLCanvasElement;
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.setSize(canvas.clientWidth, canvas.clientHeight, false);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0a0d13);
scene.fog = new THREE.FogExp2(0x0a0d13, 0.02);

const camera = new THREE.PerspectiveCamera(
  55,
  canvas.clientWidth / canvas.clientHeight,
  0.1,
  200,
);
camera.position.set(0, 3, 12);

const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 1.5, 0);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.update();

// Lights
const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
scene.add(ambientLight);

const dirLight = new THREE.DirectionalLight(0xffeedd, 1.0);
dirLight.position.set(8, 14, 10);
dirLight.castShadow = true;
dirLight.shadow.mapSize.set(2048, 2048);
dirLight.shadow.camera.left = -15;
dirLight.shadow.camera.right = 15;
dirLight.shadow.camera.top = 15;
dirLight.shadow.camera.bottom = -5;
scene.add(dirLight);

// Ground plane
const groundGeo = new THREE.PlaneGeometry(60, 60);
const groundMat = new THREE.MeshStandardMaterial({
  color: 0x1a1e2f,
  roughness: 0.85,
  metalness: 0.1,
});
const groundMesh = new THREE.Mesh(groundGeo, groundMat);
groundMesh.rotation.x = -Math.PI / 2;
groundMesh.position.y = -0.35;
groundMesh.receiveShadow = true;
scene.add(groundMesh);

// ── Stats panel (FPS / MS / MB) ───────────────────────────────

const stats = new Stats();
stats.dom.style.position = 'absolute';
stats.dom.style.top = '0';
stats.dom.style.left = '0';
(document.querySelector('.viewport') as HTMLElement)?.appendChild(stats.dom);

// ── Perf tracking ─────────────────────────────────────────────

let _physicsMs = 0;
let _renderMs = 0;
const EMA = 0.12;

function updatePerfStats() {
  const el = (id: string) => document.getElementById(id);
  el('stat-physics-ms')!.textContent = _physicsMs.toFixed(1) + ' ms';
  el('stat-render-ms')!.textContent = _renderMs.toFixed(1) + ' ms';
  el('stat-draw-calls')!.textContent = String(renderer.info.render.calls);
  el('stat-triangles')!.textContent = renderer.info.render.triangles.toLocaleString();
}

// ── Status HUD ────────────────────────────────────────────────

function updateStatus(core: DestructibleCore) {
  const el = (id: string) => document.getElementById(id);
  el('stat-bodies')!.textContent = String(core.getRigidBodyCount());
  el('stat-bonds')!.textContent = String(core.getActiveBondsCount());
  el('stat-projectiles')!.textContent = String(core.projectiles.length);

  // Hierarchy info
  const totalChunks = core.getChunkCount?.() ?? core.chunks.length;
  let visibleCount = 0;
  if (core.getVisibleChunks) {
    for (const [actorIndex] of core.actorMap) {
      visibleCount += (core.getVisibleChunks(actorIndex) ?? []).length;
    }
  }
  el('stat-chunks')!.textContent = `${visibleCount} visible / ${totalChunks} total`;
  el('stat-actors')!.textContent = String(core.actorMap.size);
}

// ── Main ──────────────────────────────────────────────────────

let coreRef: DestructibleCore | null = null;
let visualsRef: DestructibleThreeBundle | null = null;
let rapierDebug: RapierDebugRenderer | null = null;
let showDebug = false;

async function initScene() {
  const { span, height, thickness, supportFragments, subsupportFragments, density } = CONFIG.wall;

  // 1. Create wall geometry and fracture hierarchically
  const geometry = new THREE.BoxGeometry(span, height, thickness, 2, 3, 1);

  const result = buildHierarchicalFragments(geometry, {
    supportFragmentCount: supportFragments,
    subsupportFragmentCount: subsupportFragments,
    worldOffset: { x: 0, y: height * 0.5, z: 0 },
    density,
    pinata,
  });
  geometry.dispose();

  // 2. Find bottom support chunks to pin as ground anchors
  const groundSet = new Set<number>();
  const bottomThreshold = 0.6;
  for (let i = 0; i < result.chunks.length; i++) {
    if (result.chunks[i].isSupport && result.chunks[i].centroid.y < bottomThreshold) {
      groundSet.add(i);
    }
  }

  // 3. Build scenario with hierarchy and proper fragment sizes
  const fragmentSizes = result.chunks.map((_, i) => {
    const he = result.halfExtents.get(i);
    return he
      ? { x: he.x * 2, y: he.y * 2, z: he.z * 2 }
      : { x: 0.2, y: 0.2, z: 0.2 };
  });

  const nodes = result.chunks.map((c, i) => ({
    centroid: c.centroid,
    mass: groundSet.has(i) ? 0 : c.mass,
    volume: c.volume,
  }));

  const scenario = {
    nodes,
    bonds: result.bonds,
    hierarchicalChunks: result.chunks.map((c, i) => ({
      ...c,
      mass: groundSet.has(i) ? 0 : c.mass,
    })),
    parameters: { fragmentSizes } as Record<string, unknown>,
  };

  const supportCount = result.chunks.filter(c => c.isSupport).length;
  const subsupportCount = result.chunks.length - supportCount - 1; // minus root
  console.log(
    `Hierarchical wall: ${result.chunks.length} chunks ` +
    `(${supportCount} support, ${subsupportCount} subsupport), ` +
    `${result.bonds.length} bonds`,
  );

  // 4. Build destructible core
  const core = await buildDestructibleCore({
    scenario,
    gravity: CONFIG.solver.gravity,
    materialScale: CONFIG.solver.materialScale,
    friction: CONFIG.physics.friction,
    restitution: CONFIG.physics.restitution,
    contactForceScale: CONFIG.physics.contactForceScale,
    debrisCollisionMode: CONFIG.physics.debrisCollisionMode as any,
    damage: { enabled: false },
    debrisCleanup: {
      mode: 'always' as any,
      debrisTtlMs: 15000,
      maxCollidersForDebris: 2,
    },
    smallBodyDamping: {
      mode: 'always' as any,
      colliderCountThreshold: 3,
      minLinearDamping: 2,
      minAngularDamping: 2,
    },
  });

  // 5. Create visuals with hierarchical geometries
  const group = new THREE.Group();
  scene.add(group);

  const wallMaterial = new THREE.MeshStandardMaterial({
    color: 0xbb8844,
    roughness: 0.7,
    metalness: 0.1,
  });

  const visuals = createDestructibleThreeBundle({
    core,
    scenario,
    root: group,
    hierarchicalGeometries: result.geometries,
    hierarchicalMaterial: wallMaterial,
    includeDebugLines: true,
  });

  rapierDebug?.dispose();
  rapierDebug = new RapierDebugRenderer(scene, core.world as any, { enabled: showDebug });

  coreRef = core;
  visualsRef = visuals;
}

// ── Projectile shooting ───────────────────────────────────────

function shootProjectile(ndcX: number, ndcY: number) {
  const core = coreRef;
  if (!core) return;

  const raycaster = new THREE.Raycaster();
  raycaster.setFromCamera(new THREE.Vector2(ndcX, ndcY), camera);
  const dir = raycaster.ray.direction.clone().normalize();

  core.enqueueProjectile({
    position: {
      x: camera.position.x,
      y: camera.position.y,
      z: camera.position.z,
    },
    velocity: {
      x: dir.x * CONFIG.projectile.speed,
      y: dir.y * CONFIG.projectile.speed,
      z: dir.z * CONFIG.projectile.speed,
    },
    radius: CONFIG.projectile.radius,
    mass: CONFIG.projectile.mass,
    ttl: 6000,
  });
}

canvas.addEventListener('click', (e) => {
  const rect = canvas.getBoundingClientRect();
  const ndcX = ((e.clientX - rect.left) / rect.width) * 2 - 1;
  const ndcY = -((e.clientY - rect.top) / rect.height) * 2 + 1;
  shootProjectile(ndcX, ndcY);
});

// ── Chunk damage (subsupport cascade) ─────────────────────────

/** Apply chunk damage to all non-root actors, revealing subsupport pieces. */
function shatterDetachedPieces() {
  const core = coreRef;
  if (!core?.applyChunkDamage || !core.getVisibleChunks) return;

  let shattered = 0;
  for (const [actorIndex] of core.actorMap) {
    const visibleChunks = core.getVisibleChunks(actorIndex);
    if (visibleChunks.length === 0) continue;

    const damages = visibleChunks.map(chunkIndex => ({
      chunkIndex,
      damage: CONFIG.hierarchy.chunkDamageAmount,
    }));

    try {
      core.applyChunkDamage(actorIndex, damages);
      shattered += visibleChunks.length;
    } catch (e) {
      console.warn(`Failed to shatter actor ${actorIndex}:`, e);
    }
  }
  if (shattered > 0) {
    console.log(`Applied chunk damage to ${shattered} chunks`);
  }
}

// Auto-shatter: track actors and apply chunk damage to newly-detached ones
const shatteredActors = new Set<number>();
function autoShatterCheck() {
  const core = coreRef;
  if (!CONFIG.hierarchy.autoShatter) return;
  if (!core?.applyChunkDamage || !core.getVisibleChunks) return;

  for (const [actorIndex] of core.actorMap) {
    if (shatteredActors.has(actorIndex)) continue;
    // Check if this actor has detached (more than one actor means splits happened)
    if (core.actorMap.size <= 1) continue;

    const visibleChunks = core.getVisibleChunks(actorIndex);
    if (visibleChunks.length === 0) continue;

    const damages = visibleChunks.map(chunkIndex => ({
      chunkIndex,
      damage: CONFIG.hierarchy.chunkDamageAmount,
    }));

    try {
      core.applyChunkDamage(actorIndex, damages);
      shatteredActors.add(actorIndex);
    } catch {
      // May fail if actor no longer valid
    }
  }
}

// ── UI wiring ─────────────────────────────────────────────────

document.getElementById('btn-reset')?.addEventListener('click', async () => {
  visualsRef?.dispose();
  coreRef?.dispose();
  coreRef = null;
  visualsRef = null;
  shatteredActors.clear();
  await initScene();
});

document.getElementById('btn-debug')?.addEventListener('click', () => {
  showDebug = !showDebug;
  rapierDebug?.setEnabled(showDebug);
  const btn = document.getElementById('btn-debug')!;
  btn.textContent = showDebug ? '◈ Hide Debug' : '◇ Show Debug';
});

document.getElementById('btn-shatter')?.addEventListener('click', () => {
  shatterDetachedPieces();
});

// Config sliders
function bindSlider(id: string, obj: Record<string, any>, key: string, fmt?: (v: number) => string) {
  const slider = document.getElementById(id) as HTMLInputElement | null;
  const display = document.getElementById(id + '-value');
  if (!slider) return;
  slider.value = String(obj[key]);
  if (display) display.textContent = fmt ? fmt(obj[key]) : String(obj[key]);
  slider.addEventListener('input', () => {
    const v = parseFloat(slider.value);
    obj[key] = v;
    if (display) display.textContent = fmt ? fmt(v) : String(v);
  });
}

function bindSelect(id: string, obj: Record<string, any>, key: string, onChange?: (v: string) => void) {
  const select = document.getElementById(id) as HTMLSelectElement | null;
  if (!select) return;
  select.value = String(obj[key]);
  select.addEventListener('change', () => {
    obj[key] = select.value;
    onChange?.(select.value);
  });
}

function bindCheckbox(id: string, obj: Record<string, any>, key: string, onChange?: (v: boolean) => void) {
  const checkbox = document.getElementById(id) as HTMLInputElement | null;
  if (!checkbox) return;
  checkbox.checked = !!obj[key];
  checkbox.addEventListener('change', () => {
    obj[key] = checkbox.checked;
    onChange?.(checkbox.checked);
  });
}

// Wall config (deferred)
bindSlider('cfg-support-frags', CONFIG.wall, 'supportFragments');
bindSlider('cfg-subsupport-frags', CONFIG.wall, 'subsupportFragments');

// Projectile (immediate)
bindSlider('cfg-proj-radius', CONFIG.projectile, 'radius', v => v.toFixed(2));
bindSlider('cfg-proj-mass', CONFIG.projectile, 'mass', v => v.toLocaleString());
bindSlider('cfg-proj-speed', CONFIG.projectile, 'speed', v => v.toFixed(0));

// Solver (deferred)
bindSlider('cfg-gravity', CONFIG.solver, 'gravity', v => v.toFixed(1));
{
  const slider = document.getElementById('cfg-material') as HTMLInputElement | null;
  const display = document.getElementById('cfg-material-value');
  if (slider) {
    const exp = Math.log10(CONFIG.solver.materialScale);
    slider.value = String(exp);
    if (display) display.textContent = `1e${exp.toFixed(0)}`;
    slider.addEventListener('input', () => {
      const e = parseFloat(slider.value);
      CONFIG.solver.materialScale = Math.pow(10, e);
      if (display) display.textContent = `1e${e.toFixed(1)}`;
    });
  }
}

// Physics (live)
bindSelect('cfg-debris-collision', CONFIG.physics, 'debrisCollisionMode', v => {
  coreRef?.setDebrisCollisionMode(v as any);
});
bindSlider('cfg-friction', CONFIG.physics, 'friction', v => v.toFixed(2));
bindSlider('cfg-restitution', CONFIG.physics, 'restitution', v => v.toFixed(2));
bindSlider('cfg-contact-force', CONFIG.physics, 'contactForceScale', v => v.toFixed(0));

// Hierarchy controls
bindCheckbox('cfg-auto-shatter', CONFIG.hierarchy, 'autoShatter');
bindSlider('cfg-chunk-damage', CONFIG.hierarchy, 'chunkDamageAmount', v => v.toFixed(0));

// ── Render loop ───────────────────────────────────────────────

const clock = new THREE.Clock();

function loop() {
  requestAnimationFrame(loop);
  stats.begin();

  const dt = Math.min(clock.getDelta(), 1 / 30);
  controls.update();

  if (coreRef && visualsRef) {
    const t0 = performance.now();
    coreRef.step(dt);
    _physicsMs += ((performance.now() - t0) - _physicsMs) * EMA;

    // Auto-shatter detached pieces if enabled
    autoShatterCheck();

    visualsRef.update({
      debug: showDebug,
      updateBVH: false,
      updateProjectiles: true,
    });
    rapierDebug?.update();
    updateStatus(coreRef);
  }

  const t1 = performance.now();
  renderer.render(scene, camera);
  _renderMs += ((performance.now() - t1) - _renderMs) * EMA;

  updatePerfStats();
  stats.end();
}

// ── Resize ────────────────────────────────────────────────────

function onResize() {
  const w = canvas.clientWidth;
  const h = canvas.clientHeight;
  renderer.setSize(w, h, false);
  camera.aspect = w / h;
  camera.updateProjectionMatrix();
}
window.addEventListener('resize', onResize);

// ── Boot ──────────────────────────────────────────────────────

initScene().then(() => loop()).catch((err) => {
  console.error('Failed to initialize hierarchical wall demo:', err);
  const hint = document.querySelector('.viewport-hint');
  if (hint) hint.textContent = `Error: ${err.message}`;
});
