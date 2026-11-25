import sys
src, dst, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
lines = [l.strip() for l in open(src) if l.strip()]
open(dst, 'w').write('\n'.join(lines[:n]) + '\n')
print(len(lines), '->', min(n, len(lines)))
