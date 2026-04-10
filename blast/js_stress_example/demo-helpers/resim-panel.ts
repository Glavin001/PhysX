/**
 * Shared resimulation + damage config panel for demos.
 *
 * Dynamically injects a collapsible config section into the demo sidebar
 * exposing the full set of rollback/resimulation/damage controls from
 * vibe-city's destructible-stress ControlPanel (Physics + Damage tabs).
 *
 * Usage in a demo:
 *
 *   import { createResimPanel, getResimCoreOptions, applyResimConfigToCore } from './demo-helpers/resim-panel';
 *
 *   // Before building core:
 *   const resim = createResimPanel({ insertBeforeId: 'btn-reset' });
 *
 *   // When constructing core, spread the options:
 *   const core = await buildDestructibleCore({
 *     ...getResimCoreOptions(resim.config),
 *     // ... other options
 *   });
 *
 *   // After core is built, apply runtime-tunable settings:
 *   applyResimConfigToCore(core, resim.config);
 *
 *   // resim.onChange(() => { ... })  // called when any live control changes
 */

export type SnapshotMode = 'perBody' | 'world';

export interface ResimConfig {
  // Fracture rollback
  resimulateOnFracture: boolean;
  resimulateOnDamageDestroy: boolean;
  maxResimulationPasses: number;
  snapshotMode: SnapshotMode;

  // Damageable chunks (main toggle)
  damageEnabled: boolean;
  strengthPerVolume: number; // health per volume
  autoDetachOnDestroy: boolean;
  autoCleanupPhysics: boolean;

  // Contact damage tuning
  contactDamageScale: number; // kImpact
  internalContactScale: number;
  minImpulseThreshold: number;
  contactCooldownMs: number;

  // Impact speed scaling
  speedMinExternal: number;
  speedMinInternal: number;
  speedMax: number;
  speedExponent: number;
  slowSpeedFactor: number;
  fastSpeedFactor: number;

  // Splash AOE
  splashRadius: number;
  splashFalloffExp: number;
}

export const DEFAULT_RESIM_CONFIG: ResimConfig = {
  // Fracture rollback
  resimulateOnFracture: true,
  resimulateOnDamageDestroy: false,
  maxResimulationPasses: 1,
  snapshotMode: 'perBody',

  // Damageable chunks
  damageEnabled: false,
  strengthPerVolume: 5_000,
  autoDetachOnDestroy: true,
  autoCleanupPhysics: true,

  // Contact damage
  contactDamageScale: 0.1,
  internalContactScale: 0.05,
  minImpulseThreshold: 50,
  contactCooldownMs: 100,

  // Speed scaling
  speedMinExternal: 0.5,
  speedMinInternal: 0.5,
  speedMax: 10,
  speedExponent: 1.5,
  slowSpeedFactor: 0.1,
  fastSpeedFactor: 3.0,

  // Splash
  splashRadius: 0.5,
  splashFalloffExp: 2.0,
};

export interface ResimPanelHandle {
  config: ResimConfig;
  /** Register a listener for any config change; returns unsubscribe. */
  onChange: (cb: () => void) => () => void;
  /** Returns the options object ready to spread into buildDestructibleCore. */
  getCoreOptions: () => Record<string, any>;
}

/**
 * Build the HTML snippet for the resim + damage config section.
 * The strings use the existing `.config-section` / `.config-row` / `.config-slider`
 * classes from styles/demo-common.css so no extra CSS is needed.
 */
function buildHtml(cfg: ResimConfig): string {
  const b = (v: boolean) => (v ? 'checked' : '');
  return `
    <section class="config-section" data-resim-section>
      <h2 class="section-title">Fracture Rollback <small style="font-weight:normal;opacity:.5">★ = live</small></h2>
      <div class="config-row">
        <label class="config-label" for="cfg-resim-fracture">Resim on Fracture (same frame) ★</label>
        <input type="checkbox" id="cfg-resim-fracture" ${b(cfg.resimulateOnFracture)} />
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-resim-damage">Resim on Damage Destroy ★</label>
        <input type="checkbox" id="cfg-resim-damage" ${b(cfg.resimulateOnDamageDestroy)} />
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-resim-max-passes">Max Resim Passes ★</label>
        <input type="range" id="cfg-resim-max-passes" class="config-slider" min="0" max="4" step="1" value="${cfg.maxResimulationPasses}" />
        <span class="config-value"><span id="cfg-resim-max-passes-value">${cfg.maxResimulationPasses}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-resim-snapshot-mode">Snapshot Mode (Reset to apply)</label>
        <select id="cfg-resim-snapshot-mode" class="config-select">
          <option value="perBody" ${cfg.snapshotMode === 'perBody' ? 'selected' : ''}>Per-body (recommended)</option>
          <option value="world" ${cfg.snapshotMode === 'world' ? 'selected' : ''}>World snapshot</option>
        </select>
      </div>
    </section>

    <section class="config-section" data-resim-damage-section>
      <h2 class="section-title">Damageable Chunks (Reset to apply)</h2>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-enabled">Enable damageable chunks</label>
        <input type="checkbox" id="cfg-damage-enabled" ${b(cfg.damageEnabled)} />
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-strength">Strength per volume</label>
        <input type="range" id="cfg-damage-strength" class="config-slider" min="100" max="50000" step="100" value="${cfg.strengthPerVolume}" />
        <span class="config-value"><span id="cfg-damage-strength-value">${cfg.strengthPerVolume.toLocaleString()}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-auto-detach">Auto-detach on destroy</label>
        <input type="checkbox" id="cfg-damage-auto-detach" ${b(cfg.autoDetachOnDestroy)} />
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-auto-cleanup">Auto cleanup physics</label>
        <input type="checkbox" id="cfg-damage-auto-cleanup" ${b(cfg.autoCleanupPhysics)} />
      </div>

      <h2 class="section-title" style="margin-top:12px">Contact Damage</h2>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-k-impact">Contact damage scale (kImpact)</label>
        <input type="range" id="cfg-damage-k-impact" class="config-slider" min="0" max="5" step="0.01" value="${cfg.contactDamageScale}" />
        <span class="config-value"><span id="cfg-damage-k-impact-value">${cfg.contactDamageScale.toFixed(2)}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-internal-scale">Internal contact scale</label>
        <input type="range" id="cfg-damage-internal-scale" class="config-slider" min="0" max="2" step="0.01" value="${cfg.internalContactScale}" />
        <span class="config-value"><span id="cfg-damage-internal-scale-value">${cfg.internalContactScale.toFixed(2)}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-min-impulse">Min impulse threshold</label>
        <input type="range" id="cfg-damage-min-impulse" class="config-slider" min="0" max="500" step="5" value="${cfg.minImpulseThreshold}" />
        <span class="config-value"><span id="cfg-damage-min-impulse-value">${cfg.minImpulseThreshold.toFixed(0)}</span> N·s</span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-cooldown">Contact cooldown</label>
        <input type="range" id="cfg-damage-cooldown" class="config-slider" min="0" max="1000" step="10" value="${cfg.contactCooldownMs}" />
        <span class="config-value"><span id="cfg-damage-cooldown-value">${cfg.contactCooldownMs.toFixed(0)}</span> ms</span>
      </div>

      <h2 class="section-title" style="margin-top:12px">Impact Speed Scaling</h2>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-speed-min-ext">Min external speed</label>
        <input type="range" id="cfg-damage-speed-min-ext" class="config-slider" min="0" max="5" step="0.05" value="${cfg.speedMinExternal}" />
        <span class="config-value"><span id="cfg-damage-speed-min-ext-value">${cfg.speedMinExternal.toFixed(2)}</span> m/s</span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-speed-max">Full boost speed</label>
        <input type="range" id="cfg-damage-speed-max" class="config-slider" min="1" max="40" step="0.5" value="${cfg.speedMax}" />
        <span class="config-value"><span id="cfg-damage-speed-max-value">${cfg.speedMax.toFixed(1)}</span> m/s</span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-speed-exp">Boost curve</label>
        <input type="range" id="cfg-damage-speed-exp" class="config-slider" min="0.5" max="4" step="0.05" value="${cfg.speedExponent}" />
        <span class="config-value"><span id="cfg-damage-speed-exp-value">${cfg.speedExponent.toFixed(2)}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-slow-factor">Slow factor</label>
        <input type="range" id="cfg-damage-slow-factor" class="config-slider" min="0.01" max="1" step="0.01" value="${cfg.slowSpeedFactor}" />
        <span class="config-value"><span id="cfg-damage-slow-factor-value">${cfg.slowSpeedFactor.toFixed(2)}</span></span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-fast-factor">Fast factor</label>
        <input type="range" id="cfg-damage-fast-factor" class="config-slider" min="1" max="10" step="0.05" value="${cfg.fastSpeedFactor}" />
        <span class="config-value"><span id="cfg-damage-fast-factor-value">${cfg.fastSpeedFactor.toFixed(2)}</span></span>
      </div>

      <h2 class="section-title" style="margin-top:12px">Splash AOE</h2>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-splash-radius">Splash radius</label>
        <input type="range" id="cfg-damage-splash-radius" class="config-slider" min="0" max="5" step="0.05" value="${cfg.splashRadius}" />
        <span class="config-value"><span id="cfg-damage-splash-radius-value">${cfg.splashRadius.toFixed(2)}</span> m</span>
      </div>
      <div class="config-row">
        <label class="config-label" for="cfg-damage-splash-exp">Splash falloff</label>
        <input type="range" id="cfg-damage-splash-exp" class="config-slider" min="0.5" max="5" step="0.1" value="${cfg.splashFalloffExp}" />
        <span class="config-value"><span id="cfg-damage-splash-exp-value">${cfg.splashFalloffExp.toFixed(1)}</span></span>
      </div>
    </section>
  `;
}

function bindRange(id: string, cfg: any, key: string, fmt: (v: number) => string, listeners: (() => void)[]) {
  const slider = document.getElementById(id) as HTMLInputElement | null;
  const display = document.getElementById(id + '-value');
  if (!slider) return;
  slider.addEventListener('input', () => {
    const v = parseFloat(slider.value);
    cfg[key] = key === 'maxResimulationPasses' ? Math.round(v) : v;
    if (display) display.textContent = fmt(cfg[key]);
    listeners.forEach((fn) => fn());
  });
}

function bindCheckbox(id: string, cfg: any, key: string, listeners: (() => void)[]) {
  const checkbox = document.getElementById(id) as HTMLInputElement | null;
  if (!checkbox) return;
  checkbox.addEventListener('change', () => {
    cfg[key] = checkbox.checked;
    listeners.forEach((fn) => fn());
  });
}

function bindSelect(id: string, cfg: any, key: string, listeners: (() => void)[]) {
  const select = document.getElementById(id) as HTMLSelectElement | null;
  if (!select) return;
  select.addEventListener('change', () => {
    cfg[key] = select.value;
    listeners.forEach((fn) => fn());
  });
}

/**
 * Inject the resim + damage config panel into the sidebar.
 *
 * @param opts.insertBeforeId - DOM id of the element to insert the section before
 *   (usually 'btn-reset' or the '.control-actions' container). If not found,
 *   the section is appended to the sidebar.
 * @param opts.initialConfig - Override default values.
 */
export function createResimPanel(opts: {
  insertBeforeId?: string;
  initialConfig?: Partial<ResimConfig>;
} = {}): ResimPanelHandle {
  const config: ResimConfig = { ...DEFAULT_RESIM_CONFIG, ...(opts.initialConfig ?? {}) };
  const listeners: (() => void)[] = [];

  // Inject HTML
  const html = buildHtml(config);
  const temp = document.createElement('div');
  temp.innerHTML = html;
  const sections = Array.from(temp.children) as HTMLElement[];

  const sidebar = document.getElementById('sidebar');
  const insertBefore = opts.insertBeforeId ? document.getElementById(opts.insertBeforeId) : null;
  const actionsContainer = document.querySelector('.control-actions') as HTMLElement | null;
  const anchor = insertBefore ?? actionsContainer;

  if (anchor && anchor.parentElement) {
    for (const section of sections) {
      anchor.parentElement.insertBefore(section, anchor);
    }
  } else if (sidebar) {
    for (const section of sections) {
      sidebar.appendChild(section);
    }
  }

  // Wire up controls
  bindCheckbox('cfg-resim-fracture', config, 'resimulateOnFracture', listeners);
  bindCheckbox('cfg-resim-damage', config, 'resimulateOnDamageDestroy', listeners);
  bindRange('cfg-resim-max-passes', config, 'maxResimulationPasses', (v) => String(Math.round(v)), listeners);
  bindSelect('cfg-resim-snapshot-mode', config, 'snapshotMode', listeners);

  bindCheckbox('cfg-damage-enabled', config, 'damageEnabled', listeners);
  bindRange('cfg-damage-strength', config, 'strengthPerVolume', (v) => v.toLocaleString(), listeners);
  bindCheckbox('cfg-damage-auto-detach', config, 'autoDetachOnDestroy', listeners);
  bindCheckbox('cfg-damage-auto-cleanup', config, 'autoCleanupPhysics', listeners);

  bindRange('cfg-damage-k-impact', config, 'contactDamageScale', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-internal-scale', config, 'internalContactScale', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-min-impulse', config, 'minImpulseThreshold', (v) => v.toFixed(0), listeners);
  bindRange('cfg-damage-cooldown', config, 'contactCooldownMs', (v) => v.toFixed(0), listeners);

  bindRange('cfg-damage-speed-min-ext', config, 'speedMinExternal', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-speed-max', config, 'speedMax', (v) => v.toFixed(1), listeners);
  bindRange('cfg-damage-speed-exp', config, 'speedExponent', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-slow-factor', config, 'slowSpeedFactor', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-fast-factor', config, 'fastSpeedFactor', (v) => v.toFixed(2), listeners);

  bindRange('cfg-damage-splash-radius', config, 'splashRadius', (v) => v.toFixed(2), listeners);
  bindRange('cfg-damage-splash-exp', config, 'splashFalloffExp', (v) => v.toFixed(1), listeners);

  return {
    config,
    onChange(cb) {
      listeners.push(cb);
      return () => {
        const i = listeners.indexOf(cb);
        if (i >= 0) listeners.splice(i, 1);
      };
    },
    getCoreOptions: () => getResimCoreOptions(config),
  };
}

/**
 * Build the subset of buildDestructibleCore options controlled by this panel.
 * Spread this into the options object passed to buildDestructibleCore.
 */
export function getResimCoreOptions(config: ResimConfig): Record<string, any> {
  return {
    resimulateOnFracture: config.resimulateOnFracture,
    resimulateOnDamageDestroy: config.resimulateOnDamageDestroy,
    maxResimulationPasses: config.maxResimulationPasses,
    snapshotMode: config.snapshotMode,
    damage: config.damageEnabled
      ? {
          enabled: true,
          strengthPerVolume: config.strengthPerVolume,
          autoDetachOnDestroy: config.autoDetachOnDestroy,
          autoCleanupPhysics: config.autoCleanupPhysics,
          kImpact: config.contactDamageScale,
          internalContactScale: config.internalContactScale,
          minImpulseThreshold: config.minImpulseThreshold,
          contactCooldownMs: config.contactCooldownMs,
          speedMinExternal: config.speedMinExternal,
          speedMinInternal: config.speedMinInternal,
          speedMax: config.speedMax,
          speedExponent: config.speedExponent,
          slowSpeedFactor: config.slowSpeedFactor,
          fastSpeedFactor: config.fastSpeedFactor,
          splashRadius: config.splashRadius,
          splashFalloffExp: config.splashFalloffExp,
        }
      : { enabled: false },
  };
}

/**
 * Apply runtime-tunable resim settings to an existing core without rebuilding.
 * Call this whenever the config changes (e.g. in an onChange listener) to
 * immediately reflect live-tunable values.
 *
 * Note: snapshotMode and damage.enabled cannot be changed at runtime — those
 * require a full core rebuild (wire to your Reset button).
 */
export function applyResimConfigToCore(core: any, config: ResimConfig): void {
  if (!core) return;
  // Update live-tunable resim flags via setters if available.
  if (typeof core.setResimulateOnFracture === 'function') {
    core.setResimulateOnFracture(config.resimulateOnFracture);
  } else if ('resimulateOnFracture' in core) {
    (core as any).resimulateOnFracture = config.resimulateOnFracture;
  }
  if (typeof core.setResimulateOnDamageDestroy === 'function') {
    core.setResimulateOnDamageDestroy(config.resimulateOnDamageDestroy);
  } else if ('resimulateOnDamageDestroy' in core) {
    (core as any).resimulateOnDamageDestroy = config.resimulateOnDamageDestroy;
  }
  if (typeof core.setMaxResimulationPasses === 'function') {
    core.setMaxResimulationPasses(config.maxResimulationPasses);
  } else if ('maxResimulationPasses' in core) {
    (core as any).maxResimulationPasses = config.maxResimulationPasses;
  }
}
