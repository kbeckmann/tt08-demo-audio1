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

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Audio signals
  wire audio_out;
  wire [15:0] audio_sample;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Audio PMOD
  assign uio_out = {audio_out, 7'b0000000};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  // wire _unused_ok = &{ena, ui_in, uio_in};
  wire _unused_ok = &{ena, ui_in, uio_in, pix_x, pix_y};

  reg [9:0] frame;
  // reg [16:0] counter;
  reg [10:0] counter;

// Audio start
  pdm pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );

  // wire [15:0] triangle = counter[16] ? -counter : counter;
  // assign audio_sample = triangle;

  // Just to test, let's add a small memory and output it as audio samples

  // ROM
  wire [7:0] rom_addr;
  reg [15:0] rom_data;

  always @(*) begin
      case (rom_addr)
        8'h00: rom_data = 16'hFFFF;
        8'h01: rom_data = 16'hFFF5;
        8'h02: rom_data = 16'hFFEB;
        8'h03: rom_data = 16'hFFE1;
        8'h04: rom_data = 16'hFFD7;
        8'h05: rom_data = 16'hFFCD;
        8'h06: rom_data = 16'hFFC3;
        8'h07: rom_data = 16'hFFB9;
        8'h08: rom_data = 16'hFFAF;
        8'h09: rom_data = 16'hFFA5;
        8'h0A: rom_data = 16'hFF9B;
        8'h0B: rom_data = 16'hFF91;
        8'h0C: rom_data = 16'hFF87;
        8'h0D: rom_data = 16'hFF7D;
        8'h0E: rom_data = 16'hFF73;
        8'h0F: rom_data = 16'hFF69;
        8'h10: rom_data = 16'hFF5F;
        8'h11: rom_data = 16'hFF55;
        8'h12: rom_data = 16'hFF4B;
        8'h13: rom_data = 16'hFF41;
        8'h14: rom_data = 16'hFF37;
        8'h15: rom_data = 16'hFF2D;
        8'h16: rom_data = 16'hFF23;
        8'h17: rom_data = 16'hFF19;
        8'h18: rom_data = 16'hFF0F;
        8'h19: rom_data = 16'hFF05;
        8'h1A: rom_data = 16'hFEFB;
        8'h1B: rom_data = 16'hFEF1;
        8'h1C: rom_data = 16'hFEE7;
        8'h1D: rom_data = 16'hFEDD;
        8'h1E: rom_data = 16'hFED3;
        8'h1F: rom_data = 16'hFEC9;
        8'h20: rom_data = 16'hFEBF;
        8'h21: rom_data = 16'hFEB5;
        8'h22: rom_data = 16'hFEAB;
        8'h23: rom_data = 16'hFEA1;
        8'h24: rom_data = 16'hFE97;
        8'h25: rom_data = 16'hFE8D;
        8'h26: rom_data = 16'hFE83;
        8'h27: rom_data = 16'hFE79;
        8'h28: rom_data = 16'hFE6F;
        8'h29: rom_data = 16'hFE65;
        8'h2A: rom_data = 16'hFE5B;
        8'h2B: rom_data = 16'hFE51;
        8'h2C: rom_data = 16'hFE47;
        8'h2D: rom_data = 16'hFE3D;
        8'h2E: rom_data = 16'hFE33;
        8'h2F: rom_data = 16'hFE29;
        8'h30: rom_data = 16'hFE1F;
        8'h31: rom_data = 16'hFE15;
        8'h32: rom_data = 16'hFE0B;
        8'h33: rom_data = 16'hFE01;
        8'h34: rom_data = 16'hFDF7;
        8'h35: rom_data = 16'hFDED;
        8'h36: rom_data = 16'hFDE3;
        8'h37: rom_data = 16'hFDD9;
        8'h38: rom_data = 16'hFDCF;
        8'h39: rom_data = 16'hFDC5;
        8'h3A: rom_data = 16'hFDBB;
        8'h3B: rom_data = 16'hFDB1;
        8'h3C: rom_data = 16'hFDA7;
        8'h3D: rom_data = 16'hFD9D;
        8'h3E: rom_data = 16'hFD93;
        8'h3F: rom_data = 16'hFD89;
        8'h40: rom_data = 16'hFD7F;
        8'h41: rom_data = 16'hFD75;
        8'h42: rom_data = 16'hFD6B;
        8'h43: rom_data = 16'hFD61;
        8'h44: rom_data = 16'hFD57;
        8'h45: rom_data = 16'hFD4D;
        8'h46: rom_data = 16'hFD43;
        8'h47: rom_data = 16'hFD39;
        8'h48: rom_data = 16'hFD2F;
        8'h49: rom_data = 16'hFD25;
        8'h4A: rom_data = 16'hFD1B;
        8'h4B: rom_data = 16'hFD11;
        8'h4C: rom_data = 16'hFD07;
        8'h4D: rom_data = 16'hFCFD;
        8'h4E: rom_data = 16'hFCF3;
        8'h4F: rom_data = 16'hFCE9;
        8'h50: rom_data = 16'hFCDF;
        8'h51: rom_data = 16'hFCD5;
        8'h52: rom_data = 16'hFCCB;
        8'h53: rom_data = 16'hFCC1;
        8'h54: rom_data = 16'hFCB7;
        8'h55: rom_data = 16'hFCAD;
        8'h56: rom_data = 16'hFCA3;
        8'h57: rom_data = 16'hFC99;
        8'h58: rom_data = 16'hFC8F;
        8'h59: rom_data = 16'hFC85;
        8'h5A: rom_data = 16'hFC7B;
        8'h5B: rom_data = 16'hFC71;
        8'h5C: rom_data = 16'hFC67;
        8'h5D: rom_data = 16'hFC5D;
        8'h5E: rom_data = 16'hFC53;
        8'h5F: rom_data = 16'hFC49;
        8'h60: rom_data = 16'hFC3F;
        8'h61: rom_data = 16'hFC35;
        8'h62: rom_data = 16'hFC2B;
        8'h63: rom_data = 16'hFC21;
        8'h64: rom_data = 16'hFC17;
        8'h65: rom_data = 16'hFC0D;
        8'h66: rom_data = 16'hFC03;
        8'h67: rom_data = 16'hFBF9;
        8'h68: rom_data = 16'hFBEF;
        8'h69: rom_data = 16'hFBE5;
        8'h6A: rom_data = 16'hFBDB;
        8'h6B: rom_data = 16'hFBD1;
        8'h6C: rom_data = 16'hFBC7;
        8'h6D: rom_data = 16'hFBBD;
        8'h6E: rom_data = 16'hFBB3;
        8'h6F: rom_data = 16'hFBA9;
        8'h70: rom_data = 16'hFB9F;
        8'h71: rom_data = 16'hFB95;
        8'h72: rom_data = 16'hFB8B;
        8'h73: rom_data = 16'hFB81;
        8'h74: rom_data = 16'hFB77;
        8'h75: rom_data = 16'hFB6D;
        8'h76: rom_data = 16'hFB63;
        8'h77: rom_data = 16'hFB59;
        8'h78: rom_data = 16'hFB4F;
        8'h79: rom_data = 16'hFB45;
        8'h7A: rom_data = 16'hFB3B;
        8'h7B: rom_data = 16'hFB31;
        8'h7C: rom_data = 16'hFB27;
        8'h7D: rom_data = 16'hFB1D;
        8'h7E: rom_data = 16'hFB13;
        8'h7F: rom_data = 16'hFB09;
        8'h80: rom_data = 16'hFAFF;
        8'h81: rom_data = 16'hFAF5;
        8'h82: rom_data = 16'hFAEB;
        8'h83: rom_data = 16'hFAE1;
        8'h84: rom_data = 16'hFAD7;
        8'h85: rom_data = 16'hFACD;
        8'h86: rom_data = 16'hFAC3;
        8'h87: rom_data = 16'hFAB9;
        8'h88: rom_data = 16'hFAAF;
        8'h89: rom_data = 16'hFAA5;
        8'h8A: rom_data = 16'hFA9B;
        8'h8B: rom_data = 16'hFA91;
        8'h8C: rom_data = 16'hFA87;
        8'h8D: rom_data = 16'hFA7D;
        8'h8E: rom_data = 16'hFA73;
        8'h8F: rom_data = 16'hFA69;
        8'h90: rom_data = 16'hFA5F;
        8'h91: rom_data = 16'hFA55;
        8'h92: rom_data = 16'hFA4B;
        8'h93: rom_data = 16'hFA41;
        8'h94: rom_data = 16'hFA37;
        8'h95: rom_data = 16'hFA2D;
        8'h96: rom_data = 16'hFA23;
        8'h97: rom_data = 16'hFA19;
        8'h98: rom_data = 16'hFA0F;
        8'h99: rom_data = 16'hFA05;
        8'h9A: rom_data = 16'hF9FB;
        8'h9B: rom_data = 16'hF9F1;
        8'h9C: rom_data = 16'hF9E7;
        8'h9D: rom_data = 16'hF9DD;
        8'h9E: rom_data = 16'hF9D3;
        8'h9F: rom_data = 16'hF9C9;
        8'hA0: rom_data = 16'hF9BF;
        8'hA1: rom_data = 16'hF9B5;
        8'hA2: rom_data = 16'hF9AB;
        8'hA3: rom_data = 16'hF9A1;
        8'hA4: rom_data = 16'hF997;
        8'hA5: rom_data = 16'hF98D;
        8'hA6: rom_data = 16'hF983;
        8'hA7: rom_data = 16'hF979;
        8'hA8: rom_data = 16'hF96F;
        8'hA9: rom_data = 16'hF965;
        8'hAA: rom_data = 16'hF95B;
        8'hAB: rom_data = 16'hF951;
        8'hAC: rom_data = 16'hF947;
        8'hAD: rom_data = 16'hF93D;
        8'hAE: rom_data = 16'hF933;
        8'hAF: rom_data = 16'hF929;
        8'hB0: rom_data = 16'hF91F;
        8'hB1: rom_data = 16'hF915;
        8'hB2: rom_data = 16'hF90B;
        8'hB3: rom_data = 16'hF901;
        8'hB4: rom_data = 16'hF8F7;
        8'hB5: rom_data = 16'hF8ED;
        8'hB6: rom_data = 16'hF8E3;
        8'hB7: rom_data = 16'hF8D9;
        8'hB8: rom_data = 16'hF8CF;
        8'hB9: rom_data = 16'hF8C5;
        8'hBA: rom_data = 16'hF8BB;
        8'hBB: rom_data = 16'hF8B1;
        8'hBC: rom_data = 16'hF8A7;
        8'hBD: rom_data = 16'hF89D;
        8'hBE: rom_data = 16'hF893;
        8'hBF: rom_data = 16'hF889;
        8'hC0: rom_data = 16'hF87F;
        8'hC1: rom_data = 16'hF875;
        8'hC2: rom_data = 16'hF86B;
        8'hC3: rom_data = 16'hF861;
        8'hC4: rom_data = 16'hF857;
        8'hC5: rom_data = 16'hF84D;
        8'hC6: rom_data = 16'hF843;
        8'hC7: rom_data = 16'hF839;
        8'hC8: rom_data = 16'hF82F;
        8'hC9: rom_data = 16'hF825;
        8'hCA: rom_data = 16'hF81B;
        8'hCB: rom_data = 16'hF811;
        8'hCC: rom_data = 16'hF807;
        8'hCD: rom_data = 16'hF7FD;
        8'hCE: rom_data = 16'hF7F3;
        8'hCF: rom_data = 16'hF7E9;
        8'hD0: rom_data = 16'hF7DF;
        8'hD1: rom_data = 16'hF7D5;
        8'hD2: rom_data = 16'hF7CB;
        8'hD3: rom_data = 16'hF7C1;
        8'hD4: rom_data = 16'hF7B7;
        8'hD5: rom_data = 16'hF7AD;
        8'hD6: rom_data = 16'hF7A3;
        8'hD7: rom_data = 16'hF799;
        8'hD8: rom_data = 16'hF78F;
        8'hD9: rom_data = 16'hF785;
        8'hDA: rom_data = 16'hF77B;
        8'hDB: rom_data = 16'hF771;
        8'hDC: rom_data = 16'hF767;
        8'hDD: rom_data = 16'hF75D;
        8'hDE: rom_data = 16'hF753;
        8'hDF: rom_data = 16'hF749;
        8'hE0: rom_data = 16'hF73F;
        8'hE1: rom_data = 16'hF735;
        8'hE2: rom_data = 16'hF72B;
        8'hE3: rom_data = 16'hF721;
        8'hE4: rom_data = 16'hF717;
        8'hE5: rom_data = 16'hF70D;
        8'hE6: rom_data = 16'hF703;
        8'hE7: rom_data = 16'hF6F9;
        8'hE8: rom_data = 16'hF6EF;
        8'hE9: rom_data = 16'hF6E5;
        8'hEA: rom_data = 16'hF6DB;
        8'hEB: rom_data = 16'hF6D1;
        8'hEC: rom_data = 16'hF6C7;
        8'hED: rom_data = 16'hF6BD;
        8'hEE: rom_data = 16'hF6B3;
        8'hEF: rom_data = 16'hF6A9;
        8'hF0: rom_data = 16'hF69F;
        8'hF1: rom_data = 16'hF695;
        8'hF2: rom_data = 16'hF68B;
        8'hF3: rom_data = 16'hF681;
        8'hF4: rom_data = 16'hF677;
        8'hF5: rom_data = 16'hF66D;
        8'hF6: rom_data = 16'hF663;
        8'hF7: rom_data = 16'hF659;
        8'hF8: rom_data = 16'hF64F;
        8'hF9: rom_data = 16'hF645;
        8'hFA: rom_data = 16'hF63B;
        8'hFB: rom_data = 16'hF631;
        8'hFC: rom_data = 16'hF627;
        8'hFD: rom_data = 16'hF61D;
        8'hFE: rom_data = 16'hF613;
        8'hFF: rom_data = 16'hF609;
      endcase
  end


  assign rom_addr = counter[10:3];
  // assign audio_sample = {8'h00, rom_data};
  assign audio_sample = {rom_data};

// Audio end


  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  assign R = video_active ? {frame[8], frame[9]} : 2'b00;
  assign G = video_active ? {frame[4], frame[5]} : 2'b00;
  assign B = video_active ? {frame[6], frame[7]} : 2'b00;
  
  always @(posedge clk) begin
    if (~rst_n) begin
      frame <= 0;
      counter <= 0;
    end else begin
      if (vsync) begin
        frame <= frame + 1;
      end else begin
        frame <= frame;
      end

      counter <= counter + 1;
    end
  end
  
endmodule