/*
 * Copyright (c) 2024 Konrad Beckmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // Audio signals
  wire audio_out;
  wire [15:0] audio_sample;

  // TinyVGA PMOD
  // assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uo_out = 8'b00000000;

  // Audio PMOD
  assign uio_out = {audio_out, 7'b0000000};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [10:0] counter;

// Audio start
  pdm #(.N(16)) pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );

  // ROM
  wire [7:0] rom_addr;
  reg  [7:0] rom_addr_r;
  reg  [7:0] rom_data_r;
  reg  [3:0] rom_content_h[256];
  reg  [3:0] rom_content_l[256];

  initial begin
    rom_content_h[0] = 4'hA;   rom_content_l[0] = 4'hE;
    rom_content_h[1] = 4'hD;   rom_content_l[1] = 4'hE;
    rom_content_h[2] = 4'hD;   rom_content_l[2] = 4'hC;
    rom_content_h[3] = 4'hA;   rom_content_l[3] = 4'h6;
    rom_content_h[4] = 4'hC;   rom_content_l[4] = 4'h3;
    rom_content_h[5] = 4'h3;   rom_content_l[5] = 4'h5;
    rom_content_h[6] = 4'hF;   rom_content_l[6] = 4'h0;
    rom_content_h[7] = 4'hB;   rom_content_l[7] = 4'h4;
    rom_content_h[8] = 4'h7;   rom_content_l[8] = 4'hA;
    rom_content_h[9] = 4'h4;   rom_content_l[9] = 4'hE;
    rom_content_h[10] = 4'h9;   rom_content_l[10] = 4'h0;
    rom_content_h[11] = 4'hD;   rom_content_l[11] = 4'h0;
    rom_content_h[12] = 4'hB;   rom_content_l[12] = 4'hD;
    rom_content_h[13] = 4'h0;   rom_content_l[13] = 4'h4;
    rom_content_h[14] = 4'h4;   rom_content_l[14] = 4'h6;
    rom_content_h[15] = 4'h6;   rom_content_l[15] = 4'h7;
    rom_content_h[16] = 4'hF;   rom_content_l[16] = 4'h7;
    rom_content_h[17] = 4'h5;   rom_content_l[17] = 4'h7;
    rom_content_h[18] = 4'h7;   rom_content_l[18] = 4'h4;
    rom_content_h[19] = 4'h9;   rom_content_l[19] = 4'h4;
    rom_content_h[20] = 4'h2;   rom_content_l[20] = 4'hD;
    rom_content_h[21] = 4'hA;   rom_content_l[21] = 4'h6;
    rom_content_h[22] = 4'h3;   rom_content_l[22] = 4'hD;
    rom_content_h[23] = 4'h5;   rom_content_l[23] = 4'hA;
    rom_content_h[24] = 4'hE;   rom_content_l[24] = 4'h7;
    rom_content_h[25] = 4'hA;   rom_content_l[25] = 4'h8;
    rom_content_h[26] = 4'h0;   rom_content_l[26] = 4'h2;
    rom_content_h[27] = 4'hF;   rom_content_l[27] = 4'h1;
    rom_content_h[28] = 4'h2;   rom_content_l[28] = 4'h2;
    rom_content_h[29] = 4'hB;   rom_content_l[29] = 4'hB;
    rom_content_h[30] = 4'h4;   rom_content_l[30] = 4'h0;
    rom_content_h[31] = 4'h0;   rom_content_l[31] = 4'h4;
    rom_content_h[32] = 4'h9;   rom_content_l[32] = 4'h8;
    rom_content_h[33] = 4'h0;   rom_content_l[33] = 4'hE;
    rom_content_h[34] = 4'h8;   rom_content_l[34] = 4'h5;
    rom_content_h[35] = 4'h2;   rom_content_l[35] = 4'h4;
    rom_content_h[36] = 4'h7;   rom_content_l[36] = 4'hE;
    rom_content_h[37] = 4'h7;   rom_content_l[37] = 4'hE;
    rom_content_h[38] = 4'h1;   rom_content_l[38] = 4'hD;
    rom_content_h[39] = 4'h8;   rom_content_l[39] = 4'h9;
    rom_content_h[40] = 4'h4;   rom_content_l[40] = 4'h1;
    rom_content_h[41] = 4'h6;   rom_content_l[41] = 4'h6;
    rom_content_h[42] = 4'h3;   rom_content_l[42] = 4'hC;
    rom_content_h[43] = 4'h1;   rom_content_l[43] = 4'h4;
    rom_content_h[44] = 4'hE;   rom_content_l[44] = 4'hB;
    rom_content_h[45] = 4'hA;   rom_content_l[45] = 4'hA;
    rom_content_h[46] = 4'h0;   rom_content_l[46] = 4'hD;
    rom_content_h[47] = 4'h2;   rom_content_l[47] = 4'hD;
    rom_content_h[48] = 4'h3;   rom_content_l[48] = 4'h3;
    rom_content_h[49] = 4'h3;   rom_content_l[49] = 4'h9;
    rom_content_h[50] = 4'hF;   rom_content_l[50] = 4'hA;
    rom_content_h[51] = 4'h9;   rom_content_l[51] = 4'h5;
    rom_content_h[52] = 4'hA;   rom_content_l[52] = 4'h7;
    rom_content_h[53] = 4'h5;   rom_content_l[53] = 4'h0;
    rom_content_h[54] = 4'h7;   rom_content_l[54] = 4'h4;
    rom_content_h[55] = 4'hB;   rom_content_l[55] = 4'h4;
    rom_content_h[56] = 4'hD;   rom_content_l[56] = 4'h9;
    rom_content_h[57] = 4'h9;   rom_content_l[57] = 4'h7;
    rom_content_h[58] = 4'h7;   rom_content_l[58] = 4'h0;
    rom_content_h[59] = 4'h6;   rom_content_l[59] = 4'h7;
    rom_content_h[60] = 4'h8;   rom_content_l[60] = 4'h1;
    rom_content_h[61] = 4'h4;   rom_content_l[61] = 4'hC;
    rom_content_h[62] = 4'hF;   rom_content_l[62] = 4'hA;
    rom_content_h[63] = 4'h3;   rom_content_l[63] = 4'h3;
    rom_content_h[64] = 4'h7;   rom_content_l[64] = 4'h9;
    rom_content_h[65] = 4'hB;   rom_content_l[65] = 4'hC;
    rom_content_h[66] = 4'h6;   rom_content_l[66] = 4'h3;
    rom_content_h[67] = 4'hE;   rom_content_l[67] = 4'h8;
    rom_content_h[68] = 4'hA;   rom_content_l[68] = 4'hA;
    rom_content_h[69] = 4'h1;   rom_content_l[69] = 4'h8;
    rom_content_h[70] = 4'h7;   rom_content_l[70] = 4'hB;
    rom_content_h[71] = 4'h7;   rom_content_l[71] = 4'h5;
    rom_content_h[72] = 4'hF;   rom_content_l[72] = 4'hC;
    rom_content_h[73] = 4'hC;   rom_content_l[73] = 4'h7;
    rom_content_h[74] = 4'h4;   rom_content_l[74] = 4'hD;
    rom_content_h[75] = 4'h2;   rom_content_l[75] = 4'hC;
    rom_content_h[76] = 4'hB;   rom_content_l[76] = 4'h3;
    rom_content_h[77] = 4'hE;   rom_content_l[77] = 4'hE;
    rom_content_h[78] = 4'hF;   rom_content_l[78] = 4'hA;
    rom_content_h[79] = 4'hC;   rom_content_l[79] = 4'h9;
    rom_content_h[80] = 4'hF;   rom_content_l[80] = 4'h8;
    rom_content_h[81] = 4'h4;   rom_content_l[81] = 4'h9;
    rom_content_h[82] = 4'h8;   rom_content_l[82] = 4'hA;
    rom_content_h[83] = 4'hB;   rom_content_l[83] = 4'hF;
    rom_content_h[84] = 4'h3;   rom_content_l[84] = 4'h7;
    rom_content_h[85] = 4'h9;   rom_content_l[85] = 4'h3;
    rom_content_h[86] = 4'hE;   rom_content_l[86] = 4'h9;
    rom_content_h[87] = 4'hD;   rom_content_l[87] = 4'h5;
    rom_content_h[88] = 4'h6;   rom_content_l[88] = 4'h8;
    rom_content_h[89] = 4'h9;   rom_content_l[89] = 4'h7;
    rom_content_h[90] = 4'h5;   rom_content_l[90] = 4'h4;
    rom_content_h[91] = 4'h9;   rom_content_l[91] = 4'hE;
    rom_content_h[92] = 4'h9;   rom_content_l[92] = 4'hA;
    rom_content_h[93] = 4'h6;   rom_content_l[93] = 4'h4;
    rom_content_h[94] = 4'hA;   rom_content_l[94] = 4'h8;
    rom_content_h[95] = 4'h6;   rom_content_l[95] = 4'h3;
    rom_content_h[96] = 4'h7;   rom_content_l[96] = 4'hC;
    rom_content_h[97] = 4'h4;   rom_content_l[97] = 4'h0;
    rom_content_h[98] = 4'hD;   rom_content_l[98] = 4'h1;
    rom_content_h[99] = 4'h8;   rom_content_l[99] = 4'h2;
    rom_content_h[100] = 4'h5;   rom_content_l[100] = 4'hB;
    rom_content_h[101] = 4'hF;   rom_content_l[101] = 4'h6;
    rom_content_h[102] = 4'h1;   rom_content_l[102] = 4'h5;
    rom_content_h[103] = 4'h6;   rom_content_l[103] = 4'h6;
    rom_content_h[104] = 4'h2;   rom_content_l[104] = 4'h9;
    rom_content_h[105] = 4'h0;   rom_content_l[105] = 4'h9;
    rom_content_h[106] = 4'hF;   rom_content_l[106] = 4'hE;
    rom_content_h[107] = 4'h7;   rom_content_l[107] = 4'h4;
    rom_content_h[108] = 4'h8;   rom_content_l[108] = 4'hB;
    rom_content_h[109] = 4'h5;   rom_content_l[109] = 4'h1;
    rom_content_h[110] = 4'h1;   rom_content_l[110] = 4'h4;
    rom_content_h[111] = 4'hF;   rom_content_l[111] = 4'hD;
    rom_content_h[112] = 4'h9;   rom_content_l[112] = 4'h7;
    rom_content_h[113] = 4'hC;   rom_content_l[113] = 4'h8;
    rom_content_h[114] = 4'h1;   rom_content_l[114] = 4'hA;
    rom_content_h[115] = 4'hC;   rom_content_l[115] = 4'h8;
    rom_content_h[116] = 4'h8;   rom_content_l[116] = 4'h7;
    rom_content_h[117] = 4'h7;   rom_content_l[117] = 4'h0;
    rom_content_h[118] = 4'h6;   rom_content_l[118] = 4'h7;
    rom_content_h[119] = 4'h5;   rom_content_l[119] = 4'hC;
    rom_content_h[120] = 4'h1;   rom_content_l[120] = 4'h4;
    rom_content_h[121] = 4'hE;   rom_content_l[121] = 4'h9;
    rom_content_h[122] = 4'hF;   rom_content_l[122] = 4'hA;
    rom_content_h[123] = 4'h6;   rom_content_l[123] = 4'hB;
    rom_content_h[124] = 4'h7;   rom_content_l[124] = 4'h1;
    rom_content_h[125] = 4'h2;   rom_content_l[125] = 4'hF;
    rom_content_h[126] = 4'hE;   rom_content_l[126] = 4'h6;
    rom_content_h[127] = 4'h4;   rom_content_l[127] = 4'h5;
    rom_content_h[128] = 4'hC;   rom_content_l[128] = 4'h4;
    rom_content_h[129] = 4'h2;   rom_content_l[129] = 4'hD;
    rom_content_h[130] = 4'h2;   rom_content_l[130] = 4'hB;
    rom_content_h[131] = 4'hD;   rom_content_l[131] = 4'h5;
    rom_content_h[132] = 4'h9;   rom_content_l[132] = 4'h5;
    rom_content_h[133] = 4'hC;   rom_content_l[133] = 4'hC;
    rom_content_h[134] = 4'hB;   rom_content_l[134] = 4'h2;
    rom_content_h[135] = 4'h0;   rom_content_l[135] = 4'hF;
    rom_content_h[136] = 4'h0;   rom_content_l[136] = 4'hE;
    rom_content_h[137] = 4'hF;   rom_content_l[137] = 4'h4;
    rom_content_h[138] = 4'hD;   rom_content_l[138] = 4'hB;
    rom_content_h[139] = 4'h1;   rom_content_l[139] = 4'hD;
    rom_content_h[140] = 4'h0;   rom_content_l[140] = 4'hA;
    rom_content_h[141] = 4'h2;   rom_content_l[141] = 4'h4;
    rom_content_h[142] = 4'hD;   rom_content_l[142] = 4'hE;
    rom_content_h[143] = 4'h6;   rom_content_l[143] = 4'h7;
    rom_content_h[144] = 4'hC;   rom_content_l[144] = 4'h3;
    rom_content_h[145] = 4'hB;   rom_content_l[145] = 4'h3;
    rom_content_h[146] = 4'h1;   rom_content_l[146] = 4'h0;
    rom_content_h[147] = 4'h6;   rom_content_l[147] = 4'h0;
    rom_content_h[148] = 4'h3;   rom_content_l[148] = 4'h8;
    rom_content_h[149] = 4'h8;   rom_content_l[149] = 4'h5;
    rom_content_h[150] = 4'hC;   rom_content_l[150] = 4'h2;
    rom_content_h[151] = 4'h3;   rom_content_l[151] = 4'h9;
    rom_content_h[152] = 4'h0;   rom_content_l[152] = 4'hB;
    rom_content_h[153] = 4'h3;   rom_content_l[153] = 4'hE;
    rom_content_h[154] = 4'h8;   rom_content_l[154] = 4'h2;
    rom_content_h[155] = 4'h1;   rom_content_l[155] = 4'h6;
    rom_content_h[156] = 4'hD;   rom_content_l[156] = 4'hE;
    rom_content_h[157] = 4'h4;   rom_content_l[157] = 4'h7;
    rom_content_h[158] = 4'h2;   rom_content_l[158] = 4'h1;
    rom_content_h[159] = 4'h2;   rom_content_l[159] = 4'h1;
    rom_content_h[160] = 4'hA;   rom_content_l[160] = 4'hD;
    rom_content_h[161] = 4'hF;   rom_content_l[161] = 4'h0;
    rom_content_h[162] = 4'hB;   rom_content_l[162] = 4'h0;
    rom_content_h[163] = 4'h5;   rom_content_l[163] = 4'h7;
    rom_content_h[164] = 4'hF;   rom_content_l[164] = 4'h1;
    rom_content_h[165] = 4'h8;   rom_content_l[165] = 4'h1;
    rom_content_h[166] = 4'h7;   rom_content_l[166] = 4'h6;
    rom_content_h[167] = 4'h9;   rom_content_l[167] = 4'h7;
    rom_content_h[168] = 4'hA;   rom_content_l[168] = 4'h5;
    rom_content_h[169] = 4'h0;   rom_content_l[169] = 4'h3;
    rom_content_h[170] = 4'h5;   rom_content_l[170] = 4'h1;
    rom_content_h[171] = 4'h2;   rom_content_l[171] = 4'h2;
    rom_content_h[172] = 4'h3;   rom_content_l[172] = 4'h5;
    rom_content_h[173] = 4'h1;   rom_content_l[173] = 4'hC;
    rom_content_h[174] = 4'h7;   rom_content_l[174] = 4'h9;
    rom_content_h[175] = 4'h0;   rom_content_l[175] = 4'h2;
    rom_content_h[176] = 4'h4;   rom_content_l[176] = 4'hF;
    rom_content_h[177] = 4'h0;   rom_content_l[177] = 4'h5;
    rom_content_h[178] = 4'hD;   rom_content_l[178] = 4'h7;
    rom_content_h[179] = 4'hB;   rom_content_l[179] = 4'h6;
    rom_content_h[180] = 4'h9;   rom_content_l[180] = 4'hD;
    rom_content_h[181] = 4'h7;   rom_content_l[181] = 4'hD;
    rom_content_h[182] = 4'h7;   rom_content_l[182] = 4'h4;
    rom_content_h[183] = 4'h3;   rom_content_l[183] = 4'h8;
    rom_content_h[184] = 4'hB;   rom_content_l[184] = 4'h5;
    rom_content_h[185] = 4'hF;   rom_content_l[185] = 4'hF;
    rom_content_h[186] = 4'h9;   rom_content_l[186] = 4'h3;
    rom_content_h[187] = 4'h8;   rom_content_l[187] = 4'h9;
    rom_content_h[188] = 4'h8;   rom_content_l[188] = 4'hC;
    rom_content_h[189] = 4'hE;   rom_content_l[189] = 4'h6;
    rom_content_h[190] = 4'h8;   rom_content_l[190] = 4'h8;
    rom_content_h[191] = 4'h0;   rom_content_l[191] = 4'h2;
    rom_content_h[192] = 4'hC;   rom_content_l[192] = 4'h5;
    rom_content_h[193] = 4'hD;   rom_content_l[193] = 4'h1;
    rom_content_h[194] = 4'h8;   rom_content_l[194] = 4'h6;
    rom_content_h[195] = 4'hA;   rom_content_l[195] = 4'hC;
    rom_content_h[196] = 4'h0;   rom_content_l[196] = 4'h4;
    rom_content_h[197] = 4'h4;   rom_content_l[197] = 4'hD;
    rom_content_h[198] = 4'h6;   rom_content_l[198] = 4'h0;
    rom_content_h[199] = 4'h9;   rom_content_l[199] = 4'h2;
    rom_content_h[200] = 4'h9;   rom_content_l[200] = 4'h3;
    rom_content_h[201] = 4'h6;   rom_content_l[201] = 4'hD;
    rom_content_h[202] = 4'h5;   rom_content_l[202] = 4'h4;
    rom_content_h[203] = 4'hF;   rom_content_l[203] = 4'h3;
    rom_content_h[204] = 4'h6;   rom_content_l[204] = 4'h3;
    rom_content_h[205] = 4'h5;   rom_content_l[205] = 4'hD;
    rom_content_h[206] = 4'h9;   rom_content_l[206] = 4'h2;
    rom_content_h[207] = 4'h2;   rom_content_l[207] = 4'h8;
    rom_content_h[208] = 4'hC;   rom_content_l[208] = 4'h6;
    rom_content_h[209] = 4'hA;   rom_content_l[209] = 4'h2;
    rom_content_h[210] = 4'h9;   rom_content_l[210] = 4'hD;
    rom_content_h[211] = 4'hA;   rom_content_l[211] = 4'hC;
    rom_content_h[212] = 4'h6;   rom_content_l[212] = 4'hB;
    rom_content_h[213] = 4'h2;   rom_content_l[213] = 4'hE;
    rom_content_h[214] = 4'h4;   rom_content_l[214] = 4'h8;
    rom_content_h[215] = 4'h1;   rom_content_l[215] = 4'h1;
    rom_content_h[216] = 4'hF;   rom_content_l[216] = 4'h4;
    rom_content_h[217] = 4'h7;   rom_content_l[217] = 4'h8;
    rom_content_h[218] = 4'h4;   rom_content_l[218] = 4'hB;
    rom_content_h[219] = 4'hF;   rom_content_l[219] = 4'h1;
    rom_content_h[220] = 4'h4;   rom_content_l[220] = 4'hF;
    rom_content_h[221] = 4'hA;   rom_content_l[221] = 4'h8;
    rom_content_h[222] = 4'hE;   rom_content_l[222] = 4'h5;
    rom_content_h[223] = 4'h0;   rom_content_l[223] = 4'h9;
    rom_content_h[224] = 4'hF;   rom_content_l[224] = 4'hD;
    rom_content_h[225] = 4'hA;   rom_content_l[225] = 4'hA;
    rom_content_h[226] = 4'h7;   rom_content_l[226] = 4'h2;
    rom_content_h[227] = 4'h4;   rom_content_l[227] = 4'h5;
    rom_content_h[228] = 4'h4;   rom_content_l[228] = 4'hD;
    rom_content_h[229] = 4'h3;   rom_content_l[229] = 4'h1;
    rom_content_h[230] = 4'h7;   rom_content_l[230] = 4'hE;
    rom_content_h[231] = 4'h5;   rom_content_l[231] = 4'h0;
    rom_content_h[232] = 4'h9;   rom_content_l[232] = 4'h1;
    rom_content_h[233] = 4'hF;   rom_content_l[233] = 4'h2;
    rom_content_h[234] = 4'h3;   rom_content_l[234] = 4'hA;
    rom_content_h[235] = 4'h5;   rom_content_l[235] = 4'h1;
    rom_content_h[236] = 4'h7;   rom_content_l[236] = 4'h9;
    rom_content_h[237] = 4'hD;   rom_content_l[237] = 4'h1;
    rom_content_h[238] = 4'h0;   rom_content_l[238] = 4'hF;
    rom_content_h[239] = 4'hA;   rom_content_l[239] = 4'hD;
    rom_content_h[240] = 4'h7;   rom_content_l[240] = 4'h3;
    rom_content_h[241] = 4'hA;   rom_content_l[241] = 4'hF;
    rom_content_h[242] = 4'hA;   rom_content_l[242] = 4'hD;
    rom_content_h[243] = 4'h1;   rom_content_l[243] = 4'hF;
    rom_content_h[244] = 4'h7;   rom_content_l[244] = 4'h4;
    rom_content_h[245] = 4'hE;   rom_content_l[245] = 4'h6;
    rom_content_h[246] = 4'h4;   rom_content_l[246] = 4'h4;
    rom_content_h[247] = 4'h6;   rom_content_l[247] = 4'hA;
    rom_content_h[248] = 4'hD;   rom_content_l[248] = 4'hA;
    rom_content_h[249] = 4'h8;   rom_content_l[249] = 4'h9;
    rom_content_h[250] = 4'hB;   rom_content_l[250] = 4'h4;
    rom_content_h[251] = 4'hC;   rom_content_l[251] = 4'hB;
    rom_content_h[252] = 4'h1;   rom_content_l[252] = 4'hD;
    rom_content_h[253] = 4'h1;   rom_content_l[253] = 4'h9;
    rom_content_h[254] = 4'h4;   rom_content_l[254] = 4'h1;
    rom_content_h[255] = 4'hD;   rom_content_l[255] = 4'hC;
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_addr_r <= 0;
      rom_data_r <= 0;
    end else begin
      rom_addr_r <= rom_addr;
      rom_data_r <= {rom_content_h[rom_addr_r], rom_content_l[rom_addr_r]};
    end
  end

  assign rom_addr = counter[10:3];
  assign audio_sample = {8'h00, rom_data_r};

// Audio end

  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
