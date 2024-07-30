semitone = lambda x: 7382 * (2 ** (x / 12))

c_maj = [0, 2, 4, 5, 7, 9, 11, 12, 12+2, 12+4, 12+5, 12+7, 12+9, 12+11, 12+12]
d_min = [   2, 4, 5, 7, 9, 11, 12, 12+2, 12+4, 12+5, 12+7, 12+9, 12+11, 12+12, 24+2]
a_min = [               9, 11, 12, 12+2, 12+4, 12+5, 12+7, 12+9, 12+11, 12+12, 24+2, 24+4, 24+5, 24+7]
d_pen = [   2,    5, 7, 9,     12, 12+2,       12+5, 12+7, 12+9,        12+12, 24+2]

# scale = c_maj
# scale = d_min
scale = d_pen
# scale = a_min

mem = [0]
for x in scale:
    mem.append(int(semitone(x)))

with open("scale_rom.v", "w") as rom:
    header = """
`default_nettype none

module scale_rom(
        input  wire [3:0] note_in,
        output wire [15:0] freq_out
);
"""
    rom.write(header)
    rom.write(f"  reg  [15:0] rom_content[{len(mem)}];\n")
    rom.write(f"  initial begin\n")

    for i, x in enumerate(mem):
        rom.write(f"    rom_content[{i}] = 16'h{x:04X};\n")

    rom.write(f"  end\n")
    rom.write(f"  assign freq_out = rom_content[note_in];\n")
    rom.write("endmodule\n")

    rom.close()