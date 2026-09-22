"""Repository-contained paths and environments for destruction builds."""

from pathlib import Path
import os
import platform
import json


def contained(path, roots):
    """Resolve symlinks, including existing parents of a new destination."""
    resolved = Path(path).expanduser().resolve()
    if not any(resolved.is_relative_to(Path(root).resolve()) for root in roots):
        raise ValueError(f"Destination escapes the approved repositories: {path} -> {resolved}")
    return resolved


def audit_tree(path, roots):
    """Reject pre-existing redirects before child build tools follow them."""
    path = contained(path, roots)
    if path.exists():
        for base, directories, files in os.walk(path, followlinks=False):
            for name in directories + files:
                candidate = Path(base) / name
                if candidate.is_symlink():
                    contained(candidate, roots)


def local_environment(work, roots, inherited=None):
    work = contained(work, roots)
    env = dict(os.environ if inherited is None else inherited)
    if platform.system() == 'Darwin':
        # /usr/bin compiler/make shims create xcrun caches even with TMPDIR set.
        # Resolve the active selection read-only and call its real tools directly.
        selected = Path(env.get('DEVELOPER_DIR', '/var/db/xcode_select_link')).resolve()
        if selected.suffix == '.app':
            selected /= 'Contents/Developer'
        directories = [selected / 'Toolchains/XcodeDefault.xctoolchain/usr/bin', selected / 'usr/bin']
        env['PATH'] = os.pathsep.join([str(p) for p in directories if p.is_dir()] + [env.get('PATH', '')])
    locations = {
        "TMPDIR": work / "tmp", "TMP": work / "tmp", "TEMP": work / "tmp",
        "CUMETAL_CACHE_DIR": work / "cache/cumetal",
        "CLANG_MODULE_CACHE_PATH": work / "cache/clang",
        "XDG_CACHE_HOME": work / "cache/xdg",
        "CUDA_CACHE_PATH": work / "cache/cuda",
        "CCACHE_DIR": work / "cache/ccache",
        "CCACHE_TEMPDIR": work / "tmp/ccache",
        "LLVM_PROFILE_FILE": work / "profiles/%p.profraw",
        "PYTHONPYCACHEPREFIX": work / "cache/python",
        "PM_PACKAGES_ROOT": work / "cache/packman",
    }
    for key, path in locations.items():
        env[key] = str(contained(path, roots))
    env.update(PYTHONDONTWRITEBYTECODE="1", GIT_OPTIONAL_LOCKS="0",
               CUMETAL_FP64_MODE="ieee64", CMAKE_EXPORT_NO_PACKAGE_REGISTRY="ON",
               xcrun_nocache="1")
    # Never inherit a diagnostic runtime or a process-wide CUDA/Metal override.
    for key in ("DYLD_INSERT_LIBRARIES", "DYLD_LIBRARY_PATH", "LD_PRELOAD",
                "LD_LIBRARY_PATH", "CUMETAL_SYNC_EACH_LAUNCH", "CUMETAL_USE_METAL_DEVICE_ADDRESSES", "DESTDIR",
                "CFLAGS", "CXXFLAGS", "CPPFLAGS", "LDFLAGS", "OBJCFLAGS", "OBJCXXFLAGS",
                "NVCC_PREPEND_FLAGS", "NVCC_APPEND_FLAGS", "CCACHE_PREFIX", "CCACHE_CONFIGPATH"):
        env.pop(key, None)
    return env, locations


def audit_cmake_caches(path, roots):
    """Reject cached redirects before regeneration or installation can use them."""
    if not path.exists():
        return
    output_keys = {'CMAKE_INSTALL_PREFIX', 'PX_OUTPUT_LIB_DIR', 'PX_OUTPUT_BIN_DIR',
                   'PX_GENERATED_INCLUDE_DIR', 'CMAKE_CACHEFILE_DIR',
                   'CMAKE_ARCHIVE_OUTPUT_DIRECTORY', 'CMAKE_LIBRARY_OUTPUT_DIRECTORY',
                   'CMAKE_RUNTIME_OUTPUT_DIRECTORY'}
    for cache in path.rglob('CMakeCache.txt'):
        contained(cache, roots)
        values = {}
        for line in cache.read_text().splitlines():
            if '=' not in line or ':' not in line.split('=', 1)[0]:
                continue
            key, value = line.split('=', 1)
            values[key.split(':')[0]] = value
        for key, value in values.items():
            if not value:
                continue
            configuration_output = any(key.startswith(base + '_') for base in (
                'CMAKE_ARCHIVE_OUTPUT_DIRECTORY', 'CMAKE_LIBRARY_OUTPUT_DIRECTORY',
                'CMAKE_RUNTIME_OUTPUT_DIRECTORY'))
            install_directory = key.startswith('CMAKE_INSTALL_') and key.endswith('DIR')
            if key in output_keys or configuration_output or install_directory:
                destination = Path(value)
                if not destination.is_absolute():
                    base = Path(values.get('CMAKE_INSTALL_PREFIX', cache.parent)) if install_directory else cache.parent
                    if not base.is_absolute():
                        base = cache.parent / base
                    destination = base / destination
                contained(destination, roots)


def audit_test_sources(root, source_paths=None):
    """Conservative audit of SDK test trees, or an explicit narrow source set."""
    import re
    issues = []
    if source_paths is None:
        source_paths = (path for relative in ('demos/blast-stress-demo', 'destruction',
                        'blast/source/sdk/extensions/stressgpu', 'physx/source/gpudestruction')
                        for path in (root / relative).rglob('*'))
    for path in source_paths:
        if path.suffix not in ('.cpp', '.cu', '.h', '.py', '.sh', '.cmake') and path.name != 'CMakeLists.txt':
            continue
        if not path.is_file():
            continue
        path = contained(path, (root,))
        for number, line in enumerate(path.read_text(errors='replace').splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith(('#', '//', '*')):
                continue
            if '${TMPDIR:-/tmp}' in line:
                continue
            if re.search(r'[\"\x27](?:/tmp/|/var/tmp/|/private/tmp/|~/)', line):
                issues.append(f'{path.relative_to(root)}:{number}: external path requires review')
    return issues


def confined_command(command, roots, readonly=False):
    """Public macOS sandbox enforces the write boundary even for tool caches.

    Failure to enter the sandbox is an error; never retry an unconfined command.
    Linux relies on the validated paths and redirected environment.
    """
    if platform.system() != 'Darwin':
        return command
    profile = '(version 1) (allow default) (deny file-write*)'
    profile += ' (allow file-write* (literal "/dev/null"))'
    if not readonly:
        profile += ' (allow file-write* ' + ' '.join(
            '(subpath ' + json.dumps(str(Path(root).resolve())) + ')' for root in roots) + ')'
    return ['/usr/bin/sandbox-exec', '-p', profile, *map(str, command)]
