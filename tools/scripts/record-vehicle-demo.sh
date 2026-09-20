#!/usr/bin/env bash
# Record and render the vehicle demonstration into a directory named by the
# time and the commit it came from, so every run is kept and two can be
# compared: /root/recordings/vehicle-demo/<UTC time>-<short sha>[-dirty]/.
#
# Contents: the three TWSTATE1 recordings, their clips, the stitched video
# vehicle-demo-<stamp>.mp4, and manifest.txt with the commit, the test
# output lines and the exact commands.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST="$ROOT/out/destruction-sdk/reference/native_vehicle_wall_test"
RECORDER="$ROOT/demos/blast-stress-demo/recorder/target/release/blast-mini-city-recorder"
OUT_ROOT="${VEHICLE_DEMO_OUT:-/root/recordings/vehicle-demo}"
TITLE="${VEHICLE_DEMO_TITLE:-PhysX vehicle2 on the native destruction stage}"
WALL_STRENGTH="${VEHICLE_DEMO_WALL_STRENGTH:-1}"

for required in "$TEST" "$RECORDER"; do
  [ -x "$required" ] || { echo "missing $required; build the destruction SDK and the recorder first" >&2; exit 1; }
done

sha="$(git -C "$ROOT" rev-parse --short HEAD)"
dirty=""; git -C "$ROOT" diff --quiet HEAD -- demos destruction physx/source tools 2>/dev/null || dirty="-dirty"
stamp="$(date -u +%Y%m%d-%H%M%S)-${sha}${dirty}"
dir="$OUT_ROOT/$stamp"
mkdir -p "$dir"
manifest="$dir/manifest.txt"
{
  echo "vehicle demo $stamp"
  echo "commit: $(git -C "$ROOT" rev-parse HEAD)$dirty"
  echo "date: $(date -u --iso-8601=seconds)"
  echo "wall strength: $WALL_STRENGTH"
  echo "gpu: $(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || echo unknown)"
  echo
} > "$manifest"

run() { echo "\$ $*" >> "$manifest"; "$@" 2>&1 | tee -a "$manifest"; }

echo "recording into $dir"
run "$TEST" --demo --frames 480 --wall-strength "$WALL_STRENGTH" --state "$dir/wall.twstate"
run "$TEST" --rubble --frames 360 --state "$dir/rubble.twstate"

render() { # name state extra-args...
  local name="$1" state="$2"; shift 2
  run "$RECORDER" render --state "$state" --output "$dir/$name.mp4" --compact-hud --no-sleep-tint --ground-y 0 --title "$TITLE" "$@" \
    | grep -E "verified|error" || true
}
render wall-chase "$dir/wall.twstate" --camera 3 --chase-part 1
render wall-front "$dir/wall.twstate" --camera 1 --focus-center 0 -5.5 -1 --focus-radius 5.5 --camera-margin 0
render rubble-chase "$dir/rubble.twstate" --camera 3 --chase-part 1

list="$dir/clips.txt"
printf "file '%s'\nfile '%s'\nfile '%s'\n" "$dir/wall-chase.mp4" "$dir/wall-front.mp4" "$dir/rubble-chase.mp4" > "$list"
final="$dir/vehicle-demo-$stamp.mp4"
ffmpeg -v error -y -f concat -safe 0 -i "$list" -c copy "$final"
echo >> "$manifest"; echo "video: $final ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$final") s)" | tee -a "$manifest"
echo "$final"
