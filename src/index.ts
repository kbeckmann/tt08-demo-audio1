import tt_um_top_v from './tt_um_top.v?raw';
import hvsync_gen_v from './hvsync_gen.v?raw';
import voice_v from './voice.v?raw';
import scale_rom_v from './scale_rom.v?raw';

export const synth = {
  name: 'Synth',
  author: 'kbeckmann',
  topModule: 'tt_um_top',
  sources: {
    'tt_um_top.v': tt_um_top_v,
    'voice.v': voice_v,
    'scale_rom.v': scale_rom_v,
    'hvsync_gen_v': hvsync_gen_v,
  },
};
