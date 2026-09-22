"""Render accepted native wall captures. Importing this module never loads Blender."""
import argparse
import json
import math
from pathlib import Path
import sys
import time


def vector(value, size, label):
    if (not isinstance(value, list) or len(value) != size or
            any(isinstance(x, bool) or not isinstance(x, (int, float)) or not math.isfinite(x) for x in value)):
        raise ValueError(f"{label}: expected {size} finite numbers")
    return value


def position(value):
    """Right-handed basis rotation: PhysX Y-up to Blender Z-up."""
    x, y, z = value
    return x, -z, y


def rotation(value):
    """The same basis conjugation, returned in Blender's wxyz order."""
    x, y, z, w = value
    return w, x, -z, y


def validate_capture(data, diagnostic=False):
    if data.get('schema') != 'physx.native-wall-capture' or data.get('version') != 1:
        raise ValueError('unsupported native wall capture schema')
    if data.get('status') != 'completed' or data.get('failure'):
        raise ValueError('only completed, accepted simulation captures may be rendered')
    if data.get('backend') not in ('cuda', 'cumetal'):
        raise ValueError('capture must identify its real GPU backend')
    meta, summary = data['metadata'], data['summary']
    if meta.get('fps') != 60 or not math.isclose(data['timestep'], 1 / 60, rel_tol=1e-6):
        raise ValueError('capture must contain one committed step per 60 fps frame')
    if not diagnostic and summary.get('localized_damage') is not True:
        raise ValueError('localized damage was not demonstrated; use --diagnostic for a labeled diagnostic render')
    bodies, frames = data['bodies'], data['frames']
    if not frames or len(frames) != summary['frames'] or len(frames) != meta['requested_frames']:
        raise ValueError('incomplete capture frame count')
    ids = set()
    for body in bodies:
        ident = body['id']
        if type(ident) is not int or ident < 0 or ident in ids:
            raise ValueError('invalid or duplicate body ID')
        ids.add(ident)
        color = vector(body['color'], 3, 'color')
        if any(x < 0 or x > 1 for x in color):
            raise ValueError('body color is outside [0,1]')
        if body['shape'] == 'box':
            if any(x <= 0 for x in vector(body['half_extents'], 3, 'half extents')):
                raise ValueError('box dimensions must be positive')
        elif body['shape'] == 'sphere':
            radius = body['radius']
            if not isinstance(radius, (float, int)) or not math.isfinite(radius) or radius <= 0:
                raise ValueError('sphere radius must be positive and finite')
        else:
            raise ValueError('unsupported recorded shape')
    if len(bodies) != meta['width'] * meta['height'] + 1:
        raise ValueError('body count differs from authored wall and projectile')
    broken = set()
    for index, frame in enumerate(frames):
        if frame['frame'] != index or not math.isclose(frame['time'], (index + 1) / 60, rel_tol=1e-6):
            raise ValueError('frames must be contiguous committed steps')
        if len(frame['bodies']) != len(ids) or {p['id'] for p in frame['bodies']} != ids:
            raise ValueError('each frame must record every body exactly once')
        for pose in frame['bodies']:
            vector(pose['position'], 3, 'position')
            q = vector(pose['rotation'], 4, 'rotation xyzw')
            if not math.isclose(sum(x*x for x in q), 1, abs_tol=1e-4):
                raise ValueError('recorded quaternion is not normalized')
            if type(pose['visible']) is not bool:
                raise ValueError('visibility must be recorded explicitly')
        for fracture in frame['fractures']:
            bond = fracture['bond_id']
            if type(bond) is not int or not 0 <= bond < summary['bonds'] or bond in broken:
                raise ValueError('invalid or repeated fracture publication')
            if fracture['chunk0'] not in ids or fracture['chunk1'] not in ids:
                raise ValueError('fracture references an unknown chunk')
            broken.add(bond)
    if len(broken) != summary['broken_bonds']:
        raise ValueError('fracture events do not match the accepted summary')
    ground = meta['ground_y']
    if not isinstance(ground, (int, float)) or not math.isfinite(ground):
        raise ValueError('invalid floor height')
    return data


def render(args):
    import bpy
    from mathutils import Vector
    data = validate_capture(json.loads(Path(args.capture).read_text()), args.diagnostic)
    destination = Path(args.frames).resolve()
    if not destination.is_dir():
        raise ValueError('launcher must prepare the confined frame directory')
    selected = range(len(data['frames'])) if args.sample_frame is None else [args.sample_frame]
    for index in selected:
        if not 0 <= index < len(data['frames']):
            raise ValueError('sample frame is outside the capture')
        if (destination / f'frame_{index:06d}.png').exists():
            raise ValueError('refusing to overwrite a rendered frame')
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    runtime = {'blender_version': bpy.app.version_string, 'requested_engine': args.engine}
    if args.engine == 'eevee':
        scene.render.engine = 'BLENDER_EEVEE_NEXT'
        scene.eevee.taa_render_samples = args.samples
    else:
        scene.render.engine = 'CYCLES'
        scene.cycles.samples = args.samples
        scene.cycles.use_denoising = True
        scene.cycles.device = 'CPU'
        if args.engine == 'cycles-metal':
            prefs = bpy.context.preferences.addons['cycles'].preferences
            prefs.compute_device_type = 'METAL'
            prefs.get_devices()
            selected_devices = []
            for device in prefs.devices:
                device.use = device.type == 'METAL'
                if device.use:
                    selected_devices.append({'name': device.name, 'type': device.type, 'id': device.id})
            if not selected_devices:
                raise RuntimeError('No Cycles Metal GPU is available; use --engine cycles-cpu explicitly for CPU rendering')
            scene.cycles.device = 'GPU'
            runtime['cycles_devices'] = selected_devices
    runtime['engine'] = scene.render.engine
    runtime['render_device'] = 'CPU' if args.engine == 'cycles-cpu' else 'GPU'
    # Blender disables gpu.platform queries in background mode. Eevee has no
    # CPU rendering path; the launcher explicitly selects its Metal backend.
    runtime['graphics_backend'] = 'METAL' if args.engine != 'cycles-cpu' else None
    runtime['graphics_backend_evidence'] = 'explicit Blender --gpu-backend metal; raster engines have no CPU path'
    if args.engine != 'cycles-cpu':
        prefs = bpy.context.preferences.addons['cycles'].preferences
        prefs.compute_device_type = 'METAL'
        prefs.get_devices()
        runtime['available_metal_devices'] = [{'name': d.name, 'type': d.type, 'id': d.id}
                                              for d in prefs.devices if d.type == 'METAL']
        if not runtime['available_metal_devices']:
            raise RuntimeError('No Metal GPU is available; refusing CPU fallback')
    print('RENDER_BACKEND ' + json.dumps(runtime), flush=True)
    scene.render.resolution_x, scene.render.resolution_y = args.width, args.height
    scene.render.resolution_percentage = 100
    scene.render.fps = 60
    scene.render.threads_mode = 'FIXED'
    scene.render.threads = args.threads
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGB'
    scene.render.image_settings.compression = 15
    scene.render.film_transparent = False
    scene.render.use_file_extension = True
    scene.render.use_persistent_data = True
    scene.render.use_motion_blur = False
    scene.view_settings.view_transform = 'AgX'
    bpy.context.preferences.filepaths.temporary_directory = args.temporary
    world = bpy.data.worlds.new('Studio world')
    world.use_nodes = True
    world.node_tree.nodes['Background'].inputs['Color'].default_value = (.22, .25, .3, 1)
    world.node_tree.nodes['Background'].inputs['Strength'].default_value = .45
    scene.world = world

    def material(name, color):
        result = bpy.data.materials.new(name)
        result.diffuse_color = (*color, 1)
        result.use_nodes = True
        shader = result.node_tree.nodes.get('Principled BSDF')
        shader.inputs['Base Color'].default_value = (*color, 1)
        shader.inputs['Roughness'].default_value = .65
        return result

    objects = {}
    for body in data['bodies']:
        if body['shape'] == 'box':
            bpy.ops.mesh.primitive_cube_add(size=2)
            # The primitive's local axes are converted with the same basis as
            # the recorded poses; conjugated rotation then yields C*R*shape.
            x, y, z = body['half_extents']
            bpy.context.object.scale = (x, z, y)
        else:
            bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=body['radius'])
            for polygon in bpy.context.object.data.polygons:
                polygon.use_smooth = True
        obj = bpy.context.object
        obj.name = f'recorded_body_{body["id"]}'
        obj.rotation_mode = 'QUATERNION'
        obj.data.materials.append(material(obj.name, body['color']))
        objects[body['id']] = obj
    meta = data['metadata']
    width, height = meta['width'], meta['height']
    bpy.ops.mesh.primitive_plane_add(size=max(width, height) * 12, location=(0, 0, meta['ground_y']))
    bpy.context.object.data.materials.append(material('Floor', (.12, .14, .17)))
    target = Vector((0, 0, height * .43))
    bpy.ops.object.camera_add(location=(width * .9, width * 1.7 + 4, height * .95 + 2))
    camera = bpy.context.object
    camera.rotation_euler = (target - camera.location).to_track_quat('-Z', 'Y').to_euler()
    camera.data.lens = 44
    camera.data.clip_end = 1000
    scene.camera = camera
    for name, location, energy, size in (
            ('Key', (width, 4, height + 8), 2200, 8),
            ('Fill', (-width, -4, height + 4), 1600, 7)):
        bpy.ops.object.light_add(type='AREA', location=location)
        light = bpy.context.object
        light.name, light.data.energy, light.data.shape, light.data.size = name, energy, 'DISK', size
        light.rotation_euler = (target - light.location).to_track_quat('-Z', 'Y').to_euler()
    frame_seconds = []
    for index in selected:
        started = time.perf_counter()
        frame = data['frames'][index]
        # No keyframes, interpolation, rigid-body modifiers or procedural fracture.
        for pose in frame['bodies']:
            obj = objects[pose['id']]
            obj.location = position(pose['position'])
            obj.rotation_quaternion = rotation(pose['rotation'])
            obj.hide_render = not pose['visible']
        scene.frame_set(index + 1)
        scene.render.filepath = str(destination / f'frame_{index:06d}.png')
        bpy.ops.render.render(write_still=True)
        frame_seconds.append(time.perf_counter() - started)
        print(f'RECORDED_FRAME {index} time={frame["time"]} render_seconds={frame_seconds[-1]:.6f}', flush=True)
    runtime['frame_seconds'] = frame_seconds
    runtime['frames_seconds'] = sum(frame_seconds)
    runtime['first_frame_seconds'] = frame_seconds[0]
    runtime['subsequent_frames_seconds'] = sum(frame_seconds[1:])
    runtime['timing_scope'] = 'pose update, frame render and PNG write; first frame includes lazy shader initialization'
    (destination.parent / 'renderer-runtime.json').write_text(json.dumps(runtime, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', required=True)
    parser.add_argument('--frames', required=True)
    parser.add_argument('--temporary', required=True)
    parser.add_argument('--sample-frame', type=int)
    parser.add_argument('--width', type=int, default=1920)
    parser.add_argument('--height', type=int, default=1080)
    parser.add_argument('--samples', type=int, default=8)
    parser.add_argument('--engine', choices=('eevee', 'cycles-metal', 'cycles-cpu'), default='eevee')
    parser.add_argument('--threads', type=int, default=4)
    parser.add_argument('--diagnostic', action='store_true')
    render(parser.parse_args(sys.argv[sys.argv.index('--') + 1:]))


if __name__ == '__main__':
    main()
