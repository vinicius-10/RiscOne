# familias.tcl - pior folga de setup por familia de caminho do core monociclo.
#
# Chamado pelo synth.ps1 com o design (sintetizado ou implementado) aberto. Escreve
# no diretorio corrente:
#   familias.txt      uma linha por familia: folga, niveis de logica, atraso total,
#                     logica, rota, origem -> destino
#   familias_det.txt  report_timing completo do pior caminho de cada familia
#
# As familias ficam empatadas a poucos decimos de ns; olhar so o WNS esconde uma
# mudanca que melhora uma familia sem piorar as outras. "-" numa linha = nenhum
# caminho da familia entre os piores considerados (folga bem maior que as outras).

proc fam_cells {filter} { return [get_cells -hier -quiet -filter $filter] }

set rf_ram [fam_cells {IS_PRIMITIVE && REF_NAME =~ RAM* && NAME =~ *register_file_inst/*}]
set dm_ram [fam_cells {IS_PRIMITIVE && REF_NAME =~ RAM* && NAME =~ *data_memory_inst/*}]
set pc_ff  [fam_cells {IS_SEQUENTIAL && REF_NAME =~ FD* && NAME =~ *search_inst/*}]
set io_ff  [fam_cells {IS_SEQUENTIAL && REF_NAME =~ FD* && NAME =~ *data_memory_inst/mmio_inst/io_out*}]

array unset ::fam_is_rf
array unset ::fam_is_dm
foreach c $rf_ram { set ::fam_is_rf($c) 1 }
foreach c $dm_ram { set ::fam_is_dm($c) 1 }

# 1 se o caminho passa por alguma celula do conjunto (array global) dado.
proc fam_path_has {p arrname} {
    upvar #0 $arrname arr
    foreach c [get_cells -quiet -of_objects $p] {
        if {[info exists arr($c)]} { return 1 }
    }
    return 0
}

# Primeiro caminho (pior folga) que passa (want = 1) ou nao (want = 0) pelo conjunto.
proc fam_first {paths arrname want} {
    foreach p $paths {
        if {[fam_path_has $p $arrname] == $want} { return $p }
    }
    return {}
}

proc fam_line {name p} {
    if {$p eq {}} { return [format "%-20s %8s" $name "-"] }
    return [format "%-20s %8.3f %4d %7.3f %7.3f %7.3f  %s -> %s" $name \
        [get_property SLACK $p] [get_property LOGIC_LEVELS $p] \
        [get_property DATAPATH_DELAY $p] [get_property DATAPATH_LOGIC_DELAY $p] \
        [get_property DATAPATH_NET_DELAY $p] \
        [get_property STARTPOINT_PIN $p] [get_property ENDPOINT_PIN $p]]
}

proc fam_out {fh name p} {
    puts $fh [fam_line $name $p]
    if {$p ne {}} {
        set d [open familias_det.txt a]
        puts $d "\n==================== $name ===================="
        close $d
        report_timing -of_objects $p -file familias_det.txt -append
    }
}

file delete -force familias_det.txt
set fh [open familias.txt w]
puts $fh [format "%-20s %8s %4s %7s %7s %7s  %s" familia folga niv atraso logica rota "origem -> destino"]

# Proximo PC: laco instrucao -> ... -> mux do proximo PC -> ROM -> instrucao/PC.
# "com leitura do RF" = comparador do desvio e alvo do JALR; "sem" = decodificacao
# e alvo relativo ao PC.
set ps [get_timing_paths -quiet -setup -sort_by slack -max_paths 3000 -nworst 40 -to $pc_ff]
fam_out $fh proximo_pc         [lindex $ps 0]
fam_out $fh pc_com_leitura_rf  [fam_first $ps ::fam_is_rf 1]
fam_out $fh pc_sem_leitura_rf  [fam_first $ps ::fam_is_rf 0]

# Escrita no banco de registradores: vinda da RAM de dados (load) ou nao (ALU,
# deslocamento, flags de regiao, MMIO, PC+4).
set ps [get_timing_paths -quiet -setup -sort_by slack -max_paths 5000 -nworst 60 -to $rf_ram]
fam_out $fh rf_via_ram_dados   [fam_first $ps ::fam_is_dm 1]
fam_out $fh rf_sem_ram_dados   [fam_first $ps ::fam_is_dm 0]

# Escrita na RAM de dados (store) e nas saidas MMIO.
fam_out $fh store_ram_dados    [lindex [get_timing_paths -quiet -setup -max_paths 1 -to $dm_ram] 0]
fam_out $fh mmio_saidas        [lindex [get_timing_paths -quiet -setup -max_paths 1 -to $io_ff] 0]
close $fh
