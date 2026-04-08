/**
 * Hierarchical Bridge Demo
 *
 * A bridge deck with multi-level hierarchical fracture.
 * The bridge spans between two support posts, with the deck slab fractured
 * at two levels. Stress from gravity and projectile impacts break support-level
 * bonds first, then subsupport detail is revealed as pieces take further damage.
 *
 * Click to shoot projectiles at the bridge deck.
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
  bridge: {
    span: 10.0,
    width: 3.0,
    deckThickness: 0.4,
    deckHeight: 4.0,
    supportFragments: 14,
    subsupportFragments: 4,
    density: 2400,
  },
  projectile: {
    radius: 0.25,
    mass: 10_000,
    speed: 18,
  },
  solver: {
    gravity: -9.81,
    materialScale: 3e7,
  },
  physics: {
    debrisCollisionMode: 'noDebrisPairs' as string,
    friction: 0.3,
    restitution: 0.0,
    contactForceScale: 20,
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
scene.background = new THREE.Color(0x060a14);
scene.fog = new THREE.FogExp2(0x060a14, 0.012);

const camera = new THREE.PerspectiveCamera(
  55,
  canvas.clientWidth / canvas.clientHeight,
  0.1,
  200,
);
camera.position.set(0, 6, 16);

const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 3.5, 0);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.update();

// Lights
scene.add(new THREE.AmbientLight(0xffffff, 0.35));

const dirLight = new THREE.DirectionalLight(0xffeedd, 1.0);
dirLight.position.set(12, 16, 10);
dirLight.castShadow = true;
dirLight.shadow.mapSize.set(2048, 2048);
dirLight.shadow.camera.left = -15;
dirLight.shadow.camera.right = 15;
dirLight.shadow.camera.top = 12;
dirLight.shadow.camera.bottom = -4;
scene.add(dirLight);

// Ground plane
const groundGeo = new THREE.PlaneGeometry(80, 80);
const groundMat = new THREE.MeshStandardMaterial({
  color: 0x121828,
  roughness: 0.9,
  metalness: 0.05,
});
const groundMesh = new THREE.Mesh(groundGeo, groundMat);
groundMesh.rotation.x = -Math.PI / 2;
groundMesh.position.y = -0.35;
groundMesh.receiveShadow = true;
scene.add(groundMesh);

// Support posts (visual only — the pinned chunks act as supports)
const postMat = new THREE.MeshStandardMaterial({ color: 0x556677, roughness: 0.8, metalness: 0.1 });
const postGeo = new THREE.BoxGeometry(1.2, CONFIG.bridge.deckHeight, CONFIG.bridge.width);
const leftPost = new THREE.Mesh(postGeo, postMat);
leftPost.position.set(-CONFIG.bridge.span * 0.5 - 0.1, CONFIG.bridge.deckHeight * 0.5 - 0.35, 0);
leftPost.castShadow = true;
leftPost.receiveShadow = true;
scene.add(leftPost);

const rightPost = new THREE.Mesh(postGeo, postMat);
rightPost.position.set(CONFIG.bridge.span * 0.5 + 0.1, CONFIG.bridge.deckHeight * 0.5 - 0.35, 0);
rightPost.castShadow = true;
rightPost.receiveShadow = true;
scene.add(rightPost);

// ── Stats panel ───────────────────────────────────────────────

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
  const { span, width, deckThickness, deckHeight, supportFragments, subsupportFragments, density } = CONFIG.bridge;

  // 1. Create deck slab geometry elevated to deckHeight
  const geometry = new THREE.BoxGeometry(span, deckThickness, width, 4, 1, 2);

  const result = buildHierarchicalFragments(geometry, {
    supportFragmentCount: supportFragments,
    subsupportFragmentCount: subsupportFragments,
    worldOffset: { x: 0, y: deckHeight, z: 0 },
    density,
    pinata,
  });
  geometry.dispose();

  // 2. Pin chunks at the left and right ends as support anchors
  const groundSet = new Set<number>();
  const anchorMargin = span * 0.18; // pin chunks near the ends
  for (let i = 0; i < result.chunks.length; i++) {
    const c = result.chunks[i];
    if (c.isSupport) {
      const absX = Math.abs(c.centroid.x);
      if (absX > span * 0.5 - anchorMargin) {
        groundSet.add(i);
      }
    }
  }

  // 3. Build scenario
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
  const subsupportCount = result.chunks.length - supportCount - 1;
  console.log(
    `Hierarchical bridge: ${result.chunks.length} chunks ` +
    `(${supportCount} support, ${subsupportCount} subsupport, ${groundSet.size} pinned), ` +
    `${result.bonds.length} bonds`,
  );

  // 4. Build core
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
      debrisTtlMs: 12000,
      maxCollidersForDebris: 2,
    },
    smallBodyDamping: {
      mode: 'always' as any,
      colliderCountThreshold: 3,
      minLinearDamping: 2,
      minAngularDamping: 2,
    },
  });

  // 5. Create visuals
  const group = new THREE.Group();
  scene.add(group);

  const deckMaterial = new THREE.MeshStandardMaterial({
    color: 0x998866,
    roughness: 0.6,
    metalness: 0.1,
  });

  const visuals = createDestructibleThreeBundle({
    core,
    scenario,
    root: group,
    hierarchicalGeometries: result.geometries,
    hierarchicalMaterial: deckMaterial,
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
    ttl: 8000,
  });
}

canvas.addEventListener('click', (e) => {
  const rect = canvas.getBoundingClientRect();
  const ndcX = ((e.clientX - rect.left) / rect.width) * 2 - 1;
  const ndcY = -((e.clientY - rect.top) / rect.height) * 2 + 1;
  shootProjectile(ndcX, ndcY);
});

// ── Chunk damage ──────────────────────────────────────────────

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
  if (shattered > 0) console.log(`Applied chunk damage to ${shattered} chunks`);
}

const shatteredActors = new Set<number>();
function autoShatterCheck() {
  const core = coreRef;
  if (!CONFIG.hierarchy.autoShatter) return;
  if (!core?.applyChunkDamage || !core.getVisibleChunks) return;

  for (const [actorIndex] of core.actorMap) {
    if (shatteredActors.has(actorIndex)) continue;
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
      // Actor may no longer be valid
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

function bindCheckbox(id: string, obj: Record<string, any>, key: string) {
  const checkbox = document.getElementById(id) as HTMLInputElement | null;
  if (!checkbox) return;
  checkbox.checked = !!obj[key];
  checkbox.addEventListener('change', () => { obj[key] = checkbox.checked; });
}

// Bridge config (deferred)
bindSlider('cfg-deck-span', CONFIG.bridge, 'span', v => v.toFixed(1));
bindSlider('cfg-support-frags', CONFIG.bridge, 'supportFragments');
bindSlider('cfg-subsupport-frags', CONFIG.bridge, 'subsupportFragments');

// Projectile
bindSlider('cfg-proj-radius', CONFIG.projectile, 'radius', v => v.toFixed(2));
bindSlider('cfg-proj-mass', CONFIG.projectile, 'mass', v => v.toLocaleString());
bindSlider('cfg-proj-speed', CONFIG.projectile, 'speed', v => v.toFixed(0));

// Solver
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

// Physics
bindSelect('cfg-debris-collision', CONFIG.physics, 'debrisCollisionMode', v => {
  coreRef?.setDebrisCollisionMode(v as any);
});
bindSlider('cfg-contact-force', CONFIG.physics, 'contactForceScale', v => v.toFixed(0));

// Hierarchy
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

initScene().then(() => {
  (window as any).__demoReady = true;
  loop();
}).catch((err) => {
  console.error('Failed to initialize hierarchical bridge demo:', err);
  const hint = document.querySelector('.viewport-hint');
  if (hint) hint.textContent = `Error: ${err.message}`;
});
