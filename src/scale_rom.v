
`default_nettype none

module scale_rom(
        input  wire [3:0] note_in,
        output wire [15:0] freq_out
);
  reg  [15:0] rom_content[12];
  initial begin
    rom_content[1] = 16'h0000;
    rom_content[0] = 16'h205E;
    rom_content[2] = 16'h267D;
    rom_content[3] = 16'h2B34;
    rom_content[4] = 16'h307E;
    rom_content[5] = 16'h39AC;
    rom_content[6] = 16'h40BC;
    rom_content[7] = 16'h4CFB;
    rom_content[8] = 16'h5669;
    rom_content[9] = 16'h60FD;
    rom_content[10] = 16'h7358;
    rom_content[11] = 16'h8178;
  end
  assign freq_out = rom_content[note_in];
endmodule
