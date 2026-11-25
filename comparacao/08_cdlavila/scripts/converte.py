# Converte o programa da comparacao para os formatos do cdlavila:
#  - Instructions.txt: IMEM de 1 KiB em bytes, ordem BIG-ENDIAN por palavra (Memory[A] = byte mais
#    significativo), 4 bytes por linha; truncado em 256 instrucoes (1024 B).
#  - Memory.txt: DMEM de 1 KiB, 1 byte por linha, little-endian (byte do endereco 0 primeiro).
import sys, pathlib
prog, data, out = map(pathlib.Path, sys.argv[1:4])
words = [l.strip() for l in prog.read_text().split() if l.strip()]
words = words[:256]
lines = [' '.join(w.zfill(8)[i:i+2].upper() for i in range(0, 8, 2)) for w in words]
(out / 'Instructions.txt').write_text('\n'.join(lines) + '\n')
b = [l.strip().upper().zfill(2) for l in data.read_text().split() if l.strip()]
b += ['00'] * (1024 - len(b))
(out / 'Memory.txt').write_text('\n'.join(b) + '\n')
print(len(words), 'instrucoes;', len(b), 'bytes de dados')
