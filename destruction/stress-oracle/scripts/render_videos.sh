#!/usr/bin/env bash
# Renders the debug-visualisation video set into videos/: every benchmark scene
# (builders::catalog) and every showcase (showcases::catalog), each with a view
# layout and camera suited to it, plus a few feature comparisons.
#
#   scripts/render_videos.sh                # everything
#   scripts/render_videos.sh b5 s_arch      # only names containing one of the patterns
#
# Environment: JOBS (render threads, default 2), CARGO_TARGET_DIR, VIDEOS (output dir,
# default videos), EXTRA (extra stress-viz options for every video, e.g. "--size 1280x720").
set -euo pipefail

cd "$(dirname "$0")/.."
JOBS=${JOBS:-2}
VIDEOS=${VIDEOS:-videos}
mkdir -p "$VIDEOS"

cargo build --release --offline -p stress-viz
VIZ="${CARGO_TARGET_DIR:-target}/release/stress-viz"

PATTERNS=("$@")
# selected NAME: true when no patterns were given or NAME contains one of them.
selected() {
  [ ${#PATTERNS[@]} -eq 0 ] && return 0
  local pattern
  for pattern in "${PATTERNS[@]}"; do
    [[ "$1" == *"$pattern"* ]] && return 0
  done
  return 1
}

# render NAME [stress-viz options...]
render() {
  local name=$1; shift
  selected "$name" || return 0
  echo "=== $name"
  nice -n 10 "$VIZ" render "$name" --jobs "$JOBS" -o "$VIDEOS/$name.mp4" "$@" ${EXTRA:-}
}

# compare OUTPUT NAME [stress-viz options...]
compare() {
  local out=$1 name=$2; shift 2
  selected "$out" || return 0
  echo "=== $out"
  nice -n 10 "$VIZ" compare "$name" --jobs "$JOBS" -o "$VIDEOS/$out.mp4" "$@" ${EXTRA:-}
}

# --- benchmarks (builders::catalog) -------------------------------------------------
for s in b1_bond_tension b1_bond_shear; do
  probe=$([ "$s" = b1_bond_tension ] && echo axial || echo shear)
  render "$s" --views utilization,stress,damage --camera iso --plot "$probe"
done
for s in b2_cantilever b2_cantilever_n10 b2_cantilever_n40; do
  render "$s" --views utilization,stress,deformation --cols 1 --camera front --pitch 10 --plot tip
done
for s in b3_bar_wave b3_bar_wave_scaled; do
  render "$s" --views stress,velocity --cols 1 --yaw -15 --pitch 15 --plot v20,v50,v80
done
for s in b4_support_loss_sudden b4_support_loss_gradual; do
  render "$s" --views utilization,stress,velocity --camera iso --plot reaction
done
for s in b5_wall_impact_v02 b5_wall_impact_v10 b5_wall_impact_v40; do
  render "$s" --views utilization,stress,damage,fragments --arrows
done
# Spall: section through the slab (the half x < 0 is cut away), wave and crack planes.
render b6_spall --views stress,velocity,damage --clip "x<0" --yaw -50 --pitch 20 \
  --plot back_face_velocity,front_face_velocity
for s in b7_masonry_v04 b7_masonry_v15; do
  render "$s" --views utilization,damage,fragments,velocity --arrows --plot ball_velocity
done
for s in b8_frame_sudden b8_frame_gradual b8_frame_sudden_elastic; do
  render "$s" --views utilization,stress,damage,fragments --camera front --plot axial_col0,axial_col2
done
for s in b9_panel_low b9_panel_high b9_panel_high_weibull; do
  render "$s" --views utilization,damage,fragments,velocity --yaw 35 --plot center_displacement
done

# --- showcases (showcases::catalog) -------------------------------------------------
for s in s_overhang_thin s_overhang_thick; do
  render "$s" --views utilization,stress,damage,fragments --yaw -20 --pitch 12 --arrows --plot slab_tip
done
render s_supports_one_by_one --views utilization,stress,damage,fragments --camera front --pitch 15
for s in s_car_brick s_car_ductile; do
  render "$s" --views utilization,damage,fragments,velocity --arrows --plot car_velocity
done
for s in s_floor_drop s_floor_static; do
  render "$s" --views utilization,damage,fragments,velocity --camera iso
done
for s in s_arch_keystone_removed s_arch; do
  render "$s" --views utilization,stress,damage,fragments --camera front --arrows
done
render s_blast_two_walls --views utilization,damage,fragments,velocity --camera iso --arrows

# --- comparisons --------------------------------------------------------------------
compare s_overhang_thin_fatigue s_overhang_thin \
  --variant "static fatigue on:" --variant "static fatigue off:feature static_fatigue=off" \
  --views utilization,damage --yaw -20 --pitch 12 --plot slab_tip
compare b5_wall_impact_v10_rate b5_wall_impact_v10 \
  --variant "rate effects on:" --variant "rate effects off:feature rate_effects=off" \
  --views utilization,fragments
compare b7_masonry_v15_modes b7_masonry_v15 \
  --variant "explicit:" --variant "adaptive:sim.solve_mode=adaptive" \
  --views utilization,fragments --plot ball_velocity

echo "videos in $VIDEOS/"
