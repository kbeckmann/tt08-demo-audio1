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
  reg  [7:0] rom_data;
  reg  [7:0] rom_data_r;

  always @(*) begin
    case (rom_addr_r)
      8'h00: rom_data = 8'hE2;
      8'h01: rom_data = 8'hBE;
      8'h02: rom_data = 8'hC7;
      8'h03: rom_data = 8'hBB;
      8'h04: rom_data = 8'hE0;
      8'h05: rom_data = 8'hB7;
      8'h06: rom_data = 8'h1A;
      8'h07: rom_data = 8'h5B;
      8'h08: rom_data = 8'hA2;
      8'h09: rom_data = 8'h3B;
      8'h0A: rom_data = 8'hB4;
      8'h0B: rom_data = 8'h34;
      8'h0C: rom_data = 8'hBC;
      8'h0D: rom_data = 8'hF1;
      8'h0E: rom_data = 8'hB5;
      8'h0F: rom_data = 8'h03;
      8'h10: rom_data = 8'h58;
      8'h11: rom_data = 8'h0E;
      8'h12: rom_data = 8'h1F;
      8'h13: rom_data = 8'h53;
      8'h14: rom_data = 8'h16;
      8'h15: rom_data = 8'h79;
      8'h16: rom_data = 8'h3D;
      8'h17: rom_data = 8'h17;
      8'h18: rom_data = 8'hAB;
      8'h19: rom_data = 8'hAF;
      8'h1A: rom_data = 8'hB5;
      8'h1B: rom_data = 8'h7A;
      8'h1C: rom_data = 8'h86;
      8'h1D: rom_data = 8'h11;
      8'h1E: rom_data = 8'h13;
      8'h1F: rom_data = 8'h12;
      8'h20: rom_data = 8'h0D;
      8'h21: rom_data = 8'hD1;
      8'h22: rom_data = 8'hE1;
      8'h23: rom_data = 8'hA4;
      8'h24: rom_data = 8'h72;
      8'h25: rom_data = 8'h83;
      8'h26: rom_data = 8'hE2;
      8'h27: rom_data = 8'h4A;
      8'h28: rom_data = 8'hEC;
      8'h29: rom_data = 8'h1C;
      8'h2A: rom_data = 8'hB4;
      8'h2B: rom_data = 8'hC5;
      8'h2C: rom_data = 8'h2A;
      8'h2D: rom_data = 8'h93;
      8'h2E: rom_data = 8'h6C;
      8'h2F: rom_data = 8'h45;
      8'h30: rom_data = 8'h71;
      8'h31: rom_data = 8'h6D;
      8'h32: rom_data = 8'hEC;
      8'h33: rom_data = 8'hD9;
      8'h34: rom_data = 8'h0C;
      8'h35: rom_data = 8'hF3;
      8'h36: rom_data = 8'h99;
      8'h37: rom_data = 8'h4C;
      8'h38: rom_data = 8'h3B;
      8'h39: rom_data = 8'h91;
      8'h3A: rom_data = 8'h02;
      8'h3B: rom_data = 8'h50;
      8'h3C: rom_data = 8'h61;
      8'h3D: rom_data = 8'h75;
      8'h3E: rom_data = 8'h7B;
      8'h3F: rom_data = 8'h4A;
      8'h40: rom_data = 8'hFF;
      8'h41: rom_data = 8'h04;
      8'h42: rom_data = 8'hE1;
      8'h43: rom_data = 8'h3B;
      8'h44: rom_data = 8'h7D;
      8'h45: rom_data = 8'hFE;
      8'h46: rom_data = 8'h48;
      8'h47: rom_data = 8'hB2;
      8'h48: rom_data = 8'hB9;
      8'h49: rom_data = 8'h72;
      8'h4A: rom_data = 8'h29;
      8'h4B: rom_data = 8'hC2;
      8'h4C: rom_data = 8'h88;
      8'h4D: rom_data = 8'hF4;
      8'h4E: rom_data = 8'h3C;
      8'h4F: rom_data = 8'h64;
      8'h50: rom_data = 8'hBF;
      8'h51: rom_data = 8'h2B;
      8'h52: rom_data = 8'hE2;
      8'h53: rom_data = 8'h98;
      8'h54: rom_data = 8'h1A;
      8'h55: rom_data = 8'h28;
      8'h56: rom_data = 8'h45;
      8'h57: rom_data = 8'h61;
      8'h58: rom_data = 8'h07;
      8'h59: rom_data = 8'hAE;
      8'h5A: rom_data = 8'h76;
      8'h5B: rom_data = 8'h1C;
      8'h5C: rom_data = 8'h43;
      8'h5D: rom_data = 8'h26;
      8'h5E: rom_data = 8'hAD;
      8'h5F: rom_data = 8'h0B;
      8'h60: rom_data = 8'h2C;
      8'h61: rom_data = 8'h8F;
      8'h62: rom_data = 8'h03;
      8'h63: rom_data = 8'h6F;
      8'h64: rom_data = 8'hEA;
      8'h65: rom_data = 8'h3B;
      8'h66: rom_data = 8'h14;
      8'h67: rom_data = 8'h6B;
      8'h68: rom_data = 8'h5D;
      8'h69: rom_data = 8'hEB;
      8'h6A: rom_data = 8'h08;
      8'h6B: rom_data = 8'h95;
      8'h6C: rom_data = 8'hD3;
      8'h6D: rom_data = 8'h9F;
      8'h6E: rom_data = 8'h0E;
      8'h6F: rom_data = 8'hDD;
      8'h70: rom_data = 8'h6B;
      8'h71: rom_data = 8'h74;
      8'h72: rom_data = 8'h6C;
      8'h73: rom_data = 8'hE9;
      8'h74: rom_data = 8'hDF;
      8'h75: rom_data = 8'hA2;
      8'h76: rom_data = 8'h8C;
      8'h77: rom_data = 8'h11;
      8'h78: rom_data = 8'h71;
      8'h79: rom_data = 8'h6D;
      8'h7A: rom_data = 8'hC9;
      8'h7B: rom_data = 8'h6B;
      8'h7C: rom_data = 8'h69;
      8'h7D: rom_data = 8'hE8;
      8'h7E: rom_data = 8'h60;
      8'h7F: rom_data = 8'h1C;
      8'h80: rom_data = 8'h38;
      8'h81: rom_data = 8'h38;
      8'h82: rom_data = 8'h44;
      8'h83: rom_data = 8'h36;
      8'h84: rom_data = 8'h37;
      8'h85: rom_data = 8'h85;
      8'h86: rom_data = 8'h99;
      8'h87: rom_data = 8'hCB;
      8'h88: rom_data = 8'h5B;
      8'h89: rom_data = 8'hE8;
      8'h8A: rom_data = 8'hE0;
      8'h8B: rom_data = 8'hA9;
      8'h8C: rom_data = 8'h61;
      8'h8D: rom_data = 8'hD7;
      8'h8E: rom_data = 8'hA4;
      8'h8F: rom_data = 8'h70;
      8'h90: rom_data = 8'h82;
      8'h91: rom_data = 8'h2B;
      8'h92: rom_data = 8'hC4;
      8'h93: rom_data = 8'h2B;
      8'h94: rom_data = 8'hAA;
      8'h95: rom_data = 8'hB2;
      8'h96: rom_data = 8'h3E;
      8'h97: rom_data = 8'hCF;
      8'h98: rom_data = 8'h79;
      8'h99: rom_data = 8'hBD;
      8'h9A: rom_data = 8'h66;
      8'h9B: rom_data = 8'hF1;
      8'h9C: rom_data = 8'hA4;
      8'h9D: rom_data = 8'hD7;
      8'h9E: rom_data = 8'hB5;
      8'h9F: rom_data = 8'h12;
      8'hA0: rom_data = 8'h9A;
      8'hA1: rom_data = 8'h9F;
      8'hA2: rom_data = 8'h7D;
      8'hA3: rom_data = 8'h51;
      8'hA4: rom_data = 8'h4F;
      8'hA5: rom_data = 8'h1F;
      8'hA6: rom_data = 8'h1E;
      8'hA7: rom_data = 8'hA2;
      8'hA8: rom_data = 8'hDC;
      8'hA9: rom_data = 8'hB8;
      8'hAA: rom_data = 8'h87;
      8'hAB: rom_data = 8'h99;
      8'hAC: rom_data = 8'hAC;
      8'hAD: rom_data = 8'h03;
      8'hAE: rom_data = 8'h63;
      8'hAF: rom_data = 8'h2A;
      8'hB0: rom_data = 8'h0B;
      8'hB1: rom_data = 8'hCC;
      8'hB2: rom_data = 8'h6B;
      8'hB3: rom_data = 8'h25;
      8'hB4: rom_data = 8'h14;
      8'hB5: rom_data = 8'h4E;
      8'hB6: rom_data = 8'h79;
      8'hB7: rom_data = 8'hAE;
      8'hB8: rom_data = 8'hE6;
      8'hB9: rom_data = 8'h6F;
      8'hBA: rom_data = 8'h31;
      8'hBB: rom_data = 8'h74;
      8'hBC: rom_data = 8'h69;
      8'hBD: rom_data = 8'h73;
      8'hBE: rom_data = 8'h48;
      8'hBF: rom_data = 8'hDF;
      8'hC0: rom_data = 8'h22;
      8'hC1: rom_data = 8'hE5;
      8'hC2: rom_data = 8'hF4;
      8'hC3: rom_data = 8'hAD;
      8'hC4: rom_data = 8'h8A;
      8'hC5: rom_data = 8'hF6;
      8'hC6: rom_data = 8'h96;
      8'hC7: rom_data = 8'hE2;
      8'hC8: rom_data = 8'h1F;
      8'hC9: rom_data = 8'h7D;
      8'hCA: rom_data = 8'hEB;
      8'hCB: rom_data = 8'h9C;
      8'hCC: rom_data = 8'h68;
      8'hCD: rom_data = 8'hF1;
      8'hCE: rom_data = 8'hB3;
      8'hCF: rom_data = 8'h75;
      8'hD0: rom_data = 8'hA0;
      8'hD1: rom_data = 8'hB4;
      8'hD2: rom_data = 8'h84;
      8'hD3: rom_data = 8'h21;
      8'hD4: rom_data = 8'h70;
      8'hD5: rom_data = 8'hF7;
      8'hD6: rom_data = 8'h4C;
      8'hD7: rom_data = 8'h91;
      8'hD8: rom_data = 8'h8C;
      8'hD9: rom_data = 8'h20;
      8'hDA: rom_data = 8'h52;
      8'hDB: rom_data = 8'hEB;
      8'hDC: rom_data = 8'h5D;
      8'hDD: rom_data = 8'hCB;
      8'hDE: rom_data = 8'h7C;
      8'hDF: rom_data = 8'h06;
      8'hE0: rom_data = 8'hFE;
      8'hE1: rom_data = 8'hAD;
      8'hE2: rom_data = 8'h7A;
      8'hE3: rom_data = 8'hEC;
      8'hE4: rom_data = 8'h9C;
      8'hE5: rom_data = 8'h38;
      8'hE6: rom_data = 8'h21;
      8'hE7: rom_data = 8'h10;
      8'hE8: rom_data = 8'hE6;
      8'hE9: rom_data = 8'h6C;
      8'hEA: rom_data = 8'hA3;
      8'hEB: rom_data = 8'hDA;
      8'hEC: rom_data = 8'hD3;
      8'hED: rom_data = 8'h1B;
      8'hEE: rom_data = 8'h95;
      8'hEF: rom_data = 8'h42;
      8'hF0: rom_data = 8'h5D;
      8'hF1: rom_data = 8'hEE;
      8'hF2: rom_data = 8'hBD;
      8'hF3: rom_data = 8'h96;
      8'hF4: rom_data = 8'h0E;
      8'hF5: rom_data = 8'hBF;
      8'hF6: rom_data = 8'hDD;
      8'hF7: rom_data = 8'h4C;
      8'hF8: rom_data = 8'h61;
      8'hF9: rom_data = 8'hA5;
      8'hFA: rom_data = 8'hD1;
      8'hFB: rom_data = 8'h8A;
      8'hFC: rom_data = 8'hF7;
      8'hFD: rom_data = 8'h1F;
      8'hFE: rom_data = 8'h48;
      8'hFF: rom_data = 8'h6C;

      default: rom_data = 8'h00;
    endcase
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_addr_r <= 0;
      rom_data_r <= 0;
    end else begin
      rom_addr_r <= rom_addr;
      rom_data_r <= rom_data;
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