import random

with open("rom.v", "w") as rom:
    for i in range(256):
        rom.write(f"      8'h{i:02X}: begin")
        rom.write(f"  rom_data_h = 4'h{random.randint(0,15):02X};")
        rom.write(f"  rom_data_l = 4'h{random.randint(0,15):02X};")
        rom.write(f"  end\n")
        # rom.write(f"  rom_content[{i}] = 8'h{random.randint(0,255):02X};\n")
        # rom.write(f"  rom_content_h[{i}] = 4'h{random.randint(0,15):01X}; ")
        # rom.write(f"  rom_content_l[{i}] = 4'h{random.randint(0,15):01X};\n")
    rom.close()