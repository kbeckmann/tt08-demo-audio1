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
  wire [12:0] audio_sample;

  // TinyVGA PMOD
  // assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uo_out = 8'b00000000;

  // Audio PMOD
  assign uio_out = {audio_out, 7'b0000000};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

// Audio start
  pdm #(.N(16)) pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );



  reg [24:0] counter;
  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  wire [ 3:0] note_in;
  wire [15:0] freq_out;

  wire [ 3:0] note_in2;
  wire [15:0] freq_out2;

  // assign note_in = counter[20] ^ counter[19:17] & counter[22:20];
  // assign note_in = counter[19:16] & counter[23:20];
  assign note_in = counter[19:17] & counter[23:20];
  // assign note_in = counter[16];
  assign note_in2 = 3 + (counter[21:18] & counter[23:21]);

  // assign note_in = counter[20:17];
  // assign note_in = 0;

  scale_rom scale_rom_instance2(
    .note_in(note_in2),
    .freq_out(freq_out2)
  );
  scale_rom scale_rom_instance(
    .note_in(note_in),
    .freq_out(freq_out)
  );

  wire [11:0] voice1;
 wire [11:0] voice2;

  // wire [15:0] frequency1 = freq_out;
  // reg [ 7:0] control1 = (counter[16] & counter[17])<<6;
  wire gate1 = counter[17:0] < (1 << 16);
  wire gate2 = counter[18:0] < (1 << 17);
  reg [ 7:0] control1 = {7'b0001000, gate1};
  reg [ 7:0] control2 = {7'b0100000, gate2};
  // reg [11:0] pulsewidth1 = (1<<9);

 wire msb;

  voice #()
      Voice1(
          .clk_1MHz(clk),
          .reset(~rst_n),
          // .frequency((freq_out >> 1) + (freq_out == 0 ? 0: counter[17:10])),
          .frequency((freq_out >> 3)),
          .pulsewidth(1<<11),
          .control(control1),
          .Att_dec(8'h29),
          .Sus_Rel(8'h79),
          .PA_MSB_in(),
          .PA_MSB_out(),
          .voice(voice1)
      );
  // voice #()
  //     Voice2(
  //         .clk_1MHz(clk),
  //         .reset(~rst_n),
  //         // .frequency((freq_out >> 1) + (freq_out == 0 ? 0: counter[17:10])),
  //         .frequency(freq_out2 >> 1),
  //         .pulsewidth(1<<9),
  //         .control(control2),
  //         .Att_dec(8'h6F),
  //         .Sus_Rel(8'h7A),
  //         .PA_MSB_in(msb),
  //         .PA_MSB_out(),
  //         .voice(voice2)
  //     );

  // assign audio_sample = voice1 + voice2;
  assign audio_sample = voice1;

// Audio end

  
endmodule