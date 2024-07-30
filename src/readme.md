# Audio


Sequence

on/off

0 1 2 3 4 5 6 7 ... 30 31





## Bit pattern

```
bit | desc
0     On (1) or Command (0)
1     Note 0
2     Note 1
3     Note 2
4     Note 3
5     Effect
6     Effect
7     Effect

```

4 bit = 0x0 - 0xF -> C0, D0, E0, F0, G0, A0, B0, C1, D1, E1, F1, G1, A1, B1, C2, D2
                      0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
# Effects

Arpeggio

0 - 047 Major
1 - 037 Minor

