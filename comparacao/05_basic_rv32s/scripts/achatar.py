# Gera patch/RV32I37F_flat.v: expande os `include "modules/..." do RV32I37F (patch) recursivamente,
# cada arquivo uma vez, procurando primeiro em patch/ e depois em repo/RV32I/. Nao altera logica.
import io, os, re, sys
base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
dirs = [os.path.join(base, 'patch'), os.path.join(base, 'repo', 'RV32I')]
seen = set(); out = []
def find(rel):
    for d in dirs:
        p = os.path.join(d, rel)
        if os.path.exists(p): return p
    sys.exit('nao achei ' + rel)
def expand(p):
    if p in seen: return
    seen.add(p)
    out.append('// ===== ' + os.path.relpath(p, base).replace(os.sep, '/') + '\n')
    for line in io.open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n').split('\n'):
        m = re.match(r'\s*`include\s+"([^"]+)"', line)
        if m: expand(find(m.group(1)))
        else: out.append(line + '\n')
expand(find('modules/RV32I37F.v'))
io.open(os.path.join(base, 'patch', 'RV32I37F_flat.v'), 'w', encoding='utf-8', newline='\n').write(''.join(out))
