import * as monaco from 'monaco-editor';
import { FPSCounter } from './FPSCounter';
import { examples } from './examples';
import { exportProject } from './exportProject';
import { HDLModuleWASM } from './sim/hdlwasm';
import { compileVerilator } from './verilator/compile';

import noiseJs from "./noise.js?url";

let currentProject = null;

const hash = window.location.href.split('#')[1];

if (hash) {
  const jsonData = JSON.parse(atob(hash));
  currentProject = jsonData;
} else {
  // Load default project
  currentProject = structuredClone(examples[0]);
}

const inputButtons = Array.from(document.querySelectorAll('#input-values button'));

const codeEditorDiv = document.getElementById('code-editor');
const editor = monaco.editor.create(codeEditorDiv!, {
  value: currentProject.sources['tt_um_top.v'],
  language: 'systemverilog',
  scrollBeyondLastLine: false,
  minimap: {
    enabled: false,
  },
});

const res = await compileVerilator({
  topModule: currentProject.topModule,
  sources: currentProject.sources,
});
if (!res.output) {
  console.log(res.errors);
  throw new Error('Compile error');
}

let jmod = new HDLModuleWASM(res.output.modules['TOP'], res.output.modules['@CONST-POOL@']);
//let jmod = new HDLModuleJS(res.output.modules['TOP'], res.output.modules['@CONST-POOL@']);
await jmod.init();

function reset() {
  const ui_in = jmod.state.ui_in;
  jmod.powercycle();
  jmod.state.ena = 1;
  jmod.state.rst_n = 0;
  jmod.state.ui_in = ui_in;
  jmod.tick2(10);
  jmod.state.rst_n = 1;
}
reset();

function getVGASignals() {
  const uo_out = jmod.state.uo_out as number;
  return {
    hsync: !!(uo_out & 0b10000000),
    vsync: !!(uo_out & 0b00001000),
    r: ((uo_out & 0b00000001) << 1) | ((uo_out & 0b00010000) >> 4),
    g: ((uo_out & 0b00000010) << 0) | ((uo_out & 0b00100000) >> 5),
    b: ((uo_out & 0b00000100) >> 1) | ((uo_out & 0b01000000) >> 6),
  };
}

let stopped = false;
const fpsCounter = new FPSCounter();

editor.onDidChangeModelContent(async () => {
  stopped = true;
  currentProject.sources = {
    ...currentProject.sources,
    'tt_um_top.v': editor.getValue(),
  };
  const res = await compileVerilator({
    topModule: currentProject.topModule,
    sources: currentProject.sources,
  });
  monaco.editor.setModelMarkers(
    editor.getModel()!,
    'error',
    res.errors.map((e) => ({
      startLineNumber: e.line,
      endLineNumber: e.line,
      startColumn: e.column,
      endColumn: e.endColumn ?? 999,
      message: e.message,
      severity: e.type === 'error' ? monaco.MarkerSeverity.Error : monaco.MarkerSeverity.Warning,
    }))
  );
  if (!res.output) {
    return;
  }
  if (jmod) {
    jmod.dispose();
  }
  inputButtons.map((b) => b.classList.remove('active'));
  jmod = new HDLModuleWASM(res.output.modules['TOP'], res.output.modules['@CONST-POOL@']);
  await jmod.init();
  reset();
  fpsCounter.reset();
  stopped = false;
});

const canvas = document.querySelector<HTMLCanvasElement>('#vga-canvas');
const ctx = canvas?.getContext('2d');
const imageData = ctx?.createImageData(736, 520);
const fpsDisplay = document.querySelector('#fps-count');

function waitFor(condition: () => boolean, timeout = 10000) {
  let counter = 0;
  while (!condition() && counter < timeout) {
    jmod.tick2(1);
    counter++;
  }
}
let audioContext;
let noiseGenerator;
let isPlaying = false;
let offset_i = 0;

function startAudio() {
  const startAudioInner = async (context) => {
    await context.audioWorklet.addModule(noiseJs);
    noiseGenerator = new AudioWorkletNode(context, 'noise-generator', {
      processorOptions: {
        foo: 42
      }});
    noiseGenerator.connect(context.destination);
    noiseGenerator.port.onmessage = (e) => {
      const startTime = new Date().getTime();

      // console.log(e.data);
      const samples = e.data;
      const freq = jmod.state.clk_hz === undefined ? 1e6 : jmod.state.clk_hz; // Assume the design runs at 25.000 MHz
      const samprate = context.sampleRate; // Probably 48000
      const cycles = freq / samprate; // cycles to step between fetching a sample from the simulation
      let data = new Float32Array(samples);

      // console.log(cycles);
      // console.log(freq);

      for (var i = 0; i < samples; i++) {
        jmod.tick2(cycles);
        const sample = (jmod.state.audio_out - 3278.0) / 65536.0;
        data[i] = sample;
        
        // Uncomment to generate a perfect sine over time (no glitches)
        // const t = (offset_i + i) / samprate;
        // const phase = 2 * Math.PI * 440 * t;
        // data[i] = 1.0 * Math.sin(phase);
      }
      // Only used for sine generator
      offset_i += samples;
      // console.log(data)

      // Send the buffer with samples to the noiseGenerator thread
      noiseGenerator.port.postMessage(data);

      const endTime = new Date().getTime();
      const timeElapsed = endTime - startTime;
      const producedMs = 1000 * samples / samprate;
      console.log(`Took ${timeElapsed}ms to generate ${producedMs}ms of audio. Ratio: ${timeElapsed / producedMs}`)

    }

    // noiseGenerator doesn't have a start function. tell context to resume, to start pulling samples.
    context.resume();
  };

  startAudioInner(audioContext);
}

function animationFrame(now: number) {
  requestAnimationFrame(animationFrame);

  fpsCounter.update(now);

  if (fpsDisplay) {
    fpsDisplay.textContent = `${fpsCounter.getFPS().toFixed(0)}`;
  }

  if (stopped || !imageData || !ctx) {
    return;
  }

  // Check if audio is availabel - switch to audio only in such case
  const audio_en = jmod.state.audio_en as number;
  if (audio_en == 1 || isPlaying) {
    return;
  }

  const data = new Uint8Array(imageData.data.buffer);
  frameLoop: for (let y = 0; y < 520; y++) {
    waitFor(() => !getVGASignals().hsync);
    for (let x = 0; x < 736; x++) {
      const offset = (y * 736 + x) * 4;
      jmod.tick2(1);
      const { hsync, vsync, r, g, b } = getVGASignals();
      if (hsync) {
        break;
      }
      if (vsync) {
        break frameLoop;
      }
      data[offset] = r << 6;
      data[offset + 1] = g << 6;
      data[offset + 2] = b << 6;
      data[offset + 3] = 0xff;
    }
    waitFor(() => getVGASignals().hsync);
  }
  ctx!.putImageData(imageData, 0, 0);
  waitFor(() => getVGASignals().vsync);
  waitFor(() => !getVGASignals().vsync);
}

requestAnimationFrame(animationFrame);

const buttons = document.querySelector('#preset-buttons');
for (const example of examples) {
  const button = document.createElement('button');
  button.textContent = example.name;
  button.addEventListener('click', async () => {
    currentProject = structuredClone(example);
    editor.setValue(currentProject.sources['tt_um_top.v']);
  });
  buttons?.appendChild(button);
}

window.addEventListener('resize', () => {
  editor.layout();
});

window.addEventListener('visibilitychange', () => {
  const now = performance.now();
  if (document.hidden) {
    fpsCounter.pause(now);
  } else {
    fpsCounter.resume(now);
  }
});

document.querySelector('#download-button')?.addEventListener('click', () => {
  exportProject(currentProject);
});

document.querySelector('#share-button')?.addEventListener('click', () => {
  const url = new URL(window.location.href);
  const urlWithoutHash = url.protocol + "//" + url.host + url.pathname + url.search;

  const newUrl = urlWithoutHash + '#' + btoa(JSON.stringify(currentProject));
  navigator.clipboard.writeText(newUrl);
});

document.querySelector('#clipboard-button')?.addEventListener('click', () => {
  const code = btoa(JSON.stringify(currentProject.sources['tt_um_top.v']));
  navigator.clipboard.writeText(code);
});

document.querySelector('#audio-button')?.addEventListener('click', () => {
  if (isPlaying) return;

  isPlaying = true;
  audioContext = new (window.AudioContext || window.webkitAudioContext)();
  startAudio();
});

document.querySelector('#audio-mute-button')?.addEventListener('click', () => {
  if (!isPlaying) return;

  isPlaying = false;
  audioContext.close();
});



function toggleButton(index: number) {
  const bit = 1 << index;
  jmod.state.ui_in = jmod.state.ui_in ^ bit;
  if (jmod.state.ui_in & bit) {
    inputButtons[index].classList.add('active');
  } else {
    inputButtons[index].classList.remove('active');
  }
}

document.addEventListener('keydown', (e) => {
  if ('r' === e.key) {
    reset();
  }
  if (['0', '1', '2', '3', '4', '5', '6', '7'].includes(e.key)) {
    toggleButton(parseInt(e.key, 10));
  }
});

inputButtons.forEach((button, index) => {
  button.addEventListener('click', () => toggleButton(index));
});
