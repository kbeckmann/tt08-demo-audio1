/*
* Copyright (c) 2024 Konrad Beckmann
* Copyright (c) 2024 Linus Mårtensson
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
wire audio_sample;

`ifdef VERILATOR
  assign audio_en = 1'b0;
  assign audio_out = {audio_sample, 15'b000000000000000};
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

assign audio_pdm = audio_sample;

`define ENABLE_AUDIO
`ifdef ENABLE_AUDIO
  reg [24:0] ctr_audio;
  reg [7:0] ctr_clkdiv25;
  reg pulse_1MHz;

  always @(posedge clk) begin
    if (~rst_n) begin
      ctr_clkdiv25 <= 0;
      ctr_audio <= 0;
      pulse_1MHz <= 0;
    end else begin
      ctr_clkdiv25 <= ctr_clkdiv25 + 1;
      if (ctr_clkdiv25 == 25) begin
        ctr_clkdiv25 <= 0;
        ctr_audio <= ctr_audio + 1;
        pulse_1MHz <= 1'b1;
      end else begin
        pulse_1MHz <= 1'b0;
      end
    end
  end

  wire [ 3:0] note_in;
  wire [15:0] freq_out;

  assign note_in = 
      {3'b000, ctr_audio[17]}
    + {3'b000, ctr_audio[19]}
    + (
        (
          ctr_audio[21] +
          ctr_audio[17] - 
          ctr_audio[22]
        ) == 2 ? 1 : 0
    )
    + (
        (
          ctr_audio[21] + 
          ctr_audio[22] + 
          ctr_audio[23]
        ) == 3 ? 4 : 0
    )
    + (
        (
          ctr_audio[21] + 
          ctr_audio[22]
        ) == 2 ? 2 : 0
    );

  scale_rom scale_rom_instance(
    .note_in(note_in),
    .freq_out(freq_out)
  );

  wire voice1;
  wire [11:0] pulsewidth = (1<<9) + {3'b000, ctr_audio[18:10]} + {1'b0, ctr_audio[23], 10'b0000000000};

  voice #()
      Voice1(
          .clk(clk),
          .rst_n(rst_n),
          .en(pulse_1MHz),
          .frequency((freq_out >> 3)),
          .pulsewidth(pulsewidth),
          .voice(voice1)
  );

  assign audio_sample = voice1;

// Audio end
`else
  assign audio_sample = 0;
`endif

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

reg  [11:0] counter;
wire [23:0] VAL;
reg   [7:0] r, g, b;
reg   [5:0] LFSR = 1;
reg  [12:0] yq, yqo, xq, xqo;

function reg[7:0] tria (input reg[7:0] a);
  tria = a > 127 ? 255 - a : a;
endfunction;

assign VAL[7:0]   = r;
assign VAL[15:8]  = g;
assign VAL[23:16] = b;

wire [11:0] tmp1 = (
                {2'b0, pix_x} 
                + (counter<<3)
              ) >> 4;

wire [12:0] tmp2 = ((xq>>4) - (yq>>5));
wire [11:0] tmp3 = (
        {4'b0, tria(tmp2[7:0])}
        + (
          {2'b0,
            (pix_x>>2) + (pix_y>>3)
          }
        )
        - 20
      );
wire [11:0] tmp4 = (
                {2'b0, pix_y}
                + (counter << 2)
              ) >> 1;

wire _unused_truncate = &{tmp1, tmp2, tmp3, tmp4};

always @(posedge clk) begin
  if(~rst_n) begin
    LFSR <= 1;
    yq <= 0;
    yqo <= 0;
    xq <= 0;
    xqo <= 0;
    r <= 0;
    g <= 0;
    b <= 0;
  end else begin

    r <= tria(pix_x[9:2] - 80) < 32 ? tmp3[7:0] : 0;
    g <= r + {3'b0, pix_y[8:4]};
    b <= g + {3'b0, pix_y[8:4]};    
    
    xq <= xqo 
      + (
        {5'b0,
          tria(
            tmp1[7:0]
          ) >> 4
        }
      )
      + 22;
    xqo <= xq;
    if (hsync) begin
      yq <= yqo
        + {5'b0,
          tria(tmp4[7:0]) >> 2
        }
        - 22;
      xq <= 0;
    end else begin
      yqo <= yq;
    end
    if (vsync) begin
      LFSR <= 1;
      yq <= 0;
      yqo <= 0;
    end else begin
      LFSR[5:1] <= LFSR[4:0];
      LFSR[0]   <= LFSR[2] ^ LFSR[1];
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
