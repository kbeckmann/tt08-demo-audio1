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
  wire [6:0] rom_addr;
  reg  [6:0] rom_addr_r;
  reg  [7:0] rom_data_r;
  reg  [7:0] rom_content[128];

  initial begin
    rom_content[0] = 8'h35;
    rom_content[1] = 8'hF2;
    rom_content[2] = 8'h5C;
    rom_content[3] = 8'h8F;
    rom_content[4] = 8'hF6;
    rom_content[5] = 8'h4F;
    rom_content[6] = 8'h65;
    rom_content[7] = 8'h00;
    rom_content[8] = 8'h21;
    rom_content[9] = 8'hF1;
    rom_content[10] = 8'h9A;
    rom_content[11] = 8'hC0;
    rom_content[12] = 8'h64;
    rom_content[13] = 8'h6F;
    rom_content[14] = 8'h16;
    rom_content[15] = 8'hFE;
    rom_content[16] = 8'h81;
    rom_content[17] = 8'h98;
    rom_content[18] = 8'h62;
    rom_content[19] = 8'h5F;
    rom_content[20] = 8'h36;
    rom_content[21] = 8'hAD;
    rom_content[22] = 8'h27;
    rom_content[23] = 8'h89;
    rom_content[24] = 8'h2E;
    rom_content[25] = 8'h39;
    rom_content[26] = 8'hBB;
    rom_content[27] = 8'hB4;
    rom_content[28] = 8'h96;
    rom_content[29] = 8'h1D;
    rom_content[30] = 8'hDA;
    rom_content[31] = 8'h31;
    rom_content[32] = 8'h72;
    rom_content[33] = 8'h39;
    rom_content[34] = 8'hC6;
    rom_content[35] = 8'h78;
    rom_content[36] = 8'hB0;
    rom_content[37] = 8'hE2;
    rom_content[38] = 8'h0C;
    rom_content[39] = 8'hF8;
    rom_content[40] = 8'hC8;
    rom_content[41] = 8'h41;
    rom_content[42] = 8'h6D;
    rom_content[43] = 8'hE9;
    rom_content[44] = 8'hDE;
    rom_content[45] = 8'h91;
    rom_content[46] = 8'hA2;
    rom_content[47] = 8'hAE;
    rom_content[48] = 8'hAC;
    rom_content[49] = 8'h4F;
    rom_content[50] = 8'hF1;
    rom_content[51] = 8'h11;
    rom_content[52] = 8'h31;
    rom_content[53] = 8'hAA;
    rom_content[54] = 8'h8B;
    rom_content[55] = 8'hD3;
    rom_content[56] = 8'h0A;
    rom_content[57] = 8'h4B;
    rom_content[58] = 8'h34;
    rom_content[59] = 8'h6C;
    rom_content[60] = 8'hA9;
    rom_content[61] = 8'h9C;
    rom_content[62] = 8'hBA;
    rom_content[63] = 8'h9E;
    rom_content[64] = 8'hE9;
    rom_content[65] = 8'hE7;
    rom_content[66] = 8'h06;
    rom_content[67] = 8'hD1;
    rom_content[68] = 8'hB5;
    rom_content[69] = 8'hCC;
    rom_content[70] = 8'h3C;
    rom_content[71] = 8'h1A;
    rom_content[72] = 8'h87;
    rom_content[73] = 8'h86;
    rom_content[74] = 8'h81;
    rom_content[75] = 8'h8D;
    rom_content[76] = 8'h8E;
    rom_content[77] = 8'h7E;
    rom_content[78] = 8'h45;
    rom_content[79] = 8'h45;
    rom_content[80] = 8'hEF;
    rom_content[81] = 8'hFA;
    rom_content[82] = 8'h32;
    rom_content[83] = 8'h9C;
    rom_content[84] = 8'hBF;
    rom_content[85] = 8'h11;
    rom_content[86] = 8'h82;
    rom_content[87] = 8'h1D;
    rom_content[88] = 8'h61;
    rom_content[89] = 8'hA3;
    rom_content[90] = 8'hD3;
    rom_content[91] = 8'hA5;
    rom_content[92] = 8'h86;
    rom_content[93] = 8'hD4;
    rom_content[94] = 8'h78;
    rom_content[95] = 8'h65;
    rom_content[96] = 8'h97;
    rom_content[97] = 8'hFA;
    rom_content[98] = 8'h28;
    rom_content[99] = 8'hFC;
    rom_content[100] = 8'h46;
    rom_content[101] = 8'h0F;
    rom_content[102] = 8'hA2;
    rom_content[103] = 8'h4B;
    rom_content[104] = 8'h53;
    rom_content[105] = 8'hB1;
    rom_content[106] = 8'h03;
    rom_content[107] = 8'h51;
    rom_content[108] = 8'hFC;
    rom_content[109] = 8'h28;
    rom_content[110] = 8'hE5;
    rom_content[111] = 8'hB9;
    rom_content[112] = 8'h09;
    rom_content[113] = 8'hCA;
    rom_content[114] = 8'h05;
    rom_content[115] = 8'hAB;
    rom_content[116] = 8'h93;
    rom_content[117] = 8'hFC;
    rom_content[118] = 8'hF6;
    rom_content[119] = 8'hA9;
    rom_content[120] = 8'hE4;
    rom_content[121] = 8'h8A;
    rom_content[122] = 8'h80;
    rom_content[123] = 8'hBE;
    rom_content[124] = 8'h43;
    rom_content[125] = 8'h54;
    rom_content[126] = 8'hF7;
    rom_content[127] = 8'h10;
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_addr_r <= 0;
      rom_data_r <= 0;
    end else begin
      rom_addr_r <= rom_addr;
      rom_data_r <= rom_content[rom_addr_r];
    end
  end

  assign rom_addr = counter[10:4];
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