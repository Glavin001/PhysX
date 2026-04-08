import * as THREE from 'three';
import type { DestructibleCore, ScenarioDesc, Vec3 } from '../rapier/types';
import {
  buildBatchedChunkMeshFromScenario,
  buildChunkMeshesFromScenario,
} from './scenario';
import {
  SolverDebugLinesHelper,
  updateBatchedChunkMesh,
  updateChunkMeshes,
  updateProjectileMeshes,
  type BatchedChunkMeshOptions,
  type BatchedChunkMeshResult,
  type ChunkMeshBuildOptions,
  type ChunkMeshBuildResult,
} from './destructible-adapter';

export type CreateDestructibleThreeBundleOptions = {
  core: DestructibleCore;
  scenario?: ScenarioDesc;
  root?: THREE.Group;
  useBatchedMesh?: boolean;
  materials?: { deck?: THREE.Material; support?: THREE.Material };
  chunkMeshOptions?: ChunkMeshBuildOptions;
  batchedMeshOptions?: BatchedChunkMeshOptions;
  includeDebugLines?: boolean;
  initialDebugVisible?: boolean;
  /**
   * Geometries keyed by chunk index, used for hierarchical destruction.
   * When provided alongside a hierarchical scenario, meshes for all chunks
   * (support + subsupport) are created and visibility is driven by Blast's
   * native visible chunk tracking.
   */
  hierarchicalGeometries?: Map<number, THREE.BufferGeometry>;
  /** Material for hierarchical chunk meshes (applied to all levels). */
  hierarchicalMaterial?: THREE.Material;
};

export type DestructibleThreeBundle = {
  object: THREE.Group;
  core: DestructibleCore;
  chunkMeshes: THREE.Mesh[] | null;
  batched: BatchedChunkMeshResult | null;
  debugLines: SolverDebugLinesHelper | null;
  /** Map from chunk index to mesh, available for hierarchical bundles. */
  hierarchicalMeshes: Map<number, THREE.Mesh> | null;
  update: (options?: {
    debug?: boolean;
    updateBVH?: boolean;
    updateProjectiles?: boolean;
  }) => void;
  dispose: () => void;
};

function disposeChunkBuild(
  root: THREE.Group,
  chunkBuild: ChunkMeshBuildResult | null,
) {
  if (!chunkBuild) return;
  for (const mesh of chunkBuild.objects) {
    try {
      root.remove(mesh);
    } catch {}
  }
  try {
    chunkBuild.dispose();
  } catch {}
}

export function createDestructibleThreeBundle(
  options: CreateDestructibleThreeBundleOptions,
): DestructibleThreeBundle {
  const {
    core,
    scenario,
    root = new THREE.Group(),
    useBatchedMesh = false,
    materials,
    chunkMeshOptions,
    batchedMeshOptions,
    includeDebugLines = true,
    initialDebugVisible = false,
    hierarchicalGeometries,
    hierarchicalMaterial,
  } = options;

  let chunkBuild: ChunkMeshBuildResult | null = null;
  let batchedBuild: BatchedChunkMeshResult | null = null;
  const hierarchicalMeshMap: Map<number, THREE.Mesh> | null =
    core.isHierarchical && hierarchicalGeometries ? new Map() : null;

  if (hierarchicalMeshMap && hierarchicalGeometries) {
    // Hierarchical mode: create meshes for all chunks with geometry.
    // Initially only support-level chunks (visible) are shown.
    const mat = hierarchicalMaterial ?? new THREE.MeshStandardMaterial({ color: 0x888888 });
    for (const [chunkIndex, geom] of hierarchicalGeometries) {
      const mesh = new THREE.Mesh(geom, mat);
      mesh.visible = false; // Visibility driven by Blast's visible chunk query
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      root.add(mesh);
      hierarchicalMeshMap.set(chunkIndex, mesh);
    }
  } else if (scenario) {
    if (useBatchedMesh) {
      batchedBuild = buildBatchedChunkMeshFromScenario(core, scenario, batchedMeshOptions);
      root.add(batchedBuild.batchedMesh);
    } else {
      chunkBuild = buildChunkMeshesFromScenario(core, scenario, materials, chunkMeshOptions);
      for (const mesh of chunkBuild.objects) {
        root.add(mesh);
      }
    }
  }

  let debugHelper: SolverDebugLinesHelper | null = null;
  if (includeDebugLines) {
    debugHelper = new SolverDebugLinesHelper();
    debugHelper.object.visible = initialDebugVisible;
    root.add(debugHelper.object);
  }

  // Hierarchical visibility update: query Blast for visible chunks per actor
  // and show/hide meshes accordingly.
  const tmpVec = new THREE.Vector3();
  const tmpQuat = new THREE.Quaternion();

  function updateHierarchicalMeshes() {
    if (!hierarchicalMeshMap || !core.getVisibleChunks) return;

    // Hide all hierarchical meshes first.
    for (const mesh of hierarchicalMeshMap.values()) {
      mesh.visible = false;
    }

    // For each actor, get visible chunks and show their meshes.
    for (const [actorIndex, { bodyHandle }] of core.actorMap) {
      const visibleChunks = core.getVisibleChunks(actorIndex);
      const body = core.world.getRigidBody(bodyHandle);
      if (!body) continue;

      const translation = body.translation();
      const rotation = body.rotation();

      for (const chunkIdx of visibleChunks) {
        const mesh = hierarchicalMeshMap.get(chunkIdx);
        if (!mesh) continue;
        mesh.visible = true;

        // Position mesh at body's world position + chunk's local offset.
        const chunk = core.chunks[chunkIdx];
        if (chunk) {
          tmpQuat.set(rotation.x, rotation.y, rotation.z, rotation.w);
          tmpVec.set(
            chunk.baseLocalOffset.x,
            chunk.baseLocalOffset.y,
            chunk.baseLocalOffset.z,
          ).applyQuaternion(tmpQuat);
          mesh.position.set(
            translation.x + tmpVec.x,
            translation.y + tmpVec.y,
            translation.z + tmpVec.z,
          );
          mesh.quaternion.copy(tmpQuat);
        }
      }
    }
  }

  return {
    object: root,
    core,
    chunkMeshes: chunkBuild?.objects ?? null,
    batched: batchedBuild,
    debugLines: debugHelper,
    hierarchicalMeshes: hierarchicalMeshMap,
    update: (updateOptions) => {
      if (hierarchicalMeshMap) {
        updateHierarchicalMeshes();
      } else if (batchedBuild) {
        updateBatchedChunkMesh(core, batchedBuild.batchedMesh, batchedBuild.chunkToInstanceId, {
          updateBVH: updateOptions?.updateBVH,
        });
      } else if (chunkBuild) {
        updateChunkMeshes(core, chunkBuild.objects);
      }

      if (updateOptions?.updateProjectiles ?? true) {
        updateProjectileMeshes(core, root);
      }

      if (debugHelper) {
        const showDebug = updateOptions?.debug ?? initialDebugVisible;
        if (showDebug) {
          debugHelper.update(core, core.getSolverDebugLines(), true);
        } else {
          debugHelper.update(core, [], false);
        }
      }
    },
    dispose: () => {
      if (hierarchicalMeshMap) {
        for (const mesh of hierarchicalMeshMap.values()) {
          try { root.remove(mesh); } catch {}
          try { mesh.geometry.dispose(); } catch {}
        }
        hierarchicalMeshMap.clear();
      }

      if (batchedBuild) {
        try {
          root.remove(batchedBuild.batchedMesh);
        } catch {}
        try {
          batchedBuild.dispose();
        } catch {}
      }

      disposeChunkBuild(root, chunkBuild);

      if (debugHelper) {
        try {
          root.remove(debugHelper.object);
        } catch {}
        try {
          debugHelper.dispose();
        } catch {}
      }
    },
  };
}
