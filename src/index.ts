import tt_um_top_v from './tt_um_top.v?raw';
import hvsync_gen_v from './hvsync_gen.v?raw';
import voice_v from './voice.v?raw';
import scale_rom_v from './scale_rom.v?raw';
import pdm_v from './pdm.v?raw';
import full_adder_v from './full_adder.v?raw';
import ripple_carry_adder_v from './ripple_carry_adder.v?raw';
import parallel_prefix_adder_v from './parallel_prefix_adder.v?raw';
import carry_lookahead_v from './carry_lookahead.v?raw';
import generate_propagate_v from './generate_propagate.v?raw';

export const synth = {
  name: 'Synth',
  author: 'kbeckmann',
  topModule: 'tt_um_top',
  sources: {
    'tt_um_top.v': tt_um_top_v,
    'voice.v': voice_v,
    'scale_rom.v': scale_rom_v,
    'pdm.v': pdm_v,
    'hvsync_gen_v': hvsync_gen_v,
    'full_adder.v': full_adder_v,
    'ripple_carry_adder.v': ripple_carry_adder_v,
    'generate_propagate.v': generate_propagate_v,
    'carry_lookahead.v': carry_lookahead_v,
    'parallel_prefix_adder.v': parallel_prefix_adder_v,
  },
};
