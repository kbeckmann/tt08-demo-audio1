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
  reg  [7:0] rom_content[256];

  initial begin
    rom_content[0] = 8'h76;
    rom_content[1] = 8'hC2;
    rom_content[2] = 8'hE9;
    rom_content[3] = 8'h20;
    rom_content[4] = 8'hD0;
    rom_content[5] = 8'h2E;
    rom_content[6] = 8'h7E;
    rom_content[7] = 8'hF7;
    rom_content[8] = 8'h3F;
    rom_content[9] = 8'h91;
    rom_content[10] = 8'hFB;
    rom_content[11] = 8'hE1;
    rom_content[12] = 8'hC7;
    rom_content[13] = 8'hA6;
    rom_content[14] = 8'hCB;
    rom_content[15] = 8'hE7;
    rom_content[16] = 8'hC3;
    rom_content[17] = 8'h9B;
    rom_content[18] = 8'hB2;
    rom_content[19] = 8'h19;
    rom_content[20] = 8'h14;
    rom_content[21] = 8'h88;
    rom_content[22] = 8'h08;
    rom_content[23] = 8'hFE;
    rom_content[24] = 8'h5D;
    rom_content[25] = 8'hD4;
    rom_content[26] = 8'h17;
    rom_content[27] = 8'h89;
    rom_content[28] = 8'h66;
    rom_content[29] = 8'hF7;
    rom_content[30] = 8'h92;
    rom_content[31] = 8'h57;
    rom_content[32] = 8'h17;
    rom_content[33] = 8'h63;
    rom_content[34] = 8'h10;
    rom_content[35] = 8'h7E;
    rom_content[36] = 8'hFD;
    rom_content[37] = 8'hC1;
    rom_content[38] = 8'h7E;
    rom_content[39] = 8'h95;
    rom_content[40] = 8'h4C;
    rom_content[41] = 8'hAA;
    rom_content[42] = 8'h80;
    rom_content[43] = 8'hD7;
    rom_content[44] = 8'h9E;
    rom_content[45] = 8'h9A;
    rom_content[46] = 8'hBF;
    rom_content[47] = 8'h49;
    rom_content[48] = 8'hE4;
    rom_content[49] = 8'h00;
    rom_content[50] = 8'h2C;
    rom_content[51] = 8'h74;
    rom_content[52] = 8'h5F;
    rom_content[53] = 8'h8B;
    rom_content[54] = 8'hFA;
    rom_content[55] = 8'hA0;
    rom_content[56] = 8'h0F;
    rom_content[57] = 8'hE8;
    rom_content[58] = 8'h27;
    rom_content[59] = 8'h57;
    rom_content[60] = 8'h02;
    rom_content[61] = 8'hCD;
    rom_content[62] = 8'h9F;
    rom_content[63] = 8'hCA;
    rom_content[64] = 8'hF2;
    rom_content[65] = 8'h71;
    rom_content[66] = 8'h71;
    rom_content[67] = 8'hF0;
    rom_content[68] = 8'hFF;
    rom_content[69] = 8'h53;
    rom_content[70] = 8'hE4;
    rom_content[71] = 8'h74;
    rom_content[72] = 8'hA5;
    rom_content[73] = 8'h3A;
    rom_content[74] = 8'hBC;
    rom_content[75] = 8'h1A;
    rom_content[76] = 8'h82;
    rom_content[77] = 8'h83;
    rom_content[78] = 8'h89;
    rom_content[79] = 8'h76;
    rom_content[80] = 8'hB6;
    rom_content[81] = 8'h3B;
    rom_content[82] = 8'hCD;
    rom_content[83] = 8'hAD;
    rom_content[84] = 8'hCC;
    rom_content[85] = 8'hCB;
    rom_content[86] = 8'hAB;
    rom_content[87] = 8'h99;
    rom_content[88] = 8'hA2;
    rom_content[89] = 8'hCE;
    rom_content[90] = 8'hCE;
    rom_content[91] = 8'hCC;
    rom_content[92] = 8'h73;
    rom_content[93] = 8'h22;
    rom_content[94] = 8'h86;
    rom_content[95] = 8'hA0;
    rom_content[96] = 8'h90;
    rom_content[97] = 8'hD6;
    rom_content[98] = 8'h8E;
    rom_content[99] = 8'h2D;
    rom_content[100] = 8'hE5;
    rom_content[101] = 8'h3A;
    rom_content[102] = 8'hDE;
    rom_content[103] = 8'h92;
    rom_content[104] = 8'h0E;
    rom_content[105] = 8'h20;
    rom_content[106] = 8'h09;
    rom_content[107] = 8'hE1;
    rom_content[108] = 8'hBA;
    rom_content[109] = 8'hCC;
    rom_content[110] = 8'hE5;
    rom_content[111] = 8'h13;
    rom_content[112] = 8'h95;
    rom_content[113] = 8'h63;
    rom_content[114] = 8'h3D;
    rom_content[115] = 8'hC7;
    rom_content[116] = 8'h53;
    rom_content[117] = 8'hDE;
    rom_content[118] = 8'h5B;
    rom_content[119] = 8'h3B;
    rom_content[120] = 8'h3A;
    rom_content[121] = 8'h55;
    rom_content[122] = 8'hDC;
    rom_content[123] = 8'hBA;
    rom_content[124] = 8'h9B;
    rom_content[125] = 8'hBC;
    rom_content[126] = 8'h1E;
    rom_content[127] = 8'hB0;
    rom_content[128] = 8'hBF;
    rom_content[129] = 8'h9C;
    rom_content[130] = 8'h05;
    rom_content[131] = 8'h4D;
    rom_content[132] = 8'h9F;
    rom_content[133] = 8'h3B;
    rom_content[134] = 8'h15;
    rom_content[135] = 8'h9C;
    rom_content[136] = 8'h94;
    rom_content[137] = 8'hD0;
    rom_content[138] = 8'h44;
    rom_content[139] = 8'hF3;
    rom_content[140] = 8'h8B;
    rom_content[141] = 8'hFD;
    rom_content[142] = 8'hB3;
    rom_content[143] = 8'h0E;
    rom_content[144] = 8'h42;
    rom_content[145] = 8'hED;
    rom_content[146] = 8'h14;
    rom_content[147] = 8'h0B;
    rom_content[148] = 8'h7F;
    rom_content[149] = 8'hDE;
    rom_content[150] = 8'h30;
    rom_content[151] = 8'hAC;
    rom_content[152] = 8'hCD;
    rom_content[153] = 8'h6E;
    rom_content[154] = 8'h89;
    rom_content[155] = 8'h7E;
    rom_content[156] = 8'h76;
    rom_content[157] = 8'h6E;
    rom_content[158] = 8'h58;
    rom_content[159] = 8'hC9;
    rom_content[160] = 8'h32;
    rom_content[161] = 8'h4C;
    rom_content[162] = 8'hB5;
    rom_content[163] = 8'hE4;
    rom_content[164] = 8'hA7;
    rom_content[165] = 8'h3E;
    rom_content[166] = 8'h0C;
    rom_content[167] = 8'h7D;
    rom_content[168] = 8'h13;
    rom_content[169] = 8'h05;
    rom_content[170] = 8'h31;
    rom_content[171] = 8'h60;
    rom_content[172] = 8'h9D;
    rom_content[173] = 8'h46;
    rom_content[174] = 8'h11;
    rom_content[175] = 8'hE8;
    rom_content[176] = 8'h1B;
    rom_content[177] = 8'hDA;
    rom_content[178] = 8'h90;
    rom_content[179] = 8'h38;
    rom_content[180] = 8'hAA;
    rom_content[181] = 8'h11;
    rom_content[182] = 8'hBC;
    rom_content[183] = 8'h70;
    rom_content[184] = 8'h9B;
    rom_content[185] = 8'h5B;
    rom_content[186] = 8'hFC;
    rom_content[187] = 8'h87;
    rom_content[188] = 8'h1B;
    rom_content[189] = 8'h26;
    rom_content[190] = 8'hA9;
    rom_content[191] = 8'h38;
    rom_content[192] = 8'h07;
    rom_content[193] = 8'h33;
    rom_content[194] = 8'h68;
    rom_content[195] = 8'hCA;
    rom_content[196] = 8'h80;
    rom_content[197] = 8'hE1;
    rom_content[198] = 8'h86;
    rom_content[199] = 8'hEE;
    rom_content[200] = 8'h74;
    rom_content[201] = 8'hAE;
    rom_content[202] = 8'hBB;
    rom_content[203] = 8'hCB;
    rom_content[204] = 8'h94;
    rom_content[205] = 8'hA7;
    rom_content[206] = 8'h5E;
    rom_content[207] = 8'hBB;
    rom_content[208] = 8'h78;
    rom_content[209] = 8'h41;
    rom_content[210] = 8'h69;
    rom_content[211] = 8'h0D;
    rom_content[212] = 8'hEB;
    rom_content[213] = 8'hF7;
    rom_content[214] = 8'hA0;
    rom_content[215] = 8'h46;
    rom_content[216] = 8'hEB;
    rom_content[217] = 8'hC1;
    rom_content[218] = 8'h1D;
    rom_content[219] = 8'h68;
    rom_content[220] = 8'hF7;
    rom_content[221] = 8'h3D;
    rom_content[222] = 8'h88;
    rom_content[223] = 8'hBF;
    rom_content[224] = 8'hB3;
    rom_content[225] = 8'h31;
    rom_content[226] = 8'h9F;
    rom_content[227] = 8'h23;
    rom_content[228] = 8'h9F;
    rom_content[229] = 8'h81;
    rom_content[230] = 8'hBE;
    rom_content[231] = 8'hB5;
    rom_content[232] = 8'h88;
    rom_content[233] = 8'h92;
    rom_content[234] = 8'h50;
    rom_content[235] = 8'h17;
    rom_content[236] = 8'hAC;
    rom_content[237] = 8'h0C;
    rom_content[238] = 8'h61;
    rom_content[239] = 8'h7F;
    rom_content[240] = 8'hE1;
    rom_content[241] = 8'h81;
    rom_content[242] = 8'h0E;
    rom_content[243] = 8'h29;
    rom_content[244] = 8'h27;
    rom_content[245] = 8'h3A;
    rom_content[246] = 8'h38;
    rom_content[247] = 8'hB9;
    rom_content[248] = 8'h97;
    rom_content[249] = 8'h7C;
    rom_content[250] = 8'hE4;
    rom_content[251] = 8'hFD;
    rom_content[252] = 8'hB9;
    rom_content[253] = 8'hE2;
    rom_content[254] = 8'h8C;
    rom_content[255] = 8'h6D;
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