import random

with open("rom.v", "w") as rom:
    for i in range(1024):
        # rom.write(f"      8'h{i:03X}: rom_data = 8'h{random.randint(0,255):02X};\n")
        rom.write(f"  rom_content[{i}] = 8'h{random.randint(0,255):02X};\n")
        # rom.write(f"  rom_content_h[{i}] = 4'h{random.randint(0,15):01X}; ")
        # rom.write(f"  rom_content_l[{i}] = 4'h{random.randint(0,15):01X};\n")
    rom.close()