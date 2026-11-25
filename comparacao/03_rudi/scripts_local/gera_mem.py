# Gera copias de program_memory_test.vhd / ram_memory_test.vhd com o programa do TCC.
# Uso: python -I gera_mem.py <dir 03_rudi>
import re, sys, os
d = sys.argv[1]
prog = os.path.join(d, '..', 'programa')
def words(f):
    return [l.strip() for l in open(os.path.join(prog, f)) if l.strip()]
def patch(src, dst, ws, others):
    t = open(src).read()
    m = re.search(r'(:= \(\n)(.*?)(\n\s*others\s*=>[^\n]*\n)', t, re.S)
    body = ''.join('         %d => x"%s",\n' % (i, w.lower()) for i, w in enumerate(ws))
    t = t[:m.start(2)] + body.rstrip('\n') + '\n         others => ' + others + '\n' + t[m.end(3):]
    open(dst, 'w', newline='\n').write(t)
r = os.path.join(d, 'repo', 'src', 'program_memory')
patch(os.path.join(r, 'program_memory_test.vhd'), os.path.join(d, 'patch', 'program_memory_tcc.vhd'),
      words('prog_word.hex'), '(others => \'0\')')
patch(os.path.join(r, 'ram_memory_test.vhd'), os.path.join(d, 'patch', 'ram_memory_tcc.vhd'),
      words('data_word.hex'), '(others => \'0\'));')
