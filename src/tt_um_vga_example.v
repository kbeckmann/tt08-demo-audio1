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
  wire [8:0] rom_addr;
  reg [7:0] rom_data;

  always @(*) begin
      case (rom_addr)
        8'h000: rom_data = 8'h60;
        8'h001: rom_data = 8'hF7;
        8'h002: rom_data = 8'h65;
        8'h003: rom_data = 8'h3E;
        8'h004: rom_data = 8'h5C;
        8'h005: rom_data = 8'h31;
        8'h006: rom_data = 8'hD9;
        8'h007: rom_data = 8'h48;
        8'h008: rom_data = 8'h76;
        8'h009: rom_data = 8'hA7;
        8'h00A: rom_data = 8'h89;
        8'h00B: rom_data = 8'h33;
        8'h00C: rom_data = 8'hA7;
        8'h00D: rom_data = 8'h1D;
        8'h00E: rom_data = 8'h97;
        8'h00F: rom_data = 8'h5B;
        8'h010: rom_data = 8'h28;
        8'h011: rom_data = 8'hF3;
        8'h012: rom_data = 8'h70;
        8'h013: rom_data = 8'hA9;
        8'h014: rom_data = 8'h47;
        8'h015: rom_data = 8'h49;
        8'h016: rom_data = 8'h48;
        8'h017: rom_data = 8'h04;
        8'h018: rom_data = 8'h92;
        8'h019: rom_data = 8'h35;
        8'h01A: rom_data = 8'h1E;
        8'h01B: rom_data = 8'h21;
        8'h01C: rom_data = 8'h3F;
        8'h01D: rom_data = 8'hE6;
        8'h01E: rom_data = 8'hDC;
        8'h01F: rom_data = 8'h18;
        8'h020: rom_data = 8'h5D;
        8'h021: rom_data = 8'hB5;
        8'h022: rom_data = 8'hFC;
        8'h023: rom_data = 8'hD7;
        8'h024: rom_data = 8'hB2;
        8'h025: rom_data = 8'h21;
        8'h026: rom_data = 8'hE3;
        8'h027: rom_data = 8'h73;
        8'h028: rom_data = 8'h3B;
        8'h029: rom_data = 8'hC4;
        8'h02A: rom_data = 8'hE1;
        8'h02B: rom_data = 8'h3C;
        8'h02C: rom_data = 8'h64;
        8'h02D: rom_data = 8'hE7;
        8'h02E: rom_data = 8'hA7;
        8'h02F: rom_data = 8'h4E;
        8'h030: rom_data = 8'h49;
        8'h031: rom_data = 8'h40;
        8'h032: rom_data = 8'hBA;
        8'h033: rom_data = 8'h7D;
        8'h034: rom_data = 8'h50;
        8'h035: rom_data = 8'hEA;
        8'h036: rom_data = 8'hA9;
        8'h037: rom_data = 8'h59;
        8'h038: rom_data = 8'h05;
        8'h039: rom_data = 8'h66;
        8'h03A: rom_data = 8'h2A;
        8'h03B: rom_data = 8'hF0;
        8'h03C: rom_data = 8'h6A;
        8'h03D: rom_data = 8'h60;
        8'h03E: rom_data = 8'h8B;
        8'h03F: rom_data = 8'h7A;
        8'h040: rom_data = 8'hCE;
        8'h041: rom_data = 8'h14;
        8'h042: rom_data = 8'h9B;
        8'h043: rom_data = 8'h23;
        8'h044: rom_data = 8'hEA;
        8'h045: rom_data = 8'h86;
        8'h046: rom_data = 8'hCC;
        8'h047: rom_data = 8'h08;
        8'h048: rom_data = 8'hCA;
        8'h049: rom_data = 8'h00;
        8'h04A: rom_data = 8'h6E;
        8'h04B: rom_data = 8'hC8;
        8'h04C: rom_data = 8'hAF;
        8'h04D: rom_data = 8'h2B;
        8'h04E: rom_data = 8'hD6;
        8'h04F: rom_data = 8'hB4;
        8'h050: rom_data = 8'hAC;
        8'h051: rom_data = 8'hE7;
        8'h052: rom_data = 8'h76;
        8'h053: rom_data = 8'h3A;
        8'h054: rom_data = 8'hD9;
        8'h055: rom_data = 8'hF5;
        8'h056: rom_data = 8'h23;
        8'h057: rom_data = 8'hFA;
        8'h058: rom_data = 8'h46;
        8'h059: rom_data = 8'h1C;
        8'h05A: rom_data = 8'h25;
        8'h05B: rom_data = 8'h06;
        8'h05C: rom_data = 8'hE4;
        8'h05D: rom_data = 8'h27;
        8'h05E: rom_data = 8'h18;
        8'h05F: rom_data = 8'hE2;
        8'h060: rom_data = 8'h44;
        8'h061: rom_data = 8'h1D;
        8'h062: rom_data = 8'h8C;
        8'h063: rom_data = 8'hCF;
        8'h064: rom_data = 8'h20;
        8'h065: rom_data = 8'h00;
        8'h066: rom_data = 8'h6A;
        8'h067: rom_data = 8'hF9;
        8'h068: rom_data = 8'h05;
        8'h069: rom_data = 8'h0F;
        8'h06A: rom_data = 8'hB5;
        8'h06B: rom_data = 8'h71;
        8'h06C: rom_data = 8'h16;
        8'h06D: rom_data = 8'h74;
        8'h06E: rom_data = 8'h92;
        8'h06F: rom_data = 8'hD5;
        8'h070: rom_data = 8'h78;
        8'h071: rom_data = 8'h3E;
        8'h072: rom_data = 8'h1B;
        8'h073: rom_data = 8'h0D;
        8'h074: rom_data = 8'hD4;
        8'h075: rom_data = 8'h24;
        8'h076: rom_data = 8'hC6;
        8'h077: rom_data = 8'hE8;
        8'h078: rom_data = 8'hBB;
        8'h079: rom_data = 8'h5B;
        8'h07A: rom_data = 8'h22;
        8'h07B: rom_data = 8'h86;
        8'h07C: rom_data = 8'h34;
        8'h07D: rom_data = 8'h7F;
        8'h07E: rom_data = 8'h30;
        8'h07F: rom_data = 8'h07;
        8'h080: rom_data = 8'hE7;
        8'h081: rom_data = 8'h5D;
        8'h082: rom_data = 8'h67;
        8'h083: rom_data = 8'hDF;
        8'h084: rom_data = 8'h59;
        8'h085: rom_data = 8'hB2;
        8'h086: rom_data = 8'hFD;
        8'h087: rom_data = 8'hAE;
        8'h088: rom_data = 8'hA9;
        8'h089: rom_data = 8'h0D;
        8'h08A: rom_data = 8'hFC;
        8'h08B: rom_data = 8'hCD;
        8'h08C: rom_data = 8'hEB;
        8'h08D: rom_data = 8'hCA;
        8'h08E: rom_data = 8'h74;
        8'h08F: rom_data = 8'h5F;
        8'h090: rom_data = 8'hE4;
        8'h091: rom_data = 8'hE7;
        8'h092: rom_data = 8'h8D;
        8'h093: rom_data = 8'hB3;
        8'h094: rom_data = 8'hBB;
        8'h095: rom_data = 8'h24;
        8'h096: rom_data = 8'hC0;
        8'h097: rom_data = 8'hF2;
        8'h098: rom_data = 8'hB1;
        8'h099: rom_data = 8'h8F;
        8'h09A: rom_data = 8'h7B;
        8'h09B: rom_data = 8'hBC;
        8'h09C: rom_data = 8'hD3;
        8'h09D: rom_data = 8'h48;
        8'h09E: rom_data = 8'hBE;
        8'h09F: rom_data = 8'hA2;
        8'h0A0: rom_data = 8'hD5;
        8'h0A1: rom_data = 8'h30;
        8'h0A2: rom_data = 8'h02;
        8'h0A3: rom_data = 8'h04;
        8'h0A4: rom_data = 8'hBF;
        8'h0A5: rom_data = 8'h48;
        8'h0A6: rom_data = 8'hF2;
        8'h0A7: rom_data = 8'h45;
        8'h0A8: rom_data = 8'h18;
        8'h0A9: rom_data = 8'h8A;
        8'h0AA: rom_data = 8'hD5;
        8'h0AB: rom_data = 8'h27;
        8'h0AC: rom_data = 8'h72;
        8'h0AD: rom_data = 8'hE4;
        8'h0AE: rom_data = 8'h97;
        8'h0AF: rom_data = 8'h33;
        8'h0B0: rom_data = 8'h57;
        8'h0B1: rom_data = 8'hF1;
        8'h0B2: rom_data = 8'hA4;
        8'h0B3: rom_data = 8'h58;
        8'h0B4: rom_data = 8'h25;
        8'h0B5: rom_data = 8'h80;
        8'h0B6: rom_data = 8'h26;
        8'h0B7: rom_data = 8'h30;
        8'h0B8: rom_data = 8'hC1;
        8'h0B9: rom_data = 8'hB5;
        8'h0BA: rom_data = 8'hF7;
        8'h0BB: rom_data = 8'h62;
        8'h0BC: rom_data = 8'h42;
        8'h0BD: rom_data = 8'hD2;
        8'h0BE: rom_data = 8'h73;
        8'h0BF: rom_data = 8'h07;
        8'h0C0: rom_data = 8'h12;
        8'h0C1: rom_data = 8'hE4;
        8'h0C2: rom_data = 8'hBC;
        8'h0C3: rom_data = 8'h48;
        8'h0C4: rom_data = 8'hA0;
        8'h0C5: rom_data = 8'h51;
        8'h0C6: rom_data = 8'h46;
        8'h0C7: rom_data = 8'h59;
        8'h0C8: rom_data = 8'h62;
        8'h0C9: rom_data = 8'h7D;
        8'h0CA: rom_data = 8'hAA;
        8'h0CB: rom_data = 8'h20;
        8'h0CC: rom_data = 8'h52;
        8'h0CD: rom_data = 8'h4B;
        8'h0CE: rom_data = 8'h8F;
        8'h0CF: rom_data = 8'h53;
        8'h0D0: rom_data = 8'h60;
        8'h0D1: rom_data = 8'h0D;
        8'h0D2: rom_data = 8'h2C;
        8'h0D3: rom_data = 8'h1B;
        8'h0D4: rom_data = 8'h85;
        8'h0D5: rom_data = 8'h8E;
        8'h0D6: rom_data = 8'hFE;
        8'h0D7: rom_data = 8'h14;
        8'h0D8: rom_data = 8'h85;
        8'h0D9: rom_data = 8'h48;
        8'h0DA: rom_data = 8'h5D;
        8'h0DB: rom_data = 8'h2A;
        8'h0DC: rom_data = 8'h01;
        8'h0DD: rom_data = 8'hCF;
        8'h0DE: rom_data = 8'h8B;
        8'h0DF: rom_data = 8'hC1;
        8'h0E0: rom_data = 8'h94;
        8'h0E1: rom_data = 8'hAD;
        8'h0E2: rom_data = 8'hF0;
        8'h0E3: rom_data = 8'hFD;
        8'h0E4: rom_data = 8'h49;
        8'h0E5: rom_data = 8'hD1;
        8'h0E6: rom_data = 8'h4D;
        8'h0E7: rom_data = 8'hC5;
        8'h0E8: rom_data = 8'hCF;
        8'h0E9: rom_data = 8'hCE;
        8'h0EA: rom_data = 8'hC8;
        8'h0EB: rom_data = 8'h70;
        8'h0EC: rom_data = 8'hFF;
        8'h0ED: rom_data = 8'h95;
        8'h0EE: rom_data = 8'h3E;
        8'h0EF: rom_data = 8'hCC;
        8'h0F0: rom_data = 8'h6E;
        8'h0F1: rom_data = 8'hCE;
        8'h0F2: rom_data = 8'hA9;
        8'h0F3: rom_data = 8'h8F;
        8'h0F4: rom_data = 8'h2B;
        8'h0F5: rom_data = 8'h7B;
        8'h0F6: rom_data = 8'h22;
        8'h0F7: rom_data = 8'h4C;
        8'h0F8: rom_data = 8'hFD;
        8'h0F9: rom_data = 8'h2F;
        8'h0FA: rom_data = 8'hBA;
        8'h0FB: rom_data = 8'hFB;
        8'h0FC: rom_data = 8'h08;
        8'h0FD: rom_data = 8'hDF;
        8'h0FE: rom_data = 8'h94;
        8'h0FF: rom_data = 8'h85;
        8'h100: rom_data = 8'hA4;
        8'h101: rom_data = 8'hFC;
        8'h102: rom_data = 8'hAD;
        8'h103: rom_data = 8'hEC;
        8'h104: rom_data = 8'hD7;
        8'h105: rom_data = 8'h59;
        8'h106: rom_data = 8'hA4;
        8'h107: rom_data = 8'hDF;
        8'h108: rom_data = 8'h38;
        8'h109: rom_data = 8'h49;
        8'h10A: rom_data = 8'h7E;
        8'h10B: rom_data = 8'hD9;
        8'h10C: rom_data = 8'hBA;
        8'h10D: rom_data = 8'h3B;
        8'h10E: rom_data = 8'hD5;
        8'h10F: rom_data = 8'h7A;
        8'h110: rom_data = 8'h03;
        8'h111: rom_data = 8'h70;
        8'h112: rom_data = 8'hCB;
        8'h113: rom_data = 8'hC3;
        8'h114: rom_data = 8'hFE;
        8'h115: rom_data = 8'h33;
        8'h116: rom_data = 8'h79;
        8'h117: rom_data = 8'h74;
        8'h118: rom_data = 8'h5C;
        8'h119: rom_data = 8'h79;
        8'h11A: rom_data = 8'h44;
        8'h11B: rom_data = 8'hD3;
        8'h11C: rom_data = 8'h63;
        8'h11D: rom_data = 8'hA0;
        8'h11E: rom_data = 8'h97;
        8'h11F: rom_data = 8'hE7;
        8'h120: rom_data = 8'hB5;
        8'h121: rom_data = 8'h0A;
        8'h122: rom_data = 8'h7B;
        8'h123: rom_data = 8'h9E;
        8'h124: rom_data = 8'hB0;
        8'h125: rom_data = 8'hA7;
        8'h126: rom_data = 8'hDF;
        8'h127: rom_data = 8'hBA;
        8'h128: rom_data = 8'h39;
        8'h129: rom_data = 8'h58;
        8'h12A: rom_data = 8'h3F;
        8'h12B: rom_data = 8'hDB;
        8'h12C: rom_data = 8'h5B;
        8'h12D: rom_data = 8'hF3;
        8'h12E: rom_data = 8'h51;
        8'h12F: rom_data = 8'h13;
        8'h130: rom_data = 8'h75;
        8'h131: rom_data = 8'h76;
        8'h132: rom_data = 8'hC9;
        8'h133: rom_data = 8'hFA;
        8'h134: rom_data = 8'h2F;
        8'h135: rom_data = 8'hF4;
        8'h136: rom_data = 8'hC0;
        8'h137: rom_data = 8'h84;
        8'h138: rom_data = 8'h46;
        8'h139: rom_data = 8'h8B;
        8'h13A: rom_data = 8'h58;
        8'h13B: rom_data = 8'h6E;
        8'h13C: rom_data = 8'hBB;
        8'h13D: rom_data = 8'h2E;
        8'h13E: rom_data = 8'hE8;
        8'h13F: rom_data = 8'h95;
        8'h140: rom_data = 8'hB0;
        8'h141: rom_data = 8'h84;
        8'h142: rom_data = 8'hB2;
        8'h143: rom_data = 8'hC2;
        8'h144: rom_data = 8'hFD;
        8'h145: rom_data = 8'h6A;
        8'h146: rom_data = 8'hE2;
        8'h147: rom_data = 8'hD0;
        8'h148: rom_data = 8'h8A;
        8'h149: rom_data = 8'h32;
        8'h14A: rom_data = 8'h4A;
        8'h14B: rom_data = 8'hE5;
        8'h14C: rom_data = 8'hD7;
        8'h14D: rom_data = 8'hBD;
        8'h14E: rom_data = 8'h3B;
        8'h14F: rom_data = 8'h01;
        8'h150: rom_data = 8'h8A;
        8'h151: rom_data = 8'h44;
        8'h152: rom_data = 8'hB7;
        8'h153: rom_data = 8'h88;
        8'h154: rom_data = 8'hC7;
        8'h155: rom_data = 8'hA3;
        8'h156: rom_data = 8'h8D;
        8'h157: rom_data = 8'h48;
        8'h158: rom_data = 8'h56;
        8'h159: rom_data = 8'hE2;
        8'h15A: rom_data = 8'hBB;
        8'h15B: rom_data = 8'h83;
        8'h15C: rom_data = 8'h52;
        8'h15D: rom_data = 8'h29;
        8'h15E: rom_data = 8'h40;
        8'h15F: rom_data = 8'h95;
        8'h160: rom_data = 8'h9D;
        8'h161: rom_data = 8'h45;
        8'h162: rom_data = 8'hBD;
        8'h163: rom_data = 8'h53;
        8'h164: rom_data = 8'hC8;
        8'h165: rom_data = 8'hC2;
        8'h166: rom_data = 8'h65;
        8'h167: rom_data = 8'hC8;
        8'h168: rom_data = 8'h47;
        8'h169: rom_data = 8'h5A;
        8'h16A: rom_data = 8'h4C;
        8'h16B: rom_data = 8'hF8;
        8'h16C: rom_data = 8'hA9;
        8'h16D: rom_data = 8'h7A;
        8'h16E: rom_data = 8'h50;
        8'h16F: rom_data = 8'hD0;
        8'h170: rom_data = 8'hC5;
        8'h171: rom_data = 8'h9A;
        8'h172: rom_data = 8'h1F;
        8'h173: rom_data = 8'hFE;
        8'h174: rom_data = 8'hF8;
        8'h175: rom_data = 8'hF5;
        8'h176: rom_data = 8'hC7;
        8'h177: rom_data = 8'hF7;
        8'h178: rom_data = 8'hDB;
        8'h179: rom_data = 8'h1C;
        8'h17A: rom_data = 8'hA2;
        8'h17B: rom_data = 8'h3E;
        8'h17C: rom_data = 8'hC8;
        8'h17D: rom_data = 8'h3C;
        8'h17E: rom_data = 8'hAC;
        8'h17F: rom_data = 8'hAB;
        8'h180: rom_data = 8'hDE;
        8'h181: rom_data = 8'h81;
        8'h182: rom_data = 8'h68;
        8'h183: rom_data = 8'h0A;
        8'h184: rom_data = 8'h1F;
        8'h185: rom_data = 8'hD9;
        8'h186: rom_data = 8'h82;
        8'h187: rom_data = 8'hF1;
        8'h188: rom_data = 8'hC3;
        8'h189: rom_data = 8'hD9;
        8'h18A: rom_data = 8'hF4;
        8'h18B: rom_data = 8'hA4;
        8'h18C: rom_data = 8'h3F;
        8'h18D: rom_data = 8'h8C;
        8'h18E: rom_data = 8'hF1;
        8'h18F: rom_data = 8'hE8;
        8'h190: rom_data = 8'h32;
        8'h191: rom_data = 8'hE8;
        8'h192: rom_data = 8'h28;
        8'h193: rom_data = 8'h87;
        8'h194: rom_data = 8'h53;
        8'h195: rom_data = 8'h48;
        8'h196: rom_data = 8'hF7;
        8'h197: rom_data = 8'h7D;
        8'h198: rom_data = 8'hE0;
        8'h199: rom_data = 8'hB5;
        8'h19A: rom_data = 8'h0B;
        8'h19B: rom_data = 8'h79;
        8'h19C: rom_data = 8'hC2;
        8'h19D: rom_data = 8'h75;
        8'h19E: rom_data = 8'h4A;
        8'h19F: rom_data = 8'h6B;
        8'h1A0: rom_data = 8'h2A;
        8'h1A1: rom_data = 8'h1A;
        8'h1A2: rom_data = 8'hCD;
        8'h1A3: rom_data = 8'h42;
        8'h1A4: rom_data = 8'h8D;
        8'h1A5: rom_data = 8'h55;
        8'h1A6: rom_data = 8'h16;
        8'h1A7: rom_data = 8'hE1;
        8'h1A8: rom_data = 8'h13;
        8'h1A9: rom_data = 8'h67;
        8'h1AA: rom_data = 8'h55;
        8'h1AB: rom_data = 8'h14;
        8'h1AC: rom_data = 8'h57;
        8'h1AD: rom_data = 8'h1E;
        8'h1AE: rom_data = 8'h99;
        8'h1AF: rom_data = 8'h75;
        8'h1B0: rom_data = 8'h00;
        8'h1B1: rom_data = 8'hBD;
        8'h1B2: rom_data = 8'hCE;
        8'h1B3: rom_data = 8'hAB;
        8'h1B4: rom_data = 8'h75;
        8'h1B5: rom_data = 8'h84;
        8'h1B6: rom_data = 8'h58;
        8'h1B7: rom_data = 8'h2B;
        8'h1B8: rom_data = 8'h31;
        8'h1B9: rom_data = 8'h6E;
        8'h1BA: rom_data = 8'h69;
        8'h1BB: rom_data = 8'h68;
        8'h1BC: rom_data = 8'hE3;
        8'h1BD: rom_data = 8'hE7;
        8'h1BE: rom_data = 8'h0B;
        8'h1BF: rom_data = 8'h29;
        8'h1C0: rom_data = 8'hB3;
        8'h1C1: rom_data = 8'h99;
        8'h1C2: rom_data = 8'h4F;
        8'h1C3: rom_data = 8'hF5;
        8'h1C4: rom_data = 8'h9A;
        8'h1C5: rom_data = 8'hAA;
        8'h1C6: rom_data = 8'hF8;
        8'h1C7: rom_data = 8'h34;
        8'h1C8: rom_data = 8'h04;
        8'h1C9: rom_data = 8'h8C;
        8'h1CA: rom_data = 8'h60;
        8'h1CB: rom_data = 8'hDD;
        8'h1CC: rom_data = 8'h89;
        8'h1CD: rom_data = 8'hA0;
        8'h1CE: rom_data = 8'hB1;
        8'h1CF: rom_data = 8'h02;
        8'h1D0: rom_data = 8'h4C;
        8'h1D1: rom_data = 8'hDE;
        8'h1D2: rom_data = 8'h78;
        8'h1D3: rom_data = 8'h39;
        8'h1D4: rom_data = 8'h39;
        8'h1D5: rom_data = 8'hEA;
        8'h1D6: rom_data = 8'h30;
        8'h1D7: rom_data = 8'hC7;
        8'h1D8: rom_data = 8'h30;
        8'h1D9: rom_data = 8'h8F;
        8'h1DA: rom_data = 8'h0B;
        8'h1DB: rom_data = 8'hAE;
        8'h1DC: rom_data = 8'h26;
        8'h1DD: rom_data = 8'h02;
        8'h1DE: rom_data = 8'hA2;
        8'h1DF: rom_data = 8'hDF;
        8'h1E0: rom_data = 8'hD0;
        8'h1E1: rom_data = 8'hBD;
        8'h1E2: rom_data = 8'hD5;
        8'h1E3: rom_data = 8'hDA;
        8'h1E4: rom_data = 8'h57;
        8'h1E5: rom_data = 8'h74;
        8'h1E6: rom_data = 8'hEA;
        8'h1E7: rom_data = 8'hBA;
        8'h1E8: rom_data = 8'h76;
        8'h1E9: rom_data = 8'h53;
        8'h1EA: rom_data = 8'hF6;
        8'h1EB: rom_data = 8'hFF;
        8'h1EC: rom_data = 8'h11;
        8'h1ED: rom_data = 8'h0A;
        8'h1EE: rom_data = 8'h46;
        8'h1EF: rom_data = 8'hCE;
        8'h1F0: rom_data = 8'hBE;
        8'h1F1: rom_data = 8'hAA;
        8'h1F2: rom_data = 8'hFE;
        8'h1F3: rom_data = 8'h07;
        8'h1F4: rom_data = 8'h25;
        8'h1F5: rom_data = 8'h1D;
        8'h1F6: rom_data = 8'h54;
        8'h1F7: rom_data = 8'hC7;
        8'h1F8: rom_data = 8'hB0;
        8'h1F9: rom_data = 8'h70;
        8'h1FA: rom_data = 8'h52;
        8'h1FB: rom_data = 8'h22;
        8'h1FC: rom_data = 8'hCF;
        8'h1FD: rom_data = 8'hEB;
        8'h1FE: rom_data = 8'h73;
        8'h1FF: rom_data = 8'h62;
      endcase
  end


  assign rom_addr = counter[10:2];
  assign audio_sample = {8'h00, rom_data};
  // assign audio_sample = {rom_data};

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