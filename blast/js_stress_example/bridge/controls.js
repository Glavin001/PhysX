import RAPIER from '@dimforge/rapier3d-compat';

import { GRAVITY_DEFAULT, STRENGTH_DEFAULT, SOLVER_DEFAULTS } from './constants.js';
import { HUD, pushEvent, controlsUI, updateStrengthUI, updateIterationsUI, updateToleranceUI, setDebugToggleLabel } from './ui.js';
import { spawnProjectile } from './spawning.js';
import { scaleStressLimits, clamp, toleranceFromExponent } from './utils.js';

/**
 * @param {object} state   – mutable { world, bridge } container shared with the animation loop
 * @param {THREE.Scene} scene
 * @param {object} stressRuntime
 * @param {function} resetFn – called as resetFn(scene, stressRuntime)
 */
export function setupControls(state, scene, stressRuntime, resetFn) {
  const { world, bridge } = state;

  if (!bridge.solverSettings) {
    bridge.solverSettings = {
      maxIterations: SOLVER_DEFAULTS.maxIterations,
      toleranceExponent: SOLVER_DEFAULTS.toleranceExponent
    };
  }

  if (controlsUI.gravitySlider) {
    controlsUI.gravitySlider.value = GRAVITY_DEFAULT.toString();
    controlsUI.gravitySlider.addEventListener('input', (event) => {
      const value = parseFloat(event.target.value);
      state.world.gravity = new RAPIER.Vector3(0, value, 0);
      state.bridge.activeGravity = value;
      if (HUD.gravityValue) {
        HUD.gravityValue.textContent = value.toFixed(2);
      }
      pushEvent(`Gravity set to ${value.toFixed(2)} m/s²`);
    });
  }
  if (controlsUI.fireButton) {
    controlsUI.fireButton.addEventListener('click', () => {
      spawnProjectile(state.world, state.bridge);
    });
  }
  if (controlsUI.resetButton) {
    controlsUI.resetButton.addEventListener('click', () => {
      resetFn(scene, stressRuntime);
    });
  }
  if (controlsUI.strengthSlider) {
    controlsUI.strengthSlider.value = bridge.strengthScale.toString();
    updateStrengthUI(bridge.strengthScale);
    controlsUI.strengthSlider.addEventListener('input', (event) => {
      const value = parseFloat(event.target.value);
      state.bridge.strengthScale = clamp(Number.isFinite(value) ? value : STRENGTH_DEFAULT, 0, 5);
      state.bridge.limits = new state.bridge.limitsCtor(scaleStressLimits(state.bridge.baseLimits, state.bridge.strengthScale));
      const display = updateStrengthUI(state.bridge.strengthScale);
      pushEvent(`Material strength scaled to ${display}`);
    });
  }
  if (controlsUI.iterSlider) {
    controlsUI.iterSlider.value = bridge.solverSettings.maxIterations.toString();
    updateIterationsUI(bridge.solverSettings.maxIterations);
    controlsUI.iterSlider.addEventListener('input', (event) => {
      const value = parseInt(event.target.value, 10);
      state.bridge.solverSettings.maxIterations = clamp(value, 1, 256);
      state.bridge.stressProcessor.setSolverParams({
        maxIterations: state.bridge.solverSettings.maxIterations,
        tolerance: toleranceFromExponent(state.bridge.solverSettings.toleranceExponent)
      });
      updateIterationsUI(state.bridge.solverSettings.maxIterations);
      pushEvent(`Solver iterations set to ${state.bridge.solverSettings.maxIterations}`);
    });
  }
  if (controlsUI.toleranceSlider) {
    controlsUI.toleranceSlider.value = bridge.solverSettings.toleranceExponent.toString();
    updateToleranceUI(bridge.solverSettings.toleranceExponent);
    controlsUI.toleranceSlider.addEventListener('input', (event) => {
      const exponent = clamp(parseFloat(event.target.value), -12, -2);
      state.bridge.solverSettings.toleranceExponent = exponent;
      state.bridge.stressProcessor.setSolverParams({
        tolerance: toleranceFromExponent(exponent),
        maxIterations: state.bridge.solverSettings.maxIterations
      });
      updateToleranceUI(exponent);
      pushEvent(`Solver tolerance set to 1.0e${exponent.toFixed(2)}`);
    });
  }
  if (controlsUI.debugToggle && bridge.debugRenderer) {
    setDebugToggleLabel(bridge.debugRenderer.enabled);
    controlsUI.debugToggle.addEventListener('click', () => {
      const enabled = state.bridge.debugRenderer.toggle();
      setDebugToggleLabel(enabled);
    });
  }
}

