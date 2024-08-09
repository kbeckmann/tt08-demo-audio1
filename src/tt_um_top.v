/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_top(
`ifdef VERILATOR
  // Extra signals for web simulator
  output wire        audio_en , // Audio Enabled. Set to false to enable video rendering
  output wire [15:0] audio_out, // Audio sample output
  output wire [31:0] clk_hz,    // clk frequency in Hz. Output consumed by simulator to adjust sampling rate (when to consume audio_out)
`endif

  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

// ------------------------------
// Audio signals
wire audio_pdm;
wire [11:0] audio_sample;

`ifdef VERILATOR
  // assign clk_hz = 48000 * 21; // Close enough to 1MHz, but integer factor of 48kHz
  // assign audio_en = 1'b1;
  assign audio_en = 1'b0;
  assign audio_out = {4'b0, audio_sample} <<  4;
  // assign audio_out = ((mix1 + mix2 + mix3 + mix4) << 5);
  // assign audio_out = (mix8 << 6);
  // assign clk_hz = 1000000;

  assign clk_hz = 25000000; // This is reality
`endif

// ------------------------------
// VGA signals
wire hsync;
wire vsync;
wire [1:0] R;
wire [1:0] G;
wire [1:0] B;
wire video_active;
wire [9:0] pix_x;
wire [9:0] pix_y;

// TinyVGA PMOD
assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

// Audio PMOD
// assign uio_out = {audio_pdm, 7'b0000000};
assign uio_out = {audio_pdm, video_active, 6'b000000};
assign uio_oe = 8'b10000000;

// Suppress unused signals warning
wire _unused_ok = &{ena, ui_in, uio_in};

// ------------------------------
// Audio start
pdm #(.N(12)) pdm_gen(
  .clk(clk),
  .rst_n(rst_n),
  .pdm_in(audio_sample),
  .pdm_out(audio_pdm)
);
  reg [24:0] ctr_audio;
  reg [7:0] ctr_clkdiv25;
  reg clk_1MHz;
  always @(posedge clk) begin
    if (~rst_n) begin
      ctr_clkdiv25 <= 0;
      ctr_audio <= 0;
    end else begin
      if (ctr_clkdiv25 != 8'd25) begin
        ctr_clkdiv25 <= ctr_clkdiv25 + 8'b1;
        clk_1MHz <= 1'b0;
      end else begin
        ctr_audio <= ctr_audio + 1;
        ctr_clkdiv25 <= 8'b0;
        clk_1MHz <= 1'b1;
      end        
      // ctr_audio <= ctr_audio + 1;
    end
  end

  wire [ 3:0] note_in;
  wire [15:0] freq_out;

  wire [ 3:0] note_in2;
  wire [15:0] freq_out2;

  assign note_in = ctr_audio[17] + ctr_audio[19] + (ctr_audio[21]+ctr_audio[17]-ctr_audio[22]==2?1:0) + (ctr_audio[21]+ctr_audio[22]+ctr_audio[23]==3?4:0) + (ctr_audio[21]+ctr_audio[22]==2?2:0);
  assign note_in2 = (ctr_audio[19]<<1) + (ctr_audio[23]+ctr_audio[22]<<1);

  // assign note_in = ctr_audio[20:17];
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
  // reg [ 7:0] control1 = (ctr_audio[16] & ctr_audio[17])<<6;
  wire gate1 = ctr_audio[17:0] < (1 << 16);
  wire gate2 = ctr_audio[21:0] < (1 << 20);
  reg slap =  ctr_audio[16];
  reg [ 7:0] control1; 
  assign control1 = {1'b0, 6'b101000, gate1};
  reg [ 7:0] control2;
  assign control2 = {slap, 6'b100000, gate2};
  // reg [11:0] pulsewidth1 = (1<<9);

 wire msb;

  voice #()
      Voice1(
          .clk_1MHz(clk_1MHz),
          .reset(~rst_n),
          // .frequency((freq_out >> 1) + (freq_out == 0 ? 0: ctr_audio[17:10])),
          .frequency((freq_out >> 3)),
          .pulsewidth((1<<9) + ctr_audio[18:10] + (ctr_audio[23]<<10)),
          .control(control1),
          .Att_dec(8'h00),
          .Sus_Rel(8'hff),
          .PA_MSB_in(),
          .PA_MSB_out(msb),
          .voice(voice1)
      );
  voice #()
      Voice2(
          .clk_1MHz(clk_1MHz),
          .reset(~rst_n),
          // .frequency((freq_out >> 1) + (freq_out == 0 ? 0: ctr_audio[17:10])),
          .frequency(freq_out2 >> 1 + (slap<<3)),
          .pulsewidth((1<<6) + ctr_audio[20:10]),
          .control(control2),
          .Att_dec(8'h00),
          .Sus_Rel(8'hFF),
          .PA_MSB_in(msb),
          .PA_MSB_out(),
          .voice(voice2)
      );

    assign audio_sample = voice1 + (voice2);
    // assign audio_out = voice2;

// Audio end

// ------------------------------
// VGA start
hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
);

reg [11:0] counter;
reg [23:0] VAL;
reg top, bottom, left, right;
reg [10:0] rxy, pxy;
reg  [5:0] LFSR = 1;
reg [7:0] T, xl, yl, bottom_l, back_l, top_a, top_b, top_l;
reg fg;
reg lh, bh;
reg [7:0] fgg, fgb;

function reg[18:0] max ( input reg [18:0] a, b);
  max = a > b ? a : b;
endfunction
function reg[19:0] min ( input reg[19:0] a, b);
  min = a < b ? a : b;
endfunction
function reg[7:0] abs ( input reg[7:0] a);
  abs = a[7]?-a:a;
endfunction
function reg[7:0] tria (input reg[7:0] a);
  tria = a > 127 ? 255 - a : a;
endfunction;

reg [19:0] yq, yqo, xq, xqo;
reg [9:0] limy;
reg [7:0] r,g,b;

always @(posedge clk) begin
  if(~rst_n) begin
    top <= 0; bottom <= 0; left <= 0; right <= 0;
    rxy <= 0; pxy <= 0;
    LFSR <= 1;
    //TODO rst all the things^
  end else begin

    
    VAL[7:0]   <= r;
    VAL[15:8]  <= g;
    VAL[23:16] <= b;
    
    r <= tria((pix_x>>2)-80)<32?(tria((((xq>>4))-(yq>>5)))+((pix_x>>2)+(pix_y>>3))-20):0;
    g <= r + (pix_y>>4);
    b <= g + (pix_y>>4);
    
    
    xq <= xqo + (tria(pix_x+(counter<<3)>>4)>>4)+22;
    xqo <= xq;
    if (hsync) begin
      yq <= yqo + (tria(pix_y+(counter<<2)>>1)>>2)-22;
      xq <= 0;
    end else begin
      yqo <= yq;
    end
    if (vsync) begin
      LFSR <= 1;
      yq <= 0;
      yqo <= 0;
    end else begin
      LFSR[5:1]   <= LFSR[4:0];
      LFSR[0]   <= LFSR[2]^LFSR[1];
    end
  end
end


assign R = video_active ? (
        (VAL[7:6]) + (LFSR[5:0] < VAL[5:0])
    ) : 2'b00;
assign G = video_active ? (
        (VAL[15:14]) + (LFSR[5:0] < VAL[13:8])
    ) : 2'b00;
assign B = video_active ? (
        (VAL[23:22]) + (LFSR[5:0] < VAL[21:16])
    ) : 2'b00;

always @(posedge vsync) begin
    if (~rst_n) begin
    counter <= 0;
    end else begin
    counter <= counter + 1;
    end
end

// VGA end

endmodule

