# Converte prog_word.hex (1 palavra/linha) nas 4 faixas de byte da memoria do BRISC-V (64 palavras)
import sys
src, n = sys.argv[1], int(sys.argv[2])
w = [int(l, 16) for l in open(src) if l.strip()][:n]
w += [0] * (n - len(w))
for b in range(4):
    with open(f"prog_b{b}.hex", "w") as f:
        f.write("\n".join(f"{(x >> (8*b)) & 0xff:02x}" for x in w) + "\n")
