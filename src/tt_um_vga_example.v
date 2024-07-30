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
  // wire _unused_ok = &{ena, ui_in, uio_in};
  // wire _unused_ok = &{ena, ui_in, uio_in, pix_x, pix_y};
  wire _unused_ok = &{ena, ui_in, uio_in};

  // reg [9:0] frame;
  reg [10:0] counter;

// Audio start
  pdm #(.N(8)) pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );

  // wire [15:0] triangle = counter[16] ? -counter : counter;
  // assign audio_sample = triangle;

  // Just to test, let's add a small memory and output it as audio samples

  // ROM
  wire [6:0] rom_addr;
  reg [3:0] rom_data_h;
  reg [3:0] rom_data_l;
  reg [3:0] rom_content_h[128];
  reg [3:0] rom_content_l[128];

  // assign rom_data_h = rom_content_h[rom_addr];
  // assign rom_data_l = rom_content_l[rom_addr];

  initial begin
  rom_content_h[0] = 4'h4;   rom_content_l[0] = 4'h2;
  rom_content_h[1] = 4'h5;   rom_content_l[1] = 4'h7;
  rom_content_h[2] = 4'h8;   rom_content_l[2] = 4'hF;
  rom_content_h[3] = 4'h0;   rom_content_l[3] = 4'h5;
  rom_content_h[4] = 4'hE;   rom_content_l[4] = 4'hE;
  rom_content_h[5] = 4'h0;   rom_content_l[5] = 4'h2;
  rom_content_h[6] = 4'hE;   rom_content_l[6] = 4'h1;
  rom_content_h[7] = 4'h4;   rom_content_l[7] = 4'h4;
  rom_content_h[8] = 4'h7;   rom_content_l[8] = 4'h1;
  rom_content_h[9] = 4'h7;   rom_content_l[9] = 4'h7;
  rom_content_h[10] = 4'h8;   rom_content_l[10] = 4'hC;
  rom_content_h[11] = 4'h2;   rom_content_l[11] = 4'hA;
  rom_content_h[12] = 4'h3;   rom_content_l[12] = 4'hB;
  rom_content_h[13] = 4'hC;   rom_content_l[13] = 4'hA;
  rom_content_h[14] = 4'h1;   rom_content_l[14] = 4'h9;
  rom_content_h[15] = 4'h3;   rom_content_l[15] = 4'hB;
  rom_content_h[16] = 4'hF;   rom_content_l[16] = 4'h5;
  rom_content_h[17] = 4'hF;   rom_content_l[17] = 4'h4;
  rom_content_h[18] = 4'hC;   rom_content_l[18] = 4'h9;
  rom_content_h[19] = 4'hA;   rom_content_l[19] = 4'h0;
  rom_content_h[20] = 4'hC;   rom_content_l[20] = 4'hA;
  rom_content_h[21] = 4'hE;   rom_content_l[21] = 4'h2;
  rom_content_h[22] = 4'h4;   rom_content_l[22] = 4'h1;
  rom_content_h[23] = 4'hA;   rom_content_l[23] = 4'h0;
  rom_content_h[24] = 4'hF;   rom_content_l[24] = 4'h3;
  rom_content_h[25] = 4'hA;   rom_content_l[25] = 4'hC;
  rom_content_h[26] = 4'hE;   rom_content_l[26] = 4'h8;
  rom_content_h[27] = 4'h9;   rom_content_l[27] = 4'h4;
  rom_content_h[28] = 4'h4;   rom_content_l[28] = 4'h4;
  rom_content_h[29] = 4'h7;   rom_content_l[29] = 4'h8;
  rom_content_h[30] = 4'h4;   rom_content_l[30] = 4'h6;
  rom_content_h[31] = 4'hF;   rom_content_l[31] = 4'hF;
  rom_content_h[32] = 4'hC;   rom_content_l[32] = 4'hF;
  rom_content_h[33] = 4'h8;   rom_content_l[33] = 4'h9;
  rom_content_h[34] = 4'hB;   rom_content_l[34] = 4'h1;
  rom_content_h[35] = 4'h9;   rom_content_l[35] = 4'h7;
  rom_content_h[36] = 4'h3;   rom_content_l[36] = 4'h6;
  rom_content_h[37] = 4'h6;   rom_content_l[37] = 4'hA;
  rom_content_h[38] = 4'h3;   rom_content_l[38] = 4'h3;
  rom_content_h[39] = 4'h5;   rom_content_l[39] = 4'hF;
  rom_content_h[40] = 4'hC;   rom_content_l[40] = 4'h6;
  rom_content_h[41] = 4'h3;   rom_content_l[41] = 4'h5;
  rom_content_h[42] = 4'h2;   rom_content_l[42] = 4'hC;
  rom_content_h[43] = 4'h6;   rom_content_l[43] = 4'h3;
  rom_content_h[44] = 4'h5;   rom_content_l[44] = 4'h0;
  rom_content_h[45] = 4'h0;   rom_content_l[45] = 4'hC;
  rom_content_h[46] = 4'h6;   rom_content_l[46] = 4'hD;
  rom_content_h[47] = 4'hB;   rom_content_l[47] = 4'hD;
  rom_content_h[48] = 4'hE;   rom_content_l[48] = 4'h0;
  rom_content_h[49] = 4'hD;   rom_content_l[49] = 4'h6;
  rom_content_h[50] = 4'hE;   rom_content_l[50] = 4'hC;
  rom_content_h[51] = 4'h3;   rom_content_l[51] = 4'h5;
  rom_content_h[52] = 4'hF;   rom_content_l[52] = 4'hC;
  rom_content_h[53] = 4'h5;   rom_content_l[53] = 4'hE;
  rom_content_h[54] = 4'h2;   rom_content_l[54] = 4'hE;
  rom_content_h[55] = 4'hD;   rom_content_l[55] = 4'hB;
  rom_content_h[56] = 4'hE;   rom_content_l[56] = 4'hC;
  rom_content_h[57] = 4'h4;   rom_content_l[57] = 4'h0;
  rom_content_h[58] = 4'hE;   rom_content_l[58] = 4'h4;
  rom_content_h[59] = 4'hA;   rom_content_l[59] = 4'hD;
  rom_content_h[60] = 4'hE;   rom_content_l[60] = 4'h8;
  rom_content_h[61] = 4'h3;   rom_content_l[61] = 4'h8;
  rom_content_h[62] = 4'h4;   rom_content_l[62] = 4'h3;
  rom_content_h[63] = 4'h3;   rom_content_l[63] = 4'h9;
  rom_content_h[64] = 4'h2;   rom_content_l[64] = 4'h9;
  rom_content_h[65] = 4'h9;   rom_content_l[65] = 4'hF;
  rom_content_h[66] = 4'h2;   rom_content_l[66] = 4'h3;
  rom_content_h[67] = 4'h5;   rom_content_l[67] = 4'h0;
  rom_content_h[68] = 4'h5;   rom_content_l[68] = 4'hB;
  rom_content_h[69] = 4'h8;   rom_content_l[69] = 4'hE;
  rom_content_h[70] = 4'h2;   rom_content_l[70] = 4'h7;
  rom_content_h[71] = 4'hA;   rom_content_l[71] = 4'h8;
  rom_content_h[72] = 4'h9;   rom_content_l[72] = 4'hC;
  rom_content_h[73] = 4'hB;   rom_content_l[73] = 4'hA;
  rom_content_h[74] = 4'hD;   rom_content_l[74] = 4'h4;
  rom_content_h[75] = 4'hE;   rom_content_l[75] = 4'h1;
  rom_content_h[76] = 4'h5;   rom_content_l[76] = 4'h4;
  rom_content_h[77] = 4'h7;   rom_content_l[77] = 4'hC;
  rom_content_h[78] = 4'h9;   rom_content_l[78] = 4'hD;
  rom_content_h[79] = 4'hE;   rom_content_l[79] = 4'h1;
  rom_content_h[80] = 4'hD;   rom_content_l[80] = 4'h6;
  rom_content_h[81] = 4'h3;   rom_content_l[81] = 4'h3;
  rom_content_h[82] = 4'hE;   rom_content_l[82] = 4'h0;
  rom_content_h[83] = 4'h1;   rom_content_l[83] = 4'h5;
  rom_content_h[84] = 4'h2;   rom_content_l[84] = 4'h2;
  rom_content_h[85] = 4'h4;   rom_content_l[85] = 4'h0;
  rom_content_h[86] = 4'h9;   rom_content_l[86] = 4'h6;
  rom_content_h[87] = 4'h8;   rom_content_l[87] = 4'h3;
  rom_content_h[88] = 4'h2;   rom_content_l[88] = 4'hA;
  rom_content_h[89] = 4'hD;   rom_content_l[89] = 4'h6;
  rom_content_h[90] = 4'h4;   rom_content_l[90] = 4'h7;
  rom_content_h[91] = 4'hF;   rom_content_l[91] = 4'h5;
  rom_content_h[92] = 4'h0;   rom_content_l[92] = 4'h6;
  rom_content_h[93] = 4'h9;   rom_content_l[93] = 4'h0;
  rom_content_h[94] = 4'h7;   rom_content_l[94] = 4'h0;
  rom_content_h[95] = 4'hB;   rom_content_l[95] = 4'hF;
  rom_content_h[96] = 4'hB;   rom_content_l[96] = 4'h9;
  rom_content_h[97] = 4'h1;   rom_content_l[97] = 4'hD;
  rom_content_h[98] = 4'h2;   rom_content_l[98] = 4'hE;
  rom_content_h[99] = 4'hC;   rom_content_l[99] = 4'h8;
  rom_content_h[100] = 4'h2;   rom_content_l[100] = 4'hC;
  rom_content_h[101] = 4'hE;   rom_content_l[101] = 4'h8;
  rom_content_h[102] = 4'h4;   rom_content_l[102] = 4'hA;
  rom_content_h[103] = 4'h1;   rom_content_l[103] = 4'h6;
  rom_content_h[104] = 4'hF;   rom_content_l[104] = 4'h4;
  rom_content_h[105] = 4'h3;   rom_content_l[105] = 4'h1;
  rom_content_h[106] = 4'h1;   rom_content_l[106] = 4'h4;
  rom_content_h[107] = 4'h2;   rom_content_l[107] = 4'hF;
  rom_content_h[108] = 4'h9;   rom_content_l[108] = 4'hD;
  rom_content_h[109] = 4'hE;   rom_content_l[109] = 4'hD;
  rom_content_h[110] = 4'hD;   rom_content_l[110] = 4'h9;
  rom_content_h[111] = 4'hF;   rom_content_l[111] = 4'h1;
  rom_content_h[112] = 4'h2;   rom_content_l[112] = 4'h2;
  rom_content_h[113] = 4'h6;   rom_content_l[113] = 4'h1;
  rom_content_h[114] = 4'h9;   rom_content_l[114] = 4'h2;
  rom_content_h[115] = 4'hD;   rom_content_l[115] = 4'h2;
  rom_content_h[116] = 4'h1;   rom_content_l[116] = 4'hB;
  rom_content_h[117] = 4'h8;   rom_content_l[117] = 4'hB;
  rom_content_h[118] = 4'h9;   rom_content_l[118] = 4'hF;
  rom_content_h[119] = 4'h9;   rom_content_l[119] = 4'hF;
  rom_content_h[120] = 4'h3;   rom_content_l[120] = 4'hE;
  rom_content_h[121] = 4'h0;   rom_content_l[121] = 4'hB;
  rom_content_h[122] = 4'h0;   rom_content_l[122] = 4'hF;
  rom_content_h[123] = 4'h8;   rom_content_l[123] = 4'h3;
  rom_content_h[124] = 4'h5;   rom_content_l[124] = 4'h0;
  rom_content_h[125] = 4'hA;   rom_content_l[125] = 4'hE;
  rom_content_h[126] = 4'h3;   rom_content_l[126] = 4'h7;
  rom_content_h[127] = 4'h8;   rom_content_l[127] = 4'hF;

  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_data_h <= 0;
      rom_data_l <= 0;
    end else begin
      rom_data_h <= rom_content_h[rom_addr];
      rom_data_l <= rom_content_l[rom_addr];
    end
  end

  assign rom_addr = counter[6:0];
  assign audio_sample = {8'h00, rom_data_h, rom_data_l};
  // assign audio_sample = {rom_data};

// Audio end

  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule