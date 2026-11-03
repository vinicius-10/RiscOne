# File saved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 threadsafe
# 
# non-default properties - (restore without -noprops)
property -colorscheme classic
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 12
property maxzoom 5
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #0095ff
property objecthighlight4 #8000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #0000ff
property overlaycolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 4
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 12
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 1
property timelimit 1
#
module new top_core work:top_core:NOFILE -nosplit
load symbol IBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol OBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol BUFG hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol core work:core:NOFILE HIERBOX pin BTNC_IBUF input.left pin BTND_IBUF input.left pin BTNL_IBUF input.left pin BTNR_IBUF input.left pin BTNU_IBUF input.left pin CPU_RESETN_IBUF input.left pin clk_IBUF_BUFG input.left pin lopt output.right pin lopt_1 output.right pin lopt_10 output.right pin lopt_11 output.right pin lopt_12 output.right pin lopt_13 output.right pin lopt_14 output.right pin lopt_15 output.right pin lopt_16 output.right pin lopt_17 output.right pin lopt_18 output.right pin lopt_19 output.right pin lopt_2 output.right pin lopt_20 output.right pin lopt_21 output.right pin lopt_22 output.right pin lopt_23 output.right pin lopt_24 output.right pin lopt_25 output.right pin lopt_26 output.right pin lopt_27 output.right pin lopt_28 output.right pin lopt_29 output.right pin lopt_3 output.right pin lopt_30 output.right pin lopt_31 output.right pin lopt_4 output.right pin lopt_5 output.right pin lopt_6 output.right pin lopt_7 output.right pin lopt_8 output.right pin lopt_9 output.right pin pc_next_carry__0_i_1 input.left pin pc_next_carry__0_i_1_0 input.left pin pc_next_carry__0_i_1_1 input.left pin pc_next_carry__0_i_1_2 input.left pin pc_next_carry__0_i_2_n_0_repN_1_alias input.left pin pc_next_carry__0_i_2_n_0_repN_2_alias input.left pin pc_next_carry__0_i_2_n_0_repN_3_alias input.left pin pc_next_carry__0_i_2_n_0_repN_4_alias input.left pin pc_next_carry__0_i_2_n_0_repN_5_alias input.left pin pc_next_carry__0_i_2_n_0_repN_6_alias input.left pin pc_next_carry__0_i_2_n_0_repN_7_alias input.left pin pc_next_carry__0_i_2_n_0_repN_8_alias input.left pin pc_next_carry__0_i_2_n_0_repN_alias input.left pin pc_next_carry__0_i_3_n_0_repN_1_alias input.left pin pc_next_carry__0_i_3_n_0_repN_2_alias input.left pin pc_next_carry__0_i_3_n_0_repN_3_alias input.left pin pc_next_carry__0_i_3_n_0_repN_4_alias input.left pin pc_next_carry__0_i_3_n_0_repN_5_alias input.left pin pc_next_carry__0_i_3_n_0_repN_6_alias input.left pin pc_next_carry__0_i_3_n_0_repN_7_alias input.left pin pc_next_carry__0_i_3_n_0_repN_alias input.left pin pc_next_carry_i_2 input.left pin pc_next_carry_i_2_0 input.left pin pc_next_carry_i_2_1 input.left pin pc_next_carry_i_2_n_0_repN_1_alias input.left pin pc_next_carry_i_2_n_0_repN_2_alias input.left pin pc_next_carry_i_2_n_0_repN_3_alias input.left pin pc_next_carry_i_2_n_0_repN_4_alias input.left pin pc_next_carry_i_2_n_0_repN_5_alias input.left pin pc_next_carry_i_2_n_0_repN_6_alias input.left pin pc_next_carry_i_2_n_0_repN_7_alias input.left pin pc_next_carry_i_2_n_0_repN_alias input.left pin pc_next_carry_i_3_n_0_repN_10_alias input.left pin pc_next_carry_i_3_n_0_repN_11_alias input.left pin pc_next_carry_i_3_n_0_repN_12_alias input.left pin pc_next_carry_i_3_n_0_repN_1_alias input.left pin pc_next_carry_i_3_n_0_repN_2_alias input.left pin pc_next_carry_i_3_n_0_repN_3_alias input.left pin pc_next_carry_i_3_n_0_repN_4_alias input.left pin pc_next_carry_i_3_n_0_repN_5_alias input.left pin pc_next_carry_i_3_n_0_repN_6_alias input.left pin pc_next_carry_i_3_n_0_repN_7_alias input.left pin pc_next_carry_i_3_n_0_repN_8_alias input.left pin pc_next_carry_i_3_n_0_repN_9_alias input.left pin pc_next_carry_i_3_n_0_repN_alias input.left pin pc_reg_reg[12]_0 input.left pin pc_reg_reg[12]_1 input.left pin reset_i output.right pinBus JA_IBUF input.left [3:0] pinBus Q output.right [15:0] pinBus pc_reg_reg[12] output.right [8:0] pinBus pmod_col_o_reg[3] output.right [3:0] pinBus seg7_o_reg[15] output.right [15:0] pinBus switch_IBUF input.left [15:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol data_memory work:data_memory:NOFILE HIERBOX pin BTNC_IBUF input.left pin BTND_IBUF input.left pin BTNL_IBUF input.left pin BTNR_IBUF input.left pin BTNU_IBUF input.left pin O_alias output.right pin O_alias_1 output.right pin alu_result__0[1]_alias input.left pin clk_IBUF_BUFG input.left pin lopt output.right pin lopt_1 output.right pin lopt_10 output.right pin lopt_11 output.right pin lopt_12 output.right pin lopt_13 output.right pin lopt_14 output.right pin lopt_15 output.right pin lopt_16 output.right pin lopt_17 output.right pin lopt_18 output.right pin lopt_19 output.right pin lopt_2 output.right pin lopt_20 output.right pin lopt_21 output.right pin lopt_22 output.right pin lopt_23 output.right pin lopt_24 output.right pin lopt_25 output.right pin lopt_26 output.right pin lopt_27 output.right pin lopt_28 output.right pin lopt_29 output.right pin lopt_3 output.right pin lopt_30 output.right pin lopt_31 output.right pin lopt_4 output.right pin lopt_5 output.right pin lopt_6 output.right pin lopt_7 output.right pin lopt_8 output.right pin lopt_9 output.right pin mem_reg_0_255_31_31_0[21]_repN_1_alias output.right pin mem_reg_0_255_31_31_0[21]_repN_2_alias output.right pin mem_reg_0_255_31_31_0[21]_repN_alias output.right pin pmod_col_o_reg[0]_0 input.left pin pmod_col_o_reg[1]_0 input.left pin pmod_col_o_reg[2]_0 input.left pin pmod_col_o_reg[3]_1 input.left pin register_file_reg_r1_0_31_0_5_i_178_0 input.left pin register_file_reg_r1_0_31_0_5_i_178_1 input.left pin register_file_reg_r1_0_31_0_5_i_178_2 input.left pin register_file_reg_r1_0_31_0_5_i_178_3 input.left pin register_file_reg_r1_0_31_0_5_i_24_0 input.left pin register_file_reg_r1_0_31_0_5_i_24_1 input.left pin register_file_reg_r1_0_31_0_5_i_24_2 input.left pin register_file_reg_r1_0_31_0_5_i_24_3 input.left pin register_file_reg_r1_0_31_0_5_i_24_4 input.left pin register_file_reg_r1_0_31_0_5_i_28_0 input.left pin register_file_reg_r1_0_31_0_5_i_29 input.left pin register_file_reg_r1_0_31_0_5_i_29_0 input.left pin register_file_reg_r1_0_31_0_5_i_29_1 input.left pin register_file_reg_r1_0_31_0_5_i_30_1 input.left pin register_file_reg_r1_0_31_0_5_i_32_1 input.left pin register_file_reg_r1_0_31_0_5_i_34_0 input.left pin register_file_reg_r1_0_31_0_5_i_36_0 input.left pin register_file_reg_r1_0_31_18_23_i_11_0 input.left pin register_file_reg_r1_0_31_24_29_i_11_0 input.left pin register_file_reg_r1_0_31_24_29_i_13_0 input.left pin register_file_reg_r1_0_31_24_29_i_15_0 input.left pin register_file_reg_r1_0_31_24_29_i_17_0 input.left pin register_file_reg_r1_0_31_24_29_i_7_0 input.left pin register_file_reg_r1_0_31_24_29_i_7_1 input.left pin register_file_reg_r1_0_31_24_29_i_7_2 input.left pin register_file_reg_r1_0_31_24_29_i_7_3 input.left pin register_file_reg_r1_0_31_24_29_i_7_4 input.left pin register_file_reg_r1_0_31_24_29_i_9_0 input.left pin register_file_reg_r1_0_31_30_31__0_i_2_0 input.left pin register_file_reg_r1_0_31_30_31_i_2_0 input.left pin register_file_reg_r1_0_31_6_11_i_11_0 input.left pin register_file_reg_r1_0_31_6_11_i_39_0 input.left pin register_file_reg_r1_0_31_6_11_i_39_1 input.left pin register_file_reg_r1_0_31_6_11_i_39_2 input.left pin register_file_reg_r1_0_31_6_11_i_39_3 input.left pin seg7_o_reg[10]_0 input.left pin seg7_o_reg[11]_0 input.left pin seg7_o_reg[12]_0 input.left pin seg7_o_reg[13]_0 input.left pin seg7_o_reg[14]_0 input.left pin seg7_o_reg[15]_1 input.left pin seg7_o_reg[1]_0 output.right pin seg7_o_reg[2]_0 output.right pin seg7_o_reg[3]_0 output.right pin seg7_o_reg[4]_0 input.left pin seg7_o_reg[5]_0 input.left pin seg7_o_reg[6]_0 input.left pin seg7_o_reg[7]_0 input.left pin seg7_o_reg[8]_0 input.left pin seg7_o_reg[9]_0 input.left pinBus A input.left [2:0] pinBus E input.left [1:0] pinBus JA_IBUF input.left [0:0] pinBus Q output.right [15:0] pinBus alu_result input.left [9:0] pinBus mem_reg_0_255_31_31_0 output.right [29:0] pinBus p_1_in__0 output.right [1:0] pinBus pmod_col_o_reg[3]_0 output.right [3:0] pinBus pmod_col_o_reg[3]_2 input.left [0:0] pinBus register_file_reg_r1_0_31_0_5_i_190_0 input.left [3:0] pinBus register_file_reg_r1_0_31_0_5_i_30_0 input.left [2:0] pinBus register_file_reg_r1_0_31_0_5_i_32_0 input.left [1:0] pinBus register_file_reg_r1_0_31_12_17_i_42_0 input.left [1:0] pinBus seg7_o_reg[15]_0 output.right [15:0] pinBus seg7_o_reg[8]_1 input.left [1:0] pinBus switch_IBUF input.left [4:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol decoder work:decoder:NOFILE HIERBOX pin clk_IBUF_BUFG input.left pin mem_reg_0_255_0_0_i_74 input.left pin p_0_in input.left pin pc_next_carry__0_i_4 output.right pin pc_next_carry_i_3 output.right pin pc_next_carry_i_3_n_0_repN_1_alias input.left pin pc_next_carry_i_3_n_0_repN_8_alias input.left pin pc_next_carry_i_3_n_0_repN_alias input.left pin register_file_reg_r1_0_31_0_5_i_54 input.left pin register_file_reg_r1_0_31_0_5_i_54_0 input.left pinBus instruction input.left [14:0] pinBus rs1_o0 output.right [31:0] pinBus rs2_data output.right [26:0] pinBus rs2_o0 output.right [31:0] pinBus write_back_data input.left [31:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol execution work:execution:NOFILE HIERBOX pin alu_a_select input.left pin is_sub input.left pin pc_reg[31]_i_22 input.left pin pc_reg[31]_i_41 output.right pin pc_reg_reg[31] output.right pin register_file_reg_r1_0_31_24_29_i_64 input.left pinBus CO input.left [0:0] pinBus O output.right [3:0] pinBus S input.left [3:0] pinBus alu_a input.left [3:0] pinBus alu_b__226 input.left [3:0] pinBus alu_control input.left [0:0] pinBus immediate input.left [30:0] pinBus pc input.left [2:0] pinBus pc_branch output.right [30:0] pinBus pc_next_carry__0_i_2 input.left [3:0] pinBus pc_reg_reg[11] input.left [3:0] pinBus pc_reg_reg[15] input.left [3:0] pinBus pc_reg_reg[19] input.left [3:0] pinBus pc_reg_reg[23] input.left [3:0] pinBus pc_reg_reg[27] input.left [3:0] pinBus pc_reg_reg[31]_0 input.left [3:0] pinBus rs1_o0 input.left [2:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol search work:search:NOFILE HIERBOX pin CPU_RESETN output.right pin CPU_RESETN_IBUF input.left pin O_alias input.left pin O_alias_1 input.left pin alu_a_select output.right pin alu_result__0[1]_alias output.right pin branch_address0_carry__2_i_10_0 input.left pin clk_IBUF_BUFG input.left pin is_sub output.right pin led_o[15]_i_6_0 output.right pin led_o[15]_i_6_1 output.right pin led_o[15]_i_6_10 output.right pin led_o[15]_i_6_11 output.right pin led_o[15]_i_6_12 output.right pin led_o[15]_i_6_13 output.right pin led_o[15]_i_6_14 output.right pin led_o[15]_i_6_15 output.right pin led_o[15]_i_6_2 output.right pin led_o[15]_i_6_3 output.right pin led_o[15]_i_6_4 output.right pin led_o[15]_i_6_5 output.right pin led_o[15]_i_6_6 output.right pin led_o[15]_i_6_7 output.right pin led_o[15]_i_6_8 output.right pin led_o[15]_i_6_9 output.right pin mem_reg_0_255_0_0_i_11_0 output.right pin mem_reg_0_255_0_0_i_11_1 output.right pin mem_reg_0_255_0_0_i_6_0 output.right pin mem_reg_0_255_24_24_i_3_0 output.right pin mem_reg_0_255_24_24_i_3_1 output.right pin mem_reg_0_255_31_31_0[21]_repN_1_alias input.left pin mem_reg_0_255_31_31_0[21]_repN_2_alias input.left pin mem_reg_0_255_31_31_0[21]_repN_alias input.left pin p_0_in output.right pin pc_next_carry__0_i_1 output.right pin pc_next_carry__0_i_2_n_0_repN_1_alias input.left pin pc_next_carry__0_i_2_n_0_repN_2_alias input.left pin pc_next_carry__0_i_2_n_0_repN_3_alias input.left pin pc_next_carry__0_i_2_n_0_repN_4_alias input.left pin pc_next_carry__0_i_2_n_0_repN_5_alias input.left pin pc_next_carry__0_i_2_n_0_repN_6_alias input.left pin pc_next_carry__0_i_2_n_0_repN_7_alias input.left pin pc_next_carry__0_i_2_n_0_repN_8_alias input.left pin pc_next_carry__0_i_2_n_0_repN_alias input.left pin pc_next_carry__0_i_3_n_0_repN_1_alias input.left pin pc_next_carry__0_i_3_n_0_repN_2_alias input.left pin pc_next_carry__0_i_3_n_0_repN_3_alias input.left pin pc_next_carry__0_i_3_n_0_repN_4_alias input.left pin pc_next_carry__0_i_3_n_0_repN_5_alias input.left pin pc_next_carry__0_i_3_n_0_repN_6_alias input.left pin pc_next_carry__0_i_3_n_0_repN_7_alias input.left pin pc_next_carry__0_i_3_n_0_repN_alias input.left pin pc_next_carry__1_i_1_2 output.right pin pc_next_carry_i_2 input.left pin pc_next_carry_i_2_n_0_repN_1_alias input.left pin pc_next_carry_i_2_n_0_repN_2_alias input.left pin pc_next_carry_i_2_n_0_repN_3_alias input.left pin pc_next_carry_i_2_n_0_repN_4_alias input.left pin pc_next_carry_i_2_n_0_repN_5_alias input.left pin pc_next_carry_i_2_n_0_repN_6_alias input.left pin pc_next_carry_i_2_n_0_repN_7_alias input.left pin pc_next_carry_i_2_n_0_repN_alias input.left pin pc_next_carry_i_3_n_0_repN_10_alias input.left pin pc_next_carry_i_3_n_0_repN_11_alias input.left pin pc_next_carry_i_3_n_0_repN_12_alias input.left pin pc_next_carry_i_3_n_0_repN_1_alias input.left pin pc_next_carry_i_3_n_0_repN_2_alias input.left pin pc_next_carry_i_3_n_0_repN_3_alias input.left pin pc_next_carry_i_3_n_0_repN_4_alias input.left pin pc_next_carry_i_3_n_0_repN_5_alias input.left pin pc_next_carry_i_3_n_0_repN_6_alias input.left pin pc_next_carry_i_3_n_0_repN_7_alias input.left pin pc_next_carry_i_3_n_0_repN_8_alias input.left pin pc_next_carry_i_3_n_0_repN_9_alias input.left pin pc_next_carry_i_3_n_0_repN_alias input.left pin pc_reg[31]_i_14_0 input.left pin pc_reg[31]_i_6_0 input.left pin register_file_reg_r1_0_31_0_5_i_13_0 input.left pin register_file_reg_r1_0_31_0_5_i_25_0 input.left pin register_file_reg_r1_0_31_0_5_i_31_0 input.left pin register_file_reg_r1_0_31_0_5_i_33_0 input.left pin register_file_reg_r1_0_31_0_5_i_83_0 output.right pin register_file_reg_r1_0_31_0_5_i_83_1 output.right pin register_file_reg_r1_0_31_12_17_i_14_0 output.right pin register_file_reg_r1_0_31_12_17_i_14_1 output.right pin register_file_reg_r1_0_31_12_17_i_14_2 output.right pin register_file_reg_r1_0_31_12_17_i_14_3 output.right pin register_file_reg_r1_0_31_12_17_i_14_4 output.right pin register_file_reg_r1_0_31_12_17_i_14_5 output.right pin register_file_reg_r1_0_31_12_17_i_14_6 output.right pin register_file_reg_r1_0_31_12_17_i_14_7 output.right pin register_file_reg_r1_0_31_24_29_i_43_0 output.right pin register_file_reg_r1_0_31_6_11_i_21_0 output.right pin register_file_reg_r1_0_31_6_11_i_21_1 output.right pin register_file_reg_r1_0_31_6_11_i_21_2 output.right pin register_file_reg_r1_0_31_6_11_i_24_0 output.right pin register_file_reg_r1_0_31_6_11_i_24_1 output.right pin register_file_reg_r1_0_31_6_11_i_24_2 output.right pin register_file_reg_r1_0_31_6_11_i_24_3 output.right pin register_file_reg_r1_0_31_6_11_i_24_4 output.right pin register_file_reg_r1_0_31_6_11_i_24_5 output.right pin register_file_reg_r1_0_31_6_11_i_24_6 output.right pin register_file_reg_r1_0_31_6_11_i_24_7 output.right pin register_file_reg_r1_0_31_6_11_i_24_8 output.right pin register_file_reg_r2_0_31_24_29 output.right pin register_file_reg_r2_0_31_24_29_0 output.right pin register_file_reg_r2_0_31_24_29_1 output.right pin register_file_reg_r2_0_31_24_29_2 output.right pin register_file_reg_r2_0_31_24_29_3 output.right pin register_file_reg_r2_0_31_24_29_4 output.right pin register_file_reg_r2_0_31_30_31 output.right pin register_file_reg_r2_0_31_30_31__0 output.right pinBus A output.right [2:0] pinBus CO output.right [0:0] pinBus E output.right [1:0] pinBus JA_IBUF input.left [2:0] pinBus O input.left [3:0] pinBus Q input.left [10:0] pinBus S input.left [1:0] pinBus alu_result output.right [9:0] pinBus immediate output.right [30:0] pinBus led_o[15]_i_5_0 output.right [1:0] pinBus led_o[7]_i_3_0 output.right [0:0] pinBus mem_reg_0_255_0_0_i_16_0 output.right [1:0] pinBus mem_reg_0_255_0_0_i_16_1 output.right [2:0] pinBus mem_reg_0_255_0_0_i_16_2 output.right [3:0] pinBus mem_reg_0_255_0_0_i_16_3 output.right [1:0] pinBus pc_branch input.left [30:0] pinBus pc_next_carry__0_i_1_0 input.left [3:0] pinBus pc_next_carry__0_i_2 output.right [3:0] pinBus pc_next_carry__1_i_1 output.right [3:0] pinBus pc_next_carry__1_i_1_0 output.right [14:0] pinBus pc_next_carry__1_i_1_1 output.right [0:0] pinBus pc_next_carry__1_i_1_3 output.right [3:0] pinBus pc_reg[31]_i_21 input.left [26:0] pinBus pc_reg_reg[11]_0 output.right [3:0] pinBus pc_reg_reg[12]_0 output.right [8:0] pinBus pc_reg_reg[12]_1 input.left [1:0] pinBus pc_reg_reg[15]_0 output.right [3:0] pinBus pc_reg_reg[19]_0 output.right [3:0] pinBus pc_reg_reg[23]_0 output.right [3:0] pinBus pc_reg_reg[27]_0 output.right [3:0] pinBus pc_reg_reg[30]_0 output.right [2:0] pinBus pc_reg_reg[31]_0 output.right [3:0] pinBus pc_reg_reg[31]_1 output.right [3:0] pinBus register_file_reg_r1_0_31_0_5_i_7_0 input.left [1:0] pinBus register_file_reg_r1_0_31_12_17_i_13_0 input.left [10:0] pinBus register_file_reg_r1_0_31_12_17_i_21_0 input.left [29:0] pinBus rs1_o0 input.left [31:0] pinBus rs2_o0 input.left [31:0] pinBus switch_IBUF input.left [10:0] pinBus write_back_data output.right [31:0] boxcolor 1 fillcolor 2 minwidth 13%
load port BTNC input -pg 1 -lvl 0 -x 0 -y 40
load port BTND input -pg 1 -lvl 0 -x 0 -y 110
load port BTNL input -pg 1 -lvl 0 -x 0 -y 180
load port BTNR input -pg 1 -lvl 0 -x 0 -y 250
load port BTNU input -pg 1 -lvl 0 -x 0 -y 460
load port CPU_RESETN input -pg 1 -lvl 0 -x 0 -y 1300
load port clk input -pg 1 -lvl 0 -x 0 -y 3510
load portBus JA inout [10:1] -attr @name JA[10:1] -pg 1 -lvl 6 -x 7990 -y 640
load portBus a_7_segment output [7:0] -attr @name a_7_segment[7:0] -pg 1 -lvl 6 -x 7990 -y 2290
load portBus c_7_segment output [7:0] -attr @name c_7_segment[7:0] -pg 1 -lvl 6 -x 7990 -y 1730
load portBus led output [15:0] -attr @name led[15:0] -pg 1 -lvl 6 -x 7990 -y 2850
load portBus switch input [15:0] -attr @name switch[15:0] -pg 1 -lvl 0 -x 0 -y 7920
load inst BTNC_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 40
load inst BTND_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 110
load inst BTNL_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 180
load inst BTNR_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 250
load inst BTNU_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 460
load inst CPU_RESETN_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 1300
load inst JA_IBUF[10]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 600
load inst JA_IBUF[7]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 320
load inst JA_IBUF[8]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 390
load inst JA_IBUF[9]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 530
load inst JA_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1080
load inst JA_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1150
load inst JA_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1220
load inst JA_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1290
load inst a_7_segment_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2290
load inst a_7_segment_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2360
load inst a_7_segment_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2430
load inst a_7_segment_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2500
load inst a_7_segment_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2570
load inst a_7_segment_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2640
load inst a_7_segment_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2710
load inst a_7_segment_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2780
load inst c_7_segment_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1730
load inst c_7_segment_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1800
load inst c_7_segment_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1870
load inst c_7_segment_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 1940
load inst c_7_segment_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2010
load inst c_7_segment_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2080
load inst c_7_segment_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2150
load inst c_7_segment_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2220
load inst clk_IBUF_BUFG_inst BUFG hdi_primitives -attr @cell(#000000) BUFG -pg 1 -lvl 2 -x 190 -y 3510
load inst clk_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 1 -x 40 -y 3510
load inst core_inst core work:core:NOFILE -autohide -attr @cell(#000000) core -attr @fillcolor #fafafa -pinBusAttr JA_IBUF @name JA_IBUF[3:0] -pinBusAttr Q @name Q[15:0] -pinBusAttr Q @attr n/c -pinBusAttr pc_reg_reg[12] @name pc_reg_reg[12][8:0] -pinBusAttr pmod_col_o_reg[3] @name pmod_col_o_reg[3][3:0] -pinBusAttr seg7_o_reg[15] @name seg7_o_reg[15][15:0] -pinBusAttr seg7_o_reg[15] @attr n/c -pinBusAttr switch_IBUF @name switch_IBUF[15:0] -pg 1 -lvl 4 -x 1760 -y 2338
load inst led_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2850
load inst led_OBUF[10]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3550
load inst led_OBUF[11]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3620
load inst led_OBUF[12]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3690
load inst led_OBUF[13]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3760
load inst led_OBUF[14]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3830
load inst led_OBUF[15]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3900
load inst led_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2920
load inst led_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 2990
load inst led_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3060
load inst led_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3130
load inst led_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3200
load inst led_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3270
load inst led_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3340
load inst led_OBUF[8]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3410
load inst led_OBUF[9]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 5 -x 7750 -y 3480
load inst pc_next_carry__0_i_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 740
load inst pc_next_carry__0_i_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 890
load inst pc_next_carry__0_i_2_replica FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1040
load inst pc_next_carry__0_i_2_replica_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1190
load inst pc_next_carry__0_i_2_replica_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1420
load inst pc_next_carry__0_i_2_replica_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1570
load inst pc_next_carry__0_i_2_replica_4 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1750
load inst pc_next_carry__0_i_2_replica_5 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 1900
load inst pc_next_carry__0_i_2_replica_6 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2050
load inst pc_next_carry__0_i_2_replica_7 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2200
load inst pc_next_carry__0_i_2_replica_8 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2350
load inst pc_next_carry__0_i_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2500
load inst pc_next_carry__0_i_3_replica FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6010
load inst pc_next_carry__0_i_3_replica_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2650
load inst pc_next_carry__0_i_3_replica_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2800
load inst pc_next_carry__0_i_3_replica_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6160
load inst pc_next_carry__0_i_3_replica_4 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6310
load inst pc_next_carry__0_i_3_replica_5 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6460
load inst pc_next_carry__0_i_3_replica_6 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6610
load inst pc_next_carry__0_i_3_replica_7 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6760
load inst pc_next_carry__0_i_4 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 6910
load inst pc_next_carry__1_i_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 2950
load inst pc_next_carry__1_i_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3100
load inst pc_next_carry_i_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7060
load inst pc_next_carry_i_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7210
load inst pc_next_carry_i_2_replica FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3250
load inst pc_next_carry_i_2_replica_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3400
load inst pc_next_carry_i_2_replica_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3550
load inst pc_next_carry_i_2_replica_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3700
load inst pc_next_carry_i_2_replica_4 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 3850
load inst pc_next_carry_i_2_replica_5 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7360
load inst pc_next_carry_i_2_replica_6 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7510
load inst pc_next_carry_i_2_replica_7 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7660
load inst pc_next_carry_i_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 7810
load inst pc_next_carry_i_3_replica FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4000
load inst pc_next_carry_i_3_replica_1 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4150
load inst pc_next_carry_i_3_replica_10 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5560
load inst pc_next_carry_i_3_replica_11 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5710
load inst pc_next_carry_i_3_replica_12 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5860
load inst pc_next_carry_i_3_replica_2 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4330
load inst pc_next_carry_i_3_replica_3 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4510
load inst pc_next_carry_i_3_replica_4 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4660
load inst pc_next_carry_i_3_replica_5 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4810
load inst pc_next_carry_i_3_replica_6 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 4960
load inst pc_next_carry_i_3_replica_7 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5110
load inst pc_next_carry_i_3_replica_8 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5260
load inst pc_next_carry_i_3_replica_9 FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 5410
load inst switch_IBUF[0]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 7920
load inst switch_IBUF[10]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8620
load inst switch_IBUF[11]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8690
load inst switch_IBUF[12]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8760
load inst switch_IBUF[13]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8830
load inst switch_IBUF[14]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8900
load inst switch_IBUF[15]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8970
load inst switch_IBUF[1]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 7990
load inst switch_IBUF[2]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8060
load inst switch_IBUF[3]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8130
load inst switch_IBUF[4]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8200
load inst switch_IBUF[5]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8270
load inst switch_IBUF[6]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8340
load inst switch_IBUF[7]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8410
load inst switch_IBUF[8]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8480
load inst switch_IBUF[9]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 8550
load inst core_inst|data_memory_inst data_memory work:data_memory:NOFILE -hier core_inst -autohide -attr @cell(#000000) data_memory -attr @name data_memory_inst -pinBusAttr A @name A[2:0] -pinBusAttr E @name E[1:0] -pinBusAttr JA_IBUF @name JA_IBUF -pinBusAttr Q @name Q[15:0] -pinBusAttr alu_result @name alu_result[9:0] -pinBusAttr mem_reg_0_255_31_31_0 @name mem_reg_0_255_31_31_0[29:0] -pinBusAttr p_1_in__0 @name p_1_in__0[1:0] -pinBusAttr pmod_col_o_reg[3]_0 @name pmod_col_o_reg[3]_0[3:0] -pinBusAttr pmod_col_o_reg[3]_2 @name pmod_col_o_reg[3]_2 -pinBusAttr register_file_reg_r1_0_31_0_5_i_190_0 @name register_file_reg_r1_0_31_0_5_i_190_0[3:0] -pinBusAttr register_file_reg_r1_0_31_0_5_i_30_0 @name register_file_reg_r1_0_31_0_5_i_30_0[2:0] -pinBusAttr register_file_reg_r1_0_31_0_5_i_32_0 @name register_file_reg_r1_0_31_0_5_i_32_0[1:0] -pinBusAttr register_file_reg_r1_0_31_12_17_i_42_0 @name register_file_reg_r1_0_31_12_17_i_42_0[1:0] -pinBusAttr seg7_o_reg[15]_0 @name seg7_o_reg[15]_0[15:0] -pinBusAttr seg7_o_reg[8]_1 @name seg7_o_reg[8]_1[1:0] -pinBusAttr switch_IBUF @name switch_IBUF[4:0] -pg 1 -lvl 4 -x 6230 -y 2758
load inst core_inst|decoder_inst decoder work:decoder:NOFILE -hier core_inst -autohide -attr @cell(#000000) decoder -attr @name decoder_inst -pinBusAttr instruction @name instruction[14:0] -pinBusAttr rs1_o0 @name rs1_o0[31:0] -pinBusAttr rs2_data @name rs2_data[26:0] -pinBusAttr rs2_o0 @name rs2_o0[31:0] -pinBusAttr write_back_data @name write_back_data[31:0] -pg 1 -lvl 1 -x 2150 -y 4038
load inst core_inst|execution_inst execution work:execution:NOFILE -hier core_inst -autohide -attr @cell(#000000) execution -attr @name execution_inst -pinBusAttr CO @name CO -pinBusAttr O @name O[3:0] -pinBusAttr S @name S[3:0] -pinBusAttr alu_a @name alu_a[3:0] -pinBusAttr alu_b__226 @name alu_b__226[3:0] -pinBusAttr alu_control @name alu_control -pinBusAttr immediate @name immediate[30:0] -pinBusAttr pc @name pc[2:0] -pinBusAttr pc_branch @name pc_branch[30:0] -pinBusAttr pc_next_carry__0_i_2 @name pc_next_carry__0_i_2[3:0] -pinBusAttr pc_reg_reg[11] @name pc_reg_reg[11][3:0] -pinBusAttr pc_reg_reg[15] @name pc_reg_reg[15][3:0] -pinBusAttr pc_reg_reg[19] @name pc_reg_reg[19][3:0] -pinBusAttr pc_reg_reg[23] @name pc_reg_reg[23][3:0] -pinBusAttr pc_reg_reg[27] @name pc_reg_reg[27][3:0] -pinBusAttr pc_reg_reg[31]_0 @name pc_reg_reg[31]_0[3:0] -pinBusAttr rs1_o0 @name rs1_o0[2:0] -pg 1 -lvl 2 -x 2830 -y 3718
load inst core_inst|search_inst search work:search:NOFILE -hier core_inst -autohide -attr @cell(#000000) search -attr @name search_inst -pinBusAttr A @name A[2:0] -pinBusAttr CO @name CO -pinBusAttr E @name E[1:0] -pinBusAttr JA_IBUF @name JA_IBUF[2:0] -pinBusAttr O @name O[3:0] -pinBusAttr Q @name Q[10:0] -pinBusAttr S @name S[1:0] -pinBusAttr alu_result @name alu_result[9:0] -pinBusAttr immediate @name immediate[30:0] -pinBusAttr led_o[15]_i_5_0 @name led_o[15]_i_5_0[1:0] -pinBusAttr led_o[7]_i_3_0 @name led_o[7]_i_3_0 -pinBusAttr mem_reg_0_255_0_0_i_16_0 @name mem_reg_0_255_0_0_i_16_0[1:0] -pinBusAttr mem_reg_0_255_0_0_i_16_1 @name mem_reg_0_255_0_0_i_16_1[2:0] -pinBusAttr mem_reg_0_255_0_0_i_16_2 @name mem_reg_0_255_0_0_i_16_2[3:0] -pinBusAttr mem_reg_0_255_0_0_i_16_3 @name mem_reg_0_255_0_0_i_16_3[1:0] -pinBusAttr pc_branch @name pc_branch[30:0] -pinBusAttr pc_next_carry__0_i_1_0 @name pc_next_carry__0_i_1_0[3:0] -pinBusAttr pc_next_carry__0_i_2 @name pc_next_carry__0_i_2[3:0] -pinBusAttr pc_next_carry__1_i_1 @name pc_next_carry__1_i_1[3:0] -pinBusAttr pc_next_carry__1_i_1_0 @name pc_next_carry__1_i_1_0[14:0] -pinBusAttr pc_next_carry__1_i_1_1 @name pc_next_carry__1_i_1_1 -pinBusAttr pc_next_carry__1_i_1_3 @name pc_next_carry__1_i_1_3[3:0] -pinBusAttr pc_reg[31]_i_21 @name pc_reg[31]_i_21[26:0] -pinBusAttr pc_reg_reg[11]_0 @name pc_reg_reg[11]_0[3:0] -pinBusAttr pc_reg_reg[12]_0 @name pc_reg_reg[12]_0[8:0] -pinBusAttr pc_reg_reg[12]_1 @name pc_reg_reg[12]_1[1:0] -pinBusAttr pc_reg_reg[15]_0 @name pc_reg_reg[15]_0[3:0] -pinBusAttr pc_reg_reg[19]_0 @name pc_reg_reg[19]_0[3:0] -pinBusAttr pc_reg_reg[23]_0 @name pc_reg_reg[23]_0[3:0] -pinBusAttr pc_reg_reg[27]_0 @name pc_reg_reg[27]_0[3:0] -pinBusAttr pc_reg_reg[30]_0 @name pc_reg_reg[30]_0[2:0] -pinBusAttr pc_reg_reg[31]_0 @name pc_reg_reg[31]_0[3:0] -pinBusAttr pc_reg_reg[31]_1 @name pc_reg_reg[31]_1[3:0] -pinBusAttr register_file_reg_r1_0_31_0_5_i_7_0 @name register_file_reg_r1_0_31_0_5_i_7_0[1:0] -pinBusAttr register_file_reg_r1_0_31_12_17_i_13_0 @name register_file_reg_r1_0_31_12_17_i_13_0[10:0] -pinBusAttr register_file_reg_r1_0_31_12_17_i_21_0 @name register_file_reg_r1_0_31_12_17_i_21_0[29:0] -pinBusAttr rs1_o0 @name rs1_o0[31:0] -pinBusAttr rs2_o0 @name rs2_o0[31:0] -pinBusAttr switch_IBUF @name switch_IBUF[10:0] -pinBusAttr write_back_data @name write_back_data[31:0] -pg 1 -lvl 3 -x 4230 -y 2818
load net <const1> -power -pin pc_next_carry__0_i_1 CE -pin pc_next_carry__0_i_2 CE -pin pc_next_carry__0_i_2_replica CE -pin pc_next_carry__0_i_2_replica_1 CE -pin pc_next_carry__0_i_2_replica_2 CE -pin pc_next_carry__0_i_2_replica_3 CE -pin pc_next_carry__0_i_2_replica_4 CE -pin pc_next_carry__0_i_2_replica_5 CE -pin pc_next_carry__0_i_2_replica_6 CE -pin pc_next_carry__0_i_2_replica_7 CE -pin pc_next_carry__0_i_2_replica_8 CE -pin pc_next_carry__0_i_3 CE -pin pc_next_carry__0_i_3_replica CE -pin pc_next_carry__0_i_3_replica_1 CE -pin pc_next_carry__0_i_3_replica_2 CE -pin pc_next_carry__0_i_3_replica_3 CE -pin pc_next_carry__0_i_3_replica_4 CE -pin pc_next_carry__0_i_3_replica_5 CE -pin pc_next_carry__0_i_3_replica_6 CE -pin pc_next_carry__0_i_3_replica_7 CE -pin pc_next_carry__0_i_4 CE -pin pc_next_carry__1_i_1 CE -pin pc_next_carry__1_i_2 CE -pin pc_next_carry_i_1 CE -pin pc_next_carry_i_2 CE -pin pc_next_carry_i_2_replica CE -pin pc_next_carry_i_2_replica_1 CE -pin pc_next_carry_i_2_replica_2 CE -pin pc_next_carry_i_2_replica_3 CE -pin pc_next_carry_i_2_replica_4 CE -pin pc_next_carry_i_2_replica_5 CE -pin pc_next_carry_i_2_replica_6 CE -pin pc_next_carry_i_2_replica_7 CE -pin pc_next_carry_i_3 CE -pin pc_next_carry_i_3_replica CE -pin pc_next_carry_i_3_replica_1 CE -pin pc_next_carry_i_3_replica_10 CE -pin pc_next_carry_i_3_replica_11 CE -pin pc_next_carry_i_3_replica_12 CE -pin pc_next_carry_i_3_replica_2 CE -pin pc_next_carry_i_3_replica_3 CE -pin pc_next_carry_i_3_replica_4 CE -pin pc_next_carry_i_3_replica_5 CE -pin pc_next_carry_i_3_replica_6 CE -pin pc_next_carry_i_3_replica_7 CE -pin pc_next_carry_i_3_replica_8 CE -pin pc_next_carry_i_3_replica_9 CE
load net BTNC -port BTNC -pin BTNC_IBUF_inst I
netloc BTNC 1 0 3 NJ 40 NJ 40 NJ
load net BTNC_IBUF -pin BTNC_IBUF_inst O -pin core_inst BTNC_IBUF
netloc BTNC_IBUF 1 3 1 1500J 40n
load net BTND -port BTND -pin BTND_IBUF_inst I
netloc BTND 1 0 3 NJ 110 NJ 110 NJ
load net BTND_IBUF -pin BTND_IBUF_inst O -pin core_inst BTND_IBUF
netloc BTND_IBUF 1 3 1 1480J 110n
load net BTNL -port BTNL -pin BTNL_IBUF_inst I
netloc BTNL 1 0 3 NJ 180 NJ 180 NJ
load net BTNL_IBUF -pin BTNL_IBUF_inst O -pin core_inst BTNL_IBUF
netloc BTNL_IBUF 1 3 1 1460J 180n
load net BTNR -port BTNR -pin BTNR_IBUF_inst I
netloc BTNR 1 0 3 NJ 250 NJ 250 NJ
load net BTNR_IBUF -pin BTNR_IBUF_inst O -pin core_inst BTNR_IBUF
netloc BTNR_IBUF 1 3 1 1440J 250n
load net BTNU -port BTNU -pin BTNU_IBUF_inst I
netloc BTNU 1 0 3 NJ 460 NJ 460 NJ
load net BTNU_IBUF -pin BTNU_IBUF_inst O -pin core_inst BTNU_IBUF
netloc BTNU_IBUF 1 3 1 1420J 460n
load net CPU_RESETN -port CPU_RESETN -pin CPU_RESETN_IBUF_inst I
netloc CPU_RESETN 1 0 3 NJ 1300 NJ 1300 NJ
load net CPU_RESETN_IBUF -pin CPU_RESETN_IBUF_inst O -pin core_inst CPU_RESETN_IBUF
netloc CPU_RESETN_IBUF 1 3 1 1360J 1300n
load net JA[10] -attr @rip(#000000) JA[10] -port JA[10] -pin JA_IBUF[10]_inst I
load net JA[1] -attr @rip(#000000) JA[1] -port JA[1] -pin JA_OBUF[1]_inst O
load net JA[2] -attr @rip(#000000) JA[2] -port JA[2] -pin JA_OBUF[2]_inst O
load net JA[3] -attr @rip(#000000) JA[3] -port JA[3] -pin JA_OBUF[3]_inst O
load net JA[4] -attr @rip(#000000) JA[4] -port JA[4] -pin JA_OBUF[4]_inst O
load net JA[7] -attr @rip(#000000) JA[7] -port JA[7] -pin JA_IBUF[7]_inst I
load net JA[8] -attr @rip(#000000) JA[8] -port JA[8] -pin JA_IBUF[8]_inst I
load net JA[9] -attr @rip(#000000) JA[9] -port JA[9] -pin JA_IBUF[9]_inst I
load net JA_IBUF[10] -attr @rip(#000000) 3 -pin JA_IBUF[10]_inst O -pin core_inst JA_IBUF[3]
load net JA_IBUF[7] -attr @rip(#000000) 0 -pin JA_IBUF[7]_inst O -pin core_inst JA_IBUF[0]
load net JA_IBUF[8] -attr @rip(#000000) 1 -pin JA_IBUF[8]_inst O -pin core_inst JA_IBUF[1]
load net JA_IBUF[9] -attr @rip(#000000) 2 -pin JA_IBUF[9]_inst O -pin core_inst JA_IBUF[2]
load net JA_IBUF__0[1] -attr @rip(#000000) pmod_col_o_reg[3][0] -pin JA_OBUF[1]_inst I -pin core_inst pmod_col_o_reg[3][0]
load net JA_IBUF__0[2] -attr @rip(#000000) pmod_col_o_reg[3][1] -pin JA_OBUF[2]_inst I -pin core_inst pmod_col_o_reg[3][1]
load net JA_IBUF__0[3] -attr @rip(#000000) pmod_col_o_reg[3][2] -pin JA_OBUF[3]_inst I -pin core_inst pmod_col_o_reg[3][2]
load net JA_IBUF__0[4] -attr @rip(#000000) pmod_col_o_reg[3][3] -pin JA_OBUF[4]_inst I -pin core_inst pmod_col_o_reg[3][3]
load net a_7_segment[0] -attr @rip(#000000) 0 -port a_7_segment[0] -pin a_7_segment_OBUF[0]_inst O
load net a_7_segment[1] -attr @rip(#000000) 1 -port a_7_segment[1] -pin a_7_segment_OBUF[1]_inst O
load net a_7_segment[2] -attr @rip(#000000) 2 -port a_7_segment[2] -pin a_7_segment_OBUF[2]_inst O
load net a_7_segment[3] -attr @rip(#000000) 3 -port a_7_segment[3] -pin a_7_segment_OBUF[3]_inst O
load net a_7_segment[4] -attr @rip(#000000) 4 -port a_7_segment[4] -pin a_7_segment_OBUF[4]_inst O
load net a_7_segment[5] -attr @rip(#000000) 5 -port a_7_segment[5] -pin a_7_segment_OBUF[5]_inst O
load net a_7_segment[6] -attr @rip(#000000) 6 -port a_7_segment[6] -pin a_7_segment_OBUF[6]_inst O
load net a_7_segment[7] -attr @rip(#000000) 7 -port a_7_segment[7] -pin a_7_segment_OBUF[7]_inst O
load net a_7_segment_OBUF[0]
load net a_7_segment_OBUF[1]
load net a_7_segment_OBUF[2]
load net a_7_segment_OBUF[3]
load net a_7_segment_OBUF[4]
load net a_7_segment_OBUF[5]
load net a_7_segment_OBUF[6]
load net a_7_segment_OBUF[7]
load net c_7_segment[0] -attr @rip(#000000) 0 -port c_7_segment[0] -pin c_7_segment_OBUF[0]_inst O
load net c_7_segment[1] -attr @rip(#000000) 1 -port c_7_segment[1] -pin c_7_segment_OBUF[1]_inst O
load net c_7_segment[2] -attr @rip(#000000) 2 -port c_7_segment[2] -pin c_7_segment_OBUF[2]_inst O
load net c_7_segment[3] -attr @rip(#000000) 3 -port c_7_segment[3] -pin c_7_segment_OBUF[3]_inst O
load net c_7_segment[4] -attr @rip(#000000) 4 -port c_7_segment[4] -pin c_7_segment_OBUF[4]_inst O
load net c_7_segment[5] -attr @rip(#000000) 5 -port c_7_segment[5] -pin c_7_segment_OBUF[5]_inst O
load net c_7_segment[6] -attr @rip(#000000) 6 -port c_7_segment[6] -pin c_7_segment_OBUF[6]_inst O
load net c_7_segment[7] -attr @rip(#000000) 7 -port c_7_segment[7] -pin c_7_segment_OBUF[7]_inst O
load net c_7_segment_OBUF[0]
load net c_7_segment_OBUF[1]
load net c_7_segment_OBUF[2]
load net c_7_segment_OBUF[3]
load net c_7_segment_OBUF[4]
load net c_7_segment_OBUF[5]
load net c_7_segment_OBUF[6]
load net c_7_segment_OBUF[7]
load net clk -port clk -pin clk_IBUF_inst I
netloc clk 1 0 1 NJ 3510
load net clk_IBUF -pin clk_IBUF_BUFG_inst I -pin clk_IBUF_inst O
netloc clk_IBUF 1 1 1 NJ 3510
load net clk_IBUF_BUFG -pin clk_IBUF_BUFG_inst O -pin core_inst clk_IBUF_BUFG -pin pc_next_carry__0_i_1 C -pin pc_next_carry__0_i_2 C -pin pc_next_carry__0_i_2_replica C -pin pc_next_carry__0_i_2_replica_1 C -pin pc_next_carry__0_i_2_replica_2 C -pin pc_next_carry__0_i_2_replica_3 C -pin pc_next_carry__0_i_2_replica_4 C -pin pc_next_carry__0_i_2_replica_5 C -pin pc_next_carry__0_i_2_replica_6 C -pin pc_next_carry__0_i_2_replica_7 C -pin pc_next_carry__0_i_2_replica_8 C -pin pc_next_carry__0_i_3 C -pin pc_next_carry__0_i_3_replica C -pin pc_next_carry__0_i_3_replica_1 C -pin pc_next_carry__0_i_3_replica_2 C -pin pc_next_carry__0_i_3_replica_3 C -pin pc_next_carry__0_i_3_replica_4 C -pin pc_next_carry__0_i_3_replica_5 C -pin pc_next_carry__0_i_3_replica_6 C -pin pc_next_carry__0_i_3_replica_7 C -pin pc_next_carry__0_i_4 C -pin pc_next_carry__1_i_1 C -pin pc_next_carry__1_i_2 C -pin pc_next_carry_i_1 C -pin pc_next_carry_i_2 C -pin pc_next_carry_i_2_replica C -pin pc_next_carry_i_2_replica_1 C -pin pc_next_carry_i_2_replica_2 C -pin pc_next_carry_i_2_replica_3 C -pin pc_next_carry_i_2_replica_4 C -pin pc_next_carry_i_2_replica_5 C -pin pc_next_carry_i_2_replica_6 C -pin pc_next_carry_i_2_replica_7 C -pin pc_next_carry_i_3 C -pin pc_next_carry_i_3_replica C -pin pc_next_carry_i_3_replica_1 C -pin pc_next_carry_i_3_replica_10 C -pin pc_next_carry_i_3_replica_11 C -pin pc_next_carry_i_3_replica_12 C -pin pc_next_carry_i_3_replica_2 C -pin pc_next_carry_i_3_replica_3 C -pin pc_next_carry_i_3_replica_4 C -pin pc_next_carry_i_3_replica_5 C -pin pc_next_carry_i_3_replica_6 C -pin pc_next_carry_i_3_replica_7 C -pin pc_next_carry_i_3_replica_8 C -pin pc_next_carry_i_3_replica_9 C
netloc clk_IBUF_BUFG 1 2 2 370 1650 1300
load net led[0] -attr @rip(#000000) 0 -port led[0] -pin led_OBUF[0]_inst O
load net led[10] -attr @rip(#000000) 10 -port led[10] -pin led_OBUF[10]_inst O
load net led[11] -attr @rip(#000000) 11 -port led[11] -pin led_OBUF[11]_inst O
load net led[12] -attr @rip(#000000) 12 -port led[12] -pin led_OBUF[12]_inst O
load net led[13] -attr @rip(#000000) 13 -port led[13] -pin led_OBUF[13]_inst O
load net led[14] -attr @rip(#000000) 14 -port led[14] -pin led_OBUF[14]_inst O
load net led[15] -attr @rip(#000000) 15 -port led[15] -pin led_OBUF[15]_inst O
load net led[1] -attr @rip(#000000) 1 -port led[1] -pin led_OBUF[1]_inst O
load net led[2] -attr @rip(#000000) 2 -port led[2] -pin led_OBUF[2]_inst O
load net led[3] -attr @rip(#000000) 3 -port led[3] -pin led_OBUF[3]_inst O
load net led[4] -attr @rip(#000000) 4 -port led[4] -pin led_OBUF[4]_inst O
load net led[5] -attr @rip(#000000) 5 -port led[5] -pin led_OBUF[5]_inst O
load net led[6] -attr @rip(#000000) 6 -port led[6] -pin led_OBUF[6]_inst O
load net led[7] -attr @rip(#000000) 7 -port led[7] -pin led_OBUF[7]_inst O
load net led[8] -attr @rip(#000000) 8 -port led[8] -pin led_OBUF[8]_inst O
load net led[9] -attr @rip(#000000) 9 -port led[9] -pin led_OBUF[9]_inst O
load net led_OBUF[0]
load net led_OBUF[10]
load net led_OBUF[11]
load net led_OBUF[12]
load net led_OBUF[13]
load net led_OBUF[14]
load net led_OBUF[15]
load net led_OBUF[1]
load net led_OBUF[2]
load net led_OBUF[3]
load net led_OBUF[4]
load net led_OBUF[5]
load net led_OBUF[6]
load net led_OBUF[7]
load net led_OBUF[8]
load net led_OBUF[9]
load net lopt -pin a_7_segment_OBUF[0]_inst I -pin core_inst lopt
netloc lopt 1 4 1 7170 2290n
load net lopt_1 -pin a_7_segment_OBUF[1]_inst I -pin core_inst lopt_1
netloc lopt_1 1 4 1 7210 2360n
load net lopt_10 -pin c_7_segment_OBUF[2]_inst I -pin core_inst lopt_10
netloc lopt_10 1 4 1 7230 1870n
load net lopt_11 -pin c_7_segment_OBUF[3]_inst I -pin core_inst lopt_11
netloc lopt_11 1 4 1 7270 1940n
load net lopt_12 -pin c_7_segment_OBUF[4]_inst I -pin core_inst lopt_12
netloc lopt_12 1 4 1 7310 2010n
load net lopt_13 -pin c_7_segment_OBUF[5]_inst I -pin core_inst lopt_13
netloc lopt_13 1 4 1 7350 2080n
load net lopt_14 -pin c_7_segment_OBUF[6]_inst I -pin core_inst lopt_14
netloc lopt_14 1 4 1 7390 2150n
load net lopt_15 -pin c_7_segment_OBUF[7]_inst I -pin core_inst lopt_15
netloc lopt_15 1 4 1 7430 2220n
load net lopt_16 -pin core_inst lopt_16 -pin led_OBUF[0]_inst I
netloc lopt_16 1 4 1 7630 2850n
load net lopt_17 -pin core_inst lopt_17 -pin led_OBUF[10]_inst I
netloc lopt_17 1 4 1 7630 3408n
load net lopt_18 -pin core_inst lopt_18 -pin led_OBUF[11]_inst I
netloc lopt_18 1 4 1 7590 3428n
load net lopt_19 -pin core_inst lopt_19 -pin led_OBUF[12]_inst I
netloc lopt_19 1 4 1 7550 3448n
load net lopt_2 -pin a_7_segment_OBUF[2]_inst I -pin core_inst lopt_2
netloc lopt_2 1 4 1 7250 2430n
load net lopt_20 -pin core_inst lopt_20 -pin led_OBUF[13]_inst I
netloc lopt_20 1 4 1 7430 3468n
load net lopt_21 -pin core_inst lopt_21 -pin led_OBUF[14]_inst I
netloc lopt_21 1 4 1 7250 3488n
load net lopt_22 -pin core_inst lopt_22 -pin led_OBUF[15]_inst I
netloc lopt_22 1 4 1 7150 3508n
load net lopt_23 -pin core_inst lopt_23 -pin led_OBUF[1]_inst I
netloc lopt_23 1 4 1 7650 2920n
load net lopt_24 -pin core_inst lopt_24 -pin led_OBUF[2]_inst I
netloc lopt_24 1 4 1 7530 2990n
load net lopt_25 -pin core_inst lopt_25 -pin led_OBUF[3]_inst I
netloc lopt_25 1 4 1 7610 3060n
load net lopt_26 -pin core_inst lopt_26 -pin led_OBUF[4]_inst I
netloc lopt_26 1 4 1 7670 3130n
load net lopt_27 -pin core_inst lopt_27 -pin led_OBUF[5]_inst I
netloc lopt_27 1 4 1 7510 3200n
load net lopt_28 -pin core_inst lopt_28 -pin led_OBUF[6]_inst I
netloc lopt_28 1 4 1 7570 3270n
load net lopt_29 -pin core_inst lopt_29 -pin led_OBUF[7]_inst I
netloc lopt_29 1 4 1 7690 3340n
load net lopt_3 -pin a_7_segment_OBUF[3]_inst I -pin core_inst lopt_3
netloc lopt_3 1 4 1 7290 2500n
load net lopt_30 -pin core_inst lopt_30 -pin led_OBUF[8]_inst I
netloc lopt_30 1 4 1 7710 3410n
load net lopt_31 -pin core_inst lopt_31 -pin led_OBUF[9]_inst I
netloc lopt_31 1 4 1 7490 3480n
load net lopt_4 -pin a_7_segment_OBUF[4]_inst I -pin core_inst lopt_4
netloc lopt_4 1 4 1 7330 2570n
load net lopt_5 -pin a_7_segment_OBUF[5]_inst I -pin core_inst lopt_5
netloc lopt_5 1 4 1 7370 2640n
load net lopt_6 -pin a_7_segment_OBUF[6]_inst I -pin core_inst lopt_6
netloc lopt_6 1 4 1 7410 2710n
load net lopt_7 -pin a_7_segment_OBUF[7]_inst I -pin core_inst lopt_7
netloc lopt_7 1 4 1 7450 2780n
load net lopt_8 -pin c_7_segment_OBUF[0]_inst I -pin core_inst lopt_8
netloc lopt_8 1 4 1 7150 1730n
load net lopt_9 -pin c_7_segment_OBUF[1]_inst I -pin core_inst lopt_9
netloc lopt_9 1 4 1 7190 1800n
load net pc_next_carry__0_i_1_n_0 -pin core_inst pc_next_carry__0_i_1_0 -pin pc_next_carry__0_i_1 Q
netloc pc_next_carry__0_i_1_n_0 1 3 1 1380 740n
load net pc_next_carry__0_i_2_n_0 -pin core_inst pc_next_carry__0_i_1_1 -pin pc_next_carry__0_i_2 Q
netloc pc_next_carry__0_i_2_n_0 1 3 1 1340 890n
load net pc_next_carry__0_i_2_n_0_repN -pin core_inst pc_next_carry__0_i_2_n_0_repN_alias -pin pc_next_carry__0_i_2_replica Q
netloc pc_next_carry__0_i_2_n_0_repN 1 3 1 1320 1040n
load net pc_next_carry__0_i_2_n_0_repN_1 -pin core_inst pc_next_carry__0_i_2_n_0_repN_1_alias -pin pc_next_carry__0_i_2_replica_1 Q
netloc pc_next_carry__0_i_2_n_0_repN_1 1 3 1 1280 1190n
load net pc_next_carry__0_i_2_n_0_repN_2 -pin core_inst pc_next_carry__0_i_2_n_0_repN_2_alias -pin pc_next_carry__0_i_2_replica_2 Q
netloc pc_next_carry__0_i_2_n_0_repN_2 1 3 1 1260 1420n
load net pc_next_carry__0_i_2_n_0_repN_3 -pin core_inst pc_next_carry__0_i_2_n_0_repN_3_alias -pin pc_next_carry__0_i_2_replica_3 Q
netloc pc_next_carry__0_i_2_n_0_repN_3 1 3 1 1240 1570n
load net pc_next_carry__0_i_2_n_0_repN_4 -pin core_inst pc_next_carry__0_i_2_n_0_repN_4_alias -pin pc_next_carry__0_i_2_replica_4 Q
netloc pc_next_carry__0_i_2_n_0_repN_4 1 3 1 1220 1750n
load net pc_next_carry__0_i_2_n_0_repN_5 -pin core_inst pc_next_carry__0_i_2_n_0_repN_5_alias -pin pc_next_carry__0_i_2_replica_5 Q
netloc pc_next_carry__0_i_2_n_0_repN_5 1 3 1 1180 1900n
load net pc_next_carry__0_i_2_n_0_repN_6 -pin core_inst pc_next_carry__0_i_2_n_0_repN_6_alias -pin pc_next_carry__0_i_2_replica_6 Q
netloc pc_next_carry__0_i_2_n_0_repN_6 1 3 1 1160 2050n
load net pc_next_carry__0_i_2_n_0_repN_7 -pin core_inst pc_next_carry__0_i_2_n_0_repN_7_alias -pin pc_next_carry__0_i_2_replica_7 Q
netloc pc_next_carry__0_i_2_n_0_repN_7 1 3 1 1140 2200n
load net pc_next_carry__0_i_2_n_0_repN_8 -pin core_inst pc_next_carry__0_i_2_n_0_repN_8_alias -pin pc_next_carry__0_i_2_replica_8 Q
netloc pc_next_carry__0_i_2_n_0_repN_8 1 3 1 1120 2350n
load net pc_next_carry__0_i_3_n_0 -pin core_inst pc_next_carry__0_i_1_2 -pin pc_next_carry__0_i_3 Q
netloc pc_next_carry__0_i_3_n_0 1 3 1 1200 2500n
load net pc_next_carry__0_i_3_n_0_repN -pin core_inst pc_next_carry__0_i_3_n_0_repN_alias -pin pc_next_carry__0_i_3_replica Q
netloc pc_next_carry__0_i_3_n_0_repN 1 3 1 1020 3208n
load net pc_next_carry__0_i_3_n_0_repN_1 -pin core_inst pc_next_carry__0_i_3_n_0_repN_1_alias -pin pc_next_carry__0_i_3_replica_1 Q
netloc pc_next_carry__0_i_3_n_0_repN_1 1 3 1 1100 2650n
load net pc_next_carry__0_i_3_n_0_repN_2 -pin core_inst pc_next_carry__0_i_3_n_0_repN_2_alias -pin pc_next_carry__0_i_3_replica_2 Q
netloc pc_next_carry__0_i_3_n_0_repN_2 1 3 1 1040 2800n
load net pc_next_carry__0_i_3_n_0_repN_3 -pin core_inst pc_next_carry__0_i_3_n_0_repN_3_alias -pin pc_next_carry__0_i_3_replica_3 Q
netloc pc_next_carry__0_i_3_n_0_repN_3 1 3 1 1040 3268n
load net pc_next_carry__0_i_3_n_0_repN_4 -pin core_inst pc_next_carry__0_i_3_n_0_repN_4_alias -pin pc_next_carry__0_i_3_replica_4 Q
netloc pc_next_carry__0_i_3_n_0_repN_4 1 3 1 1060 3288n
load net pc_next_carry__0_i_3_n_0_repN_5 -pin core_inst pc_next_carry__0_i_3_n_0_repN_5_alias -pin pc_next_carry__0_i_3_replica_5 Q
netloc pc_next_carry__0_i_3_n_0_repN_5 1 3 1 1100 3308n
load net pc_next_carry__0_i_3_n_0_repN_6 -pin core_inst pc_next_carry__0_i_3_n_0_repN_6_alias -pin pc_next_carry__0_i_3_replica_6 Q
netloc pc_next_carry__0_i_3_n_0_repN_6 1 3 1 1140 3328n
load net pc_next_carry__0_i_3_n_0_repN_7 -pin core_inst pc_next_carry__0_i_3_n_0_repN_7_alias -pin pc_next_carry__0_i_3_replica_7 Q
netloc pc_next_carry__0_i_3_n_0_repN_7 1 3 1 1200 3348n
load net pc_next_carry__0_i_4_n_0 -pin core_inst pc_next_carry__0_i_1 -pin pc_next_carry__0_i_4 Q
netloc pc_next_carry__0_i_4_n_0 1 3 1 1080 2948n
load net pc_next_carry__1_i_1_n_0 -pin core_inst pc_reg_reg[12]_0 -pin pc_next_carry__1_i_1 Q
netloc pc_next_carry__1_i_1_n_0 1 3 1 920 2950n
load net pc_next_carry__1_i_2_n_0 -pin core_inst pc_reg_reg[12]_1 -pin pc_next_carry__1_i_2 Q
netloc pc_next_carry__1_i_2_n_0 1 3 1 880 3100n
load net pc_next_carry_i_1_n_0 -pin core_inst pc_next_carry_i_2_1 -pin pc_next_carry_i_1 Q
netloc pc_next_carry_i_1_n_0 1 3 1 1460 4528n
load net pc_next_carry_i_2_n_0 -pin core_inst pc_next_carry_i_2_0 -pin pc_next_carry_i_2 Q
netloc pc_next_carry_i_2_n_0 1 3 1 1440 4508n
load net pc_next_carry_i_2_n_0_repN -pin core_inst pc_next_carry_i_2_n_0_repN_alias -pin pc_next_carry_i_2_replica Q
netloc pc_next_carry_i_2_n_0_repN 1 3 1 1000 3250n
load net pc_next_carry_i_2_n_0_repN_1 -pin core_inst pc_next_carry_i_2_n_0_repN_1_alias -pin pc_next_carry_i_2_replica_1 Q
netloc pc_next_carry_i_2_n_0_repN_1 1 3 1 980 3400n
load net pc_next_carry_i_2_n_0_repN_2 -pin core_inst pc_next_carry_i_2_n_0_repN_2_alias -pin pc_next_carry_i_2_replica_2 Q
netloc pc_next_carry_i_2_n_0_repN_2 1 3 1 960 3550n
load net pc_next_carry_i_2_n_0_repN_3 -pin core_inst pc_next_carry_i_2_n_0_repN_3_alias -pin pc_next_carry_i_2_replica_3 Q
netloc pc_next_carry_i_2_n_0_repN_3 1 3 1 940 3700n
load net pc_next_carry_i_2_n_0_repN_4 -pin core_inst pc_next_carry_i_2_n_0_repN_4_alias -pin pc_next_carry_i_2_replica_4 Q
netloc pc_next_carry_i_2_n_0_repN_4 1 3 1 900 3850n
load net pc_next_carry_i_2_n_0_repN_5 -pin core_inst pc_next_carry_i_2_n_0_repN_5_alias -pin pc_next_carry_i_2_replica_5 Q
netloc pc_next_carry_i_2_n_0_repN_5 1 3 1 1320 4448n
load net pc_next_carry_i_2_n_0_repN_6 -pin core_inst pc_next_carry_i_2_n_0_repN_6_alias -pin pc_next_carry_i_2_replica_6 Q
netloc pc_next_carry_i_2_n_0_repN_6 1 3 1 1420 4468n
load net pc_next_carry_i_2_n_0_repN_7 -pin core_inst pc_next_carry_i_2_n_0_repN_7_alias -pin pc_next_carry_i_2_replica_7 Q
netloc pc_next_carry_i_2_n_0_repN_7 1 3 1 1480 4488n
load net pc_next_carry_i_3_n_0 -pin core_inst pc_next_carry_i_2 -pin pc_next_carry_i_3 Q
netloc pc_next_carry_i_3_n_0 1 3 1 1360 3368n
load net pc_next_carry_i_3_n_0_repN -pin core_inst pc_next_carry_i_3_n_0_repN_alias -pin pc_next_carry_i_3_replica Q
netloc pc_next_carry_i_3_n_0_repN 1 3 1 860 4000n
load net pc_next_carry_i_3_n_0_repN_1 -pin core_inst pc_next_carry_i_3_n_0_repN_1_alias -pin pc_next_carry_i_3_replica_1 Q
netloc pc_next_carry_i_3_n_0_repN_1 1 3 1 840 4150n
load net pc_next_carry_i_3_n_0_repN_10 -pin core_inst pc_next_carry_i_3_n_0_repN_10_alias -pin pc_next_carry_i_3_replica_10 Q
netloc pc_next_carry_i_3_n_0_repN_10 1 3 1 1280 4748n
load net pc_next_carry_i_3_n_0_repN_11 -pin core_inst pc_next_carry_i_3_n_0_repN_11_alias -pin pc_next_carry_i_3_replica_11 Q
netloc pc_next_carry_i_3_n_0_repN_11 1 3 1 780 4768n
load net pc_next_carry_i_3_n_0_repN_12 -pin core_inst pc_next_carry_i_3_n_0_repN_12_alias -pin pc_next_carry_i_3_replica_12 Q
netloc pc_next_carry_i_3_n_0_repN_12 1 3 1 740 4788n
load net pc_next_carry_i_3_n_0_repN_2 -pin core_inst pc_next_carry_i_3_n_0_repN_2_alias -pin pc_next_carry_i_3_replica_2 Q
netloc pc_next_carry_i_3_n_0_repN_2 1 3 1 820 4330n
load net pc_next_carry_i_3_n_0_repN_3 -pin core_inst pc_next_carry_i_3_n_0_repN_3_alias -pin pc_next_carry_i_3_replica_3 Q
netloc pc_next_carry_i_3_n_0_repN_3 1 3 1 780 4510n
load net pc_next_carry_i_3_n_0_repN_4 -pin core_inst pc_next_carry_i_3_n_0_repN_4_alias -pin pc_next_carry_i_3_replica_4 Q
netloc pc_next_carry_i_3_n_0_repN_4 1 3 1 780 4628n
load net pc_next_carry_i_3_n_0_repN_5 -pin core_inst pc_next_carry_i_3_n_0_repN_5_alias -pin pc_next_carry_i_3_replica_5 Q
netloc pc_next_carry_i_3_n_0_repN_5 1 3 1 820 4648n
load net pc_next_carry_i_3_n_0_repN_6 -pin core_inst pc_next_carry_i_3_n_0_repN_6_alias -pin pc_next_carry_i_3_replica_6 Q
netloc pc_next_carry_i_3_n_0_repN_6 1 3 1 1120 4668n
load net pc_next_carry_i_3_n_0_repN_7 -pin core_inst pc_next_carry_i_3_n_0_repN_7_alias -pin pc_next_carry_i_3_replica_7 Q
netloc pc_next_carry_i_3_n_0_repN_7 1 3 1 1160 4688n
load net pc_next_carry_i_3_n_0_repN_8 -pin core_inst pc_next_carry_i_3_n_0_repN_8_alias -pin pc_next_carry_i_3_replica_8 Q
netloc pc_next_carry_i_3_n_0_repN_8 1 3 1 1240 4708n
load net pc_next_carry_i_3_n_0_repN_9 -pin core_inst pc_next_carry_i_3_n_0_repN_9_alias -pin pc_next_carry_i_3_replica_9 Q
netloc pc_next_carry_i_3_n_0_repN_9 1 3 1 1260 4728n
load net reset_i -pin core_inst reset_i -pin pc_next_carry__0_i_1 R -pin pc_next_carry__0_i_2 R -pin pc_next_carry__0_i_2_replica R -pin pc_next_carry__0_i_2_replica_1 R -pin pc_next_carry__0_i_2_replica_2 R -pin pc_next_carry__0_i_2_replica_3 R -pin pc_next_carry__0_i_2_replica_4 R -pin pc_next_carry__0_i_2_replica_5 R -pin pc_next_carry__0_i_2_replica_6 R -pin pc_next_carry__0_i_2_replica_7 R -pin pc_next_carry__0_i_2_replica_8 R -pin pc_next_carry__0_i_3 R -pin pc_next_carry__0_i_3_replica R -pin pc_next_carry__0_i_3_replica_1 R -pin pc_next_carry__0_i_3_replica_2 R -pin pc_next_carry__0_i_3_replica_3 R -pin pc_next_carry__0_i_3_replica_4 R -pin pc_next_carry__0_i_3_replica_5 R -pin pc_next_carry__0_i_3_replica_6 R -pin pc_next_carry__0_i_3_replica_7 R -pin pc_next_carry__0_i_4 R -pin pc_next_carry__1_i_1 R -pin pc_next_carry__1_i_2 R -pin pc_next_carry_i_1 R -pin pc_next_carry_i_2 R -pin pc_next_carry_i_2_replica R -pin pc_next_carry_i_2_replica_1 R -pin pc_next_carry_i_2_replica_2 R -pin pc_next_carry_i_2_replica_3 R -pin pc_next_carry_i_2_replica_4 R -pin pc_next_carry_i_2_replica_5 R -pin pc_next_carry_i_2_replica_6 R -pin pc_next_carry_i_2_replica_7 R -pin pc_next_carry_i_3 R -pin pc_next_carry_i_3_replica R -pin pc_next_carry_i_3_replica_1 R -pin pc_next_carry_i_3_replica_10 R -pin pc_next_carry_i_3_replica_11 R -pin pc_next_carry_i_3_replica_12 R -pin pc_next_carry_i_3_replica_2 R -pin pc_next_carry_i_3_replica_3 R -pin pc_next_carry_i_3_replica_4 R -pin pc_next_carry_i_3_replica_5 R -pin pc_next_carry_i_3_replica_6 R -pin pc_next_carry_i_3_replica_7 R -pin pc_next_carry_i_3_replica_8 R -pin pc_next_carry_i_3_replica_9 R
netloc reset_i 1 2 3 410 4230 800J 5698 7150
load net search_inst/p_0_in[10] -attr @rip(#000000) pc_reg_reg[12][8] -pin core_inst pc_reg_reg[12][8] -pin pc_next_carry__1_i_1 D
load net search_inst/p_0_in[2] -attr @rip(#000000) pc_reg_reg[12][0] -pin core_inst pc_reg_reg[12][0] -pin pc_next_carry_i_1 D
load net search_inst/p_0_in[3] -attr @rip(#000000) pc_reg_reg[12][1] -pin core_inst pc_reg_reg[12][1] -pin pc_next_carry_i_3 D -pin pc_next_carry_i_3_replica D -pin pc_next_carry_i_3_replica_1 D -pin pc_next_carry_i_3_replica_10 D -pin pc_next_carry_i_3_replica_11 D -pin pc_next_carry_i_3_replica_12 D -pin pc_next_carry_i_3_replica_2 D -pin pc_next_carry_i_3_replica_3 D -pin pc_next_carry_i_3_replica_4 D -pin pc_next_carry_i_3_replica_5 D -pin pc_next_carry_i_3_replica_6 D -pin pc_next_carry_i_3_replica_7 D -pin pc_next_carry_i_3_replica_8 D -pin pc_next_carry_i_3_replica_9 D
load net search_inst/p_0_in[4] -attr @rip(#000000) pc_reg_reg[12][2] -pin core_inst pc_reg_reg[12][2] -pin pc_next_carry_i_2 D -pin pc_next_carry_i_2_replica D -pin pc_next_carry_i_2_replica_1 D -pin pc_next_carry_i_2_replica_2 D -pin pc_next_carry_i_2_replica_3 D -pin pc_next_carry_i_2_replica_4 D -pin pc_next_carry_i_2_replica_5 D -pin pc_next_carry_i_2_replica_6 D -pin pc_next_carry_i_2_replica_7 D
load net search_inst/p_0_in[5] -attr @rip(#000000) pc_reg_reg[12][3] -pin core_inst pc_reg_reg[12][3] -pin pc_next_carry__0_i_4 D
load net search_inst/p_0_in[6] -attr @rip(#000000) pc_reg_reg[12][4] -pin core_inst pc_reg_reg[12][4] -pin pc_next_carry__0_i_3 D -pin pc_next_carry__0_i_3_replica D -pin pc_next_carry__0_i_3_replica_1 D -pin pc_next_carry__0_i_3_replica_2 D -pin pc_next_carry__0_i_3_replica_3 D -pin pc_next_carry__0_i_3_replica_4 D -pin pc_next_carry__0_i_3_replica_5 D -pin pc_next_carry__0_i_3_replica_6 D -pin pc_next_carry__0_i_3_replica_7 D
load net search_inst/p_0_in[7] -attr @rip(#000000) pc_reg_reg[12][5] -pin core_inst pc_reg_reg[12][5] -pin pc_next_carry__0_i_2 D -pin pc_next_carry__0_i_2_replica D -pin pc_next_carry__0_i_2_replica_1 D -pin pc_next_carry__0_i_2_replica_2 D -pin pc_next_carry__0_i_2_replica_3 D -pin pc_next_carry__0_i_2_replica_4 D -pin pc_next_carry__0_i_2_replica_5 D -pin pc_next_carry__0_i_2_replica_6 D -pin pc_next_carry__0_i_2_replica_7 D -pin pc_next_carry__0_i_2_replica_8 D
load net search_inst/p_0_in[8] -attr @rip(#000000) pc_reg_reg[12][6] -pin core_inst pc_reg_reg[12][6] -pin pc_next_carry__0_i_1 D
load net search_inst/p_0_in[9] -attr @rip(#000000) pc_reg_reg[12][7] -pin core_inst pc_reg_reg[12][7] -pin pc_next_carry__1_i_2 D
load net switch[0] -attr @rip(#000000) switch[0] -port switch[0] -pin switch_IBUF[0]_inst I
load net switch[10] -attr @rip(#000000) switch[10] -port switch[10] -pin switch_IBUF[10]_inst I
load net switch[11] -attr @rip(#000000) switch[11] -port switch[11] -pin switch_IBUF[11]_inst I
load net switch[12] -attr @rip(#000000) switch[12] -port switch[12] -pin switch_IBUF[12]_inst I
load net switch[13] -attr @rip(#000000) switch[13] -port switch[13] -pin switch_IBUF[13]_inst I
load net switch[14] -attr @rip(#000000) switch[14] -port switch[14] -pin switch_IBUF[14]_inst I
load net switch[15] -attr @rip(#000000) switch[15] -port switch[15] -pin switch_IBUF[15]_inst I
load net switch[1] -attr @rip(#000000) switch[1] -port switch[1] -pin switch_IBUF[1]_inst I
load net switch[2] -attr @rip(#000000) switch[2] -port switch[2] -pin switch_IBUF[2]_inst I
load net switch[3] -attr @rip(#000000) switch[3] -port switch[3] -pin switch_IBUF[3]_inst I
load net switch[4] -attr @rip(#000000) switch[4] -port switch[4] -pin switch_IBUF[4]_inst I
load net switch[5] -attr @rip(#000000) switch[5] -port switch[5] -pin switch_IBUF[5]_inst I
load net switch[6] -attr @rip(#000000) switch[6] -port switch[6] -pin switch_IBUF[6]_inst I
load net switch[7] -attr @rip(#000000) switch[7] -port switch[7] -pin switch_IBUF[7]_inst I
load net switch[8] -attr @rip(#000000) switch[8] -port switch[8] -pin switch_IBUF[8]_inst I
load net switch[9] -attr @rip(#000000) switch[9] -port switch[9] -pin switch_IBUF[9]_inst I
load net switch_IBUF[0] -attr @rip(#000000) 0 -pin core_inst switch_IBUF[0] -pin switch_IBUF[0]_inst O
load net switch_IBUF[10] -attr @rip(#000000) 10 -pin core_inst switch_IBUF[10] -pin switch_IBUF[10]_inst O
load net switch_IBUF[11] -attr @rip(#000000) 11 -pin core_inst switch_IBUF[11] -pin switch_IBUF[11]_inst O
load net switch_IBUF[12] -attr @rip(#000000) 12 -pin core_inst switch_IBUF[12] -pin switch_IBUF[12]_inst O
load net switch_IBUF[13] -attr @rip(#000000) 13 -pin core_inst switch_IBUF[13] -pin switch_IBUF[13]_inst O
load net switch_IBUF[14] -attr @rip(#000000) 14 -pin core_inst switch_IBUF[14] -pin switch_IBUF[14]_inst O
load net switch_IBUF[15] -attr @rip(#000000) 15 -pin core_inst switch_IBUF[15] -pin switch_IBUF[15]_inst O
load net switch_IBUF[1] -attr @rip(#000000) 1 -pin core_inst switch_IBUF[1] -pin switch_IBUF[1]_inst O
load net switch_IBUF[2] -attr @rip(#000000) 2 -pin core_inst switch_IBUF[2] -pin switch_IBUF[2]_inst O
load net switch_IBUF[3] -attr @rip(#000000) 3 -pin core_inst switch_IBUF[3] -pin switch_IBUF[3]_inst O
load net switch_IBUF[4] -attr @rip(#000000) 4 -pin core_inst switch_IBUF[4] -pin switch_IBUF[4]_inst O
load net switch_IBUF[5] -attr @rip(#000000) 5 -pin core_inst switch_IBUF[5] -pin switch_IBUF[5]_inst O
load net switch_IBUF[6] -attr @rip(#000000) 6 -pin core_inst switch_IBUF[6] -pin switch_IBUF[6]_inst O
load net switch_IBUF[7] -attr @rip(#000000) 7 -pin core_inst switch_IBUF[7] -pin switch_IBUF[7]_inst O
load net switch_IBUF[8] -attr @rip(#000000) 8 -pin core_inst switch_IBUF[8] -pin switch_IBUF[8]_inst O
load net switch_IBUF[9] -attr @rip(#000000) 9 -pin core_inst switch_IBUF[9] -pin switch_IBUF[9]_inst O
load net core_inst|BTNC_IBUF -attr @name BTNC_IBUF -hierPin core_inst BTNC_IBUF -pin core_inst|data_memory_inst BTNC_IBUF
netloc core_inst|BTNC_IBUF 1 0 4 NJ 2328 NJ 2328 NJ 2328 5960
load net core_inst|BTND_IBUF -attr @name BTND_IBUF -hierPin core_inst BTND_IBUF -pin core_inst|data_memory_inst BTND_IBUF
netloc core_inst|BTND_IBUF 1 0 4 NJ 2348 NJ 2348 NJ 2348 5940
load net core_inst|BTNL_IBUF -attr @name BTNL_IBUF -hierPin core_inst BTNL_IBUF -pin core_inst|data_memory_inst BTNL_IBUF
netloc core_inst|BTNL_IBUF 1 0 4 NJ 2368 NJ 2368 NJ 2368 5920
load net core_inst|BTNR_IBUF -attr @name BTNR_IBUF -hierPin core_inst BTNR_IBUF -pin core_inst|data_memory_inst BTNR_IBUF
netloc core_inst|BTNR_IBUF 1 0 4 NJ 2388 NJ 2388 NJ 2388 5900
load net core_inst|BTNU_IBUF -attr @name BTNU_IBUF -hierPin core_inst BTNU_IBUF -pin core_inst|data_memory_inst BTNU_IBUF
netloc core_inst|BTNU_IBUF 1 0 4 NJ 2408 NJ 2408 NJ 2408 5880
load net core_inst|CPU_RESETN_IBUF -attr @name CPU_RESETN_IBUF -hierPin core_inst CPU_RESETN_IBUF -pin core_inst|search_inst CPU_RESETN_IBUF
netloc core_inst|CPU_RESETN_IBUF 1 0 3 NJ 2888 NJ 2888 3770
load net core_inst|JA_IBUF[0] -attr @rip JA_IBUF[0] -attr @name JA_IBUF[0] -hierPin core_inst JA_IBUF[0] -pin core_inst|data_memory_inst JA_IBUF[0]
load net core_inst|JA_IBUF[1] -attr @rip JA_IBUF[1] -attr @name JA_IBUF[1] -hierPin core_inst JA_IBUF[1] -pin core_inst|search_inst JA_IBUF[0]
load net core_inst|JA_IBUF[2] -attr @rip JA_IBUF[2] -attr @name JA_IBUF[2] -hierPin core_inst JA_IBUF[2] -pin core_inst|search_inst JA_IBUF[1]
load net core_inst|JA_IBUF[3] -attr @rip JA_IBUF[3] -attr @name JA_IBUF[3] -hierPin core_inst JA_IBUF[3] -pin core_inst|search_inst JA_IBUF[2]
load net core_inst|O_alias -attr @name O_alias -pin core_inst|data_memory_inst O_alias -pin core_inst|search_inst O_alias
netloc core_inst|O_alias 1 2 3 3830 2468 5740J 4168 6800
load net core_inst|O_alias_1 -attr @name O_alias_1 -pin core_inst|data_memory_inst O_alias_1 -pin core_inst|search_inst O_alias_1
netloc core_inst|O_alias_1 1 2 3 3850 2488 5700J 4188 6740
load net core_inst|Q[0] -attr @rip Q[0] -attr @name Q[0] -hierPin core_inst Q[0] -pin core_inst|data_memory_inst Q[0]
load net core_inst|Q[10] -attr @rip Q[10] -attr @name Q[10] -hierPin core_inst Q[10] -pin core_inst|data_memory_inst Q[10] -pin core_inst|search_inst Q[5]
load net core_inst|Q[11] -attr @rip Q[11] -attr @name Q[11] -hierPin core_inst Q[11] -pin core_inst|data_memory_inst Q[11] -pin core_inst|search_inst Q[6]
load net core_inst|Q[12] -attr @rip Q[12] -attr @name Q[12] -hierPin core_inst Q[12] -pin core_inst|data_memory_inst Q[12] -pin core_inst|search_inst Q[7]
load net core_inst|Q[13] -attr @rip Q[13] -attr @name Q[13] -hierPin core_inst Q[13] -pin core_inst|data_memory_inst Q[13] -pin core_inst|search_inst Q[8]
load net core_inst|Q[14] -attr @rip Q[14] -attr @name Q[14] -hierPin core_inst Q[14] -pin core_inst|data_memory_inst Q[14] -pin core_inst|search_inst Q[9]
load net core_inst|Q[15] -attr @rip Q[15] -attr @name Q[15] -hierPin core_inst Q[15] -pin core_inst|data_memory_inst Q[15] -pin core_inst|search_inst Q[10]
load net core_inst|Q[1] -attr @rip Q[1] -attr @name Q[1] -hierPin core_inst Q[1] -pin core_inst|data_memory_inst Q[1]
load net core_inst|Q[2] -attr @rip Q[2] -attr @name Q[2] -hierPin core_inst Q[2] -pin core_inst|data_memory_inst Q[2]
load net core_inst|Q[3] -attr @rip Q[3] -attr @name Q[3] -hierPin core_inst Q[3] -pin core_inst|data_memory_inst Q[3]
load net core_inst|Q[4] -attr @rip Q[4] -attr @name Q[4] -hierPin core_inst Q[4] -pin core_inst|data_memory_inst Q[4]
load net core_inst|Q[5] -attr @rip Q[5] -attr @name Q[5] -hierPin core_inst Q[5] -pin core_inst|data_memory_inst Q[5] -pin core_inst|search_inst Q[0]
load net core_inst|Q[6] -attr @rip Q[6] -attr @name Q[6] -hierPin core_inst Q[6] -pin core_inst|data_memory_inst Q[6] -pin core_inst|search_inst Q[1]
load net core_inst|Q[7] -attr @rip Q[7] -attr @name Q[7] -hierPin core_inst Q[7] -pin core_inst|data_memory_inst Q[7] -pin core_inst|search_inst Q[2]
load net core_inst|Q[8] -attr @rip Q[8] -attr @name Q[8] -hierPin core_inst Q[8] -pin core_inst|data_memory_inst Q[8] -pin core_inst|search_inst Q[3]
load net core_inst|Q[9] -attr @rip Q[9] -attr @name Q[9] -hierPin core_inst Q[9] -pin core_inst|data_memory_inst Q[9] -pin core_inst|search_inst Q[4]
load net core_inst|alu_a[28] -attr @rip pc_reg_reg[31]_0[0] -attr @name alu_a[28] -pin core_inst|execution_inst alu_a[0] -pin core_inst|search_inst pc_reg_reg[31]_0[0]
load net core_inst|alu_a[29] -attr @rip pc_reg_reg[31]_0[1] -attr @name alu_a[29] -pin core_inst|execution_inst alu_a[1] -pin core_inst|search_inst pc_reg_reg[31]_0[1]
load net core_inst|alu_a[30] -attr @rip pc_reg_reg[31]_0[2] -attr @name alu_a[30] -pin core_inst|execution_inst alu_a[2] -pin core_inst|search_inst pc_reg_reg[31]_0[2]
load net core_inst|alu_a[31] -attr @rip pc_reg_reg[31]_0[3] -attr @name alu_a[31] -pin core_inst|execution_inst alu_a[3] -pin core_inst|search_inst pc_reg_reg[31]_0[3]
load net core_inst|alu_a_select -attr @name alu_a_select -pin core_inst|execution_inst alu_a_select -pin core_inst|search_inst alu_a_select
netloc core_inst|alu_a_select 1 1 3 2390 3428 3030J 2608 4900
load net core_inst|alu_b__226[28] -attr @rip pc_next_carry__1_i_1[0] -attr @name alu_b__226[28] -pin core_inst|execution_inst alu_b__226[0] -pin core_inst|search_inst pc_next_carry__1_i_1[0]
load net core_inst|alu_b__226[29] -attr @rip pc_next_carry__1_i_1[1] -attr @name alu_b__226[29] -pin core_inst|execution_inst alu_b__226[1] -pin core_inst|search_inst pc_next_carry__1_i_1[1]
load net core_inst|alu_b__226[30] -attr @rip pc_next_carry__1_i_1[2] -attr @name alu_b__226[30] -pin core_inst|execution_inst alu_b__226[2] -pin core_inst|search_inst pc_next_carry__1_i_1[2]
load net core_inst|alu_b__226[31] -attr @rip pc_next_carry__1_i_1[3] -attr @name alu_b__226[31] -pin core_inst|execution_inst alu_b__226[3] -pin core_inst|search_inst pc_next_carry__1_i_1[3]
load net core_inst|alu_control[0] -attr @rip pc_next_carry__1_i_1_1[0] -attr @name alu_control[0] -pin core_inst|execution_inst alu_control[0] -pin core_inst|search_inst pc_next_carry__1_i_1_1[0]
netloc core_inst|alu_control[0] 1 1 3 2510 3588 3330J 2768 4720
load net core_inst|alu_inst/is_sub -attr @name alu_inst/is_sub -pin core_inst|execution_inst is_sub -pin core_inst|search_inst is_sub
netloc core_inst|alu_inst/is_sub 1 1 3 2490 3468 3070J 2648 4740
load net core_inst|alu_result[10] -attr @rip alu_result[8] -attr @name alu_result[10] -pin core_inst|data_memory_inst alu_result[8] -pin core_inst|search_inst alu_result[8]
load net core_inst|alu_result[11] -attr @rip alu_result[9] -attr @name alu_result[11] -pin core_inst|data_memory_inst alu_result[9] -pin core_inst|search_inst alu_result[9]
load net core_inst|alu_result[2] -attr @rip alu_result[0] -attr @name alu_result[2] -pin core_inst|data_memory_inst alu_result[0] -pin core_inst|search_inst alu_result[0]
load net core_inst|alu_result[3] -attr @rip alu_result[1] -attr @name alu_result[3] -pin core_inst|data_memory_inst alu_result[1] -pin core_inst|search_inst alu_result[1]
load net core_inst|alu_result[4] -attr @rip alu_result[2] -attr @name alu_result[4] -pin core_inst|data_memory_inst alu_result[2] -pin core_inst|search_inst alu_result[2]
load net core_inst|alu_result[5] -attr @rip alu_result[3] -attr @name alu_result[5] -pin core_inst|data_memory_inst alu_result[3] -pin core_inst|search_inst alu_result[3]
load net core_inst|alu_result[6] -attr @rip alu_result[4] -attr @name alu_result[6] -pin core_inst|data_memory_inst alu_result[4] -pin core_inst|search_inst alu_result[4]
load net core_inst|alu_result[7] -attr @rip alu_result[5] -attr @name alu_result[7] -pin core_inst|data_memory_inst alu_result[5] -pin core_inst|search_inst alu_result[5]
load net core_inst|alu_result[8] -attr @rip alu_result[6] -attr @name alu_result[8] -pin core_inst|data_memory_inst alu_result[6] -pin core_inst|search_inst alu_result[6]
load net core_inst|alu_result[9] -attr @rip alu_result[7] -attr @name alu_result[9] -pin core_inst|data_memory_inst alu_result[7] -pin core_inst|search_inst alu_result[7]
load net core_inst|alu_result__0[1]_alias -attr @name alu_result__0[1]_alias -pin core_inst|data_memory_inst alu_result__0[1]_alias -pin core_inst|search_inst alu_result__0[1]_alias
netloc core_inst|alu_result__0[1]_alias 1 3 1 N 2948
load net core_inst|clk_IBUF_BUFG -attr @name clk_IBUF_BUFG -hierPin core_inst clk_IBUF_BUFG -pin core_inst|data_memory_inst clk_IBUF_BUFG -pin core_inst|decoder_inst clk_IBUF_BUFG -pin core_inst|search_inst clk_IBUF_BUFG
netloc core_inst|clk_IBUF_BUFG 1 0 4 1850 2988 NJ 2988 3810 2448 5760J
load net core_inst|data_memory_inst_n_64 -attr @name data_memory_inst_n_64 -pin core_inst|data_memory_inst seg7_o_reg[1]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_25_0
netloc core_inst|data_memory_inst_n_64 1 2 3 3810 4568 NJ 4568 6760
load net core_inst|data_memory_inst_n_65 -attr @name data_memory_inst_n_65 -pin core_inst|data_memory_inst seg7_o_reg[2]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_33_0
netloc core_inst|data_memory_inst_n_65 1 2 3 3870 4608 NJ 4608 6840
load net core_inst|data_memory_inst_n_66 -attr @name data_memory_inst_n_66 -pin core_inst|data_memory_inst seg7_o_reg[3]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_31_0
netloc core_inst|data_memory_inst_n_66 1 2 3 3830 4588 NJ 4588 6700
load net core_inst|decoder_inst_n_64 -attr @name decoder_inst_n_64 -pin core_inst|decoder_inst pc_next_carry_i_3 -pin core_inst|search_inst branch_address0_carry__2_i_10_0
netloc core_inst|decoder_inst_n_64 1 1 2 2370 3608 3470J
load net core_inst|decoder_inst_n_65 -attr @name decoder_inst_n_65 -pin core_inst|decoder_inst pc_next_carry__0_i_4 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_13_0
netloc core_inst|decoder_inst_n_65 1 1 2 2390J 4168 N
load net core_inst|execution_inst_n_31 -attr @name execution_inst_n_31 -pin core_inst|execution_inst pc_reg_reg[31] -pin core_inst|search_inst pc_reg[31]_i_6_0
netloc core_inst|execution_inst_n_31 1 2 1 3010 3928n
load net core_inst|execution_inst_n_32 -attr @rip O[3] -attr @name execution_inst_n_32 -pin core_inst|execution_inst O[3] -pin core_inst|search_inst O[3]
load net core_inst|execution_inst_n_33 -attr @rip O[2] -attr @name execution_inst_n_33 -pin core_inst|execution_inst O[2] -pin core_inst|search_inst O[2]
load net core_inst|execution_inst_n_34 -attr @rip O[1] -attr @name execution_inst_n_34 -pin core_inst|execution_inst O[1] -pin core_inst|search_inst O[1]
load net core_inst|execution_inst_n_35 -attr @rip O[0] -attr @name execution_inst_n_35 -pin core_inst|execution_inst O[0] -pin core_inst|search_inst O[0]
load net core_inst|execution_inst_n_36 -attr @name execution_inst_n_36 -pin core_inst|execution_inst pc_reg[31]_i_41 -pin core_inst|search_inst pc_reg[31]_i_14_0
netloc core_inst|execution_inst_n_36 1 2 1 3070 3908n
load net core_inst|immediate[0] -attr @rip immediate[0] -attr @name immediate[0] -pin core_inst|execution_inst immediate[0] -pin core_inst|search_inst immediate[0]
load net core_inst|immediate[10] -attr @rip immediate[10] -attr @name immediate[10] -pin core_inst|execution_inst immediate[10] -pin core_inst|search_inst immediate[10]
load net core_inst|immediate[11] -attr @rip immediate[11] -attr @name immediate[11] -pin core_inst|execution_inst immediate[11] -pin core_inst|search_inst immediate[11]
load net core_inst|immediate[12] -attr @rip immediate[12] -attr @name immediate[12] -pin core_inst|execution_inst immediate[12] -pin core_inst|search_inst immediate[12]
load net core_inst|immediate[13] -attr @rip immediate[13] -attr @name immediate[13] -pin core_inst|execution_inst immediate[13] -pin core_inst|search_inst immediate[13]
load net core_inst|immediate[14] -attr @rip immediate[14] -attr @name immediate[14] -pin core_inst|execution_inst immediate[14] -pin core_inst|search_inst immediate[14]
load net core_inst|immediate[15] -attr @rip immediate[15] -attr @name immediate[15] -pin core_inst|execution_inst immediate[15] -pin core_inst|search_inst immediate[15]
load net core_inst|immediate[16] -attr @rip immediate[16] -attr @name immediate[16] -pin core_inst|execution_inst immediate[16] -pin core_inst|search_inst immediate[16]
load net core_inst|immediate[17] -attr @rip immediate[17] -attr @name immediate[17] -pin core_inst|execution_inst immediate[17] -pin core_inst|search_inst immediate[17]
load net core_inst|immediate[18] -attr @rip immediate[18] -attr @name immediate[18] -pin core_inst|execution_inst immediate[18] -pin core_inst|search_inst immediate[18]
load net core_inst|immediate[19] -attr @rip immediate[19] -attr @name immediate[19] -pin core_inst|execution_inst immediate[19] -pin core_inst|search_inst immediate[19]
load net core_inst|immediate[1] -attr @rip immediate[1] -attr @name immediate[1] -pin core_inst|execution_inst immediate[1] -pin core_inst|search_inst immediate[1]
load net core_inst|immediate[20] -attr @rip immediate[20] -attr @name immediate[20] -pin core_inst|execution_inst immediate[20] -pin core_inst|search_inst immediate[20]
load net core_inst|immediate[21] -attr @rip immediate[21] -attr @name immediate[21] -pin core_inst|execution_inst immediate[21] -pin core_inst|search_inst immediate[21]
load net core_inst|immediate[22] -attr @rip immediate[22] -attr @name immediate[22] -pin core_inst|execution_inst immediate[22] -pin core_inst|search_inst immediate[22]
load net core_inst|immediate[23] -attr @rip immediate[23] -attr @name immediate[23] -pin core_inst|execution_inst immediate[23] -pin core_inst|search_inst immediate[23]
load net core_inst|immediate[24] -attr @rip immediate[24] -attr @name immediate[24] -pin core_inst|execution_inst immediate[24] -pin core_inst|search_inst immediate[24]
load net core_inst|immediate[25] -attr @rip immediate[25] -attr @name immediate[25] -pin core_inst|execution_inst immediate[25] -pin core_inst|search_inst immediate[25]
load net core_inst|immediate[26] -attr @rip immediate[26] -attr @name immediate[26] -pin core_inst|execution_inst immediate[26] -pin core_inst|search_inst immediate[26]
load net core_inst|immediate[27] -attr @rip immediate[27] -attr @name immediate[27] -pin core_inst|execution_inst immediate[27] -pin core_inst|search_inst immediate[27]
load net core_inst|immediate[28] -attr @rip immediate[28] -attr @name immediate[28] -pin core_inst|execution_inst immediate[28] -pin core_inst|search_inst immediate[28]
load net core_inst|immediate[29] -attr @rip immediate[29] -attr @name immediate[29] -pin core_inst|execution_inst immediate[29] -pin core_inst|search_inst immediate[29]
load net core_inst|immediate[2] -attr @rip immediate[2] -attr @name immediate[2] -pin core_inst|execution_inst immediate[2] -pin core_inst|search_inst immediate[2]
load net core_inst|immediate[30] -attr @rip immediate[30] -attr @name immediate[30] -pin core_inst|execution_inst immediate[30] -pin core_inst|search_inst immediate[30]
load net core_inst|immediate[3] -attr @rip immediate[3] -attr @name immediate[3] -pin core_inst|execution_inst immediate[3] -pin core_inst|search_inst immediate[3]
load net core_inst|immediate[4] -attr @rip immediate[4] -attr @name immediate[4] -pin core_inst|execution_inst immediate[4] -pin core_inst|search_inst immediate[4]
load net core_inst|immediate[5] -attr @rip immediate[5] -attr @name immediate[5] -pin core_inst|execution_inst immediate[5] -pin core_inst|search_inst immediate[5]
load net core_inst|immediate[6] -attr @rip immediate[6] -attr @name immediate[6] -pin core_inst|execution_inst immediate[6] -pin core_inst|search_inst immediate[6]
load net core_inst|immediate[7] -attr @rip immediate[7] -attr @name immediate[7] -pin core_inst|execution_inst immediate[7] -pin core_inst|search_inst immediate[7]
load net core_inst|immediate[8] -attr @rip immediate[8] -attr @name immediate[8] -pin core_inst|execution_inst immediate[8] -pin core_inst|search_inst immediate[8]
load net core_inst|immediate[9] -attr @rip immediate[9] -attr @name immediate[9] -pin core_inst|execution_inst immediate[9] -pin core_inst|search_inst immediate[9]
load net core_inst|instruction[10] -attr @rip pc_next_carry__1_i_1_0[3] -attr @name instruction[10] -pin core_inst|decoder_inst instruction[3] -pin core_inst|search_inst pc_next_carry__1_i_1_0[3]
load net core_inst|instruction[11] -attr @rip pc_next_carry__1_i_1_0[4] -attr @name instruction[11] -pin core_inst|decoder_inst instruction[4] -pin core_inst|search_inst pc_next_carry__1_i_1_0[4]
load net core_inst|instruction[15] -attr @rip pc_next_carry__1_i_1_0[5] -attr @name instruction[15] -pin core_inst|decoder_inst instruction[5] -pin core_inst|search_inst pc_next_carry__1_i_1_0[5]
load net core_inst|instruction[16] -attr @rip pc_next_carry__1_i_1_0[6] -attr @name instruction[16] -pin core_inst|decoder_inst instruction[6] -pin core_inst|search_inst pc_next_carry__1_i_1_0[6]
load net core_inst|instruction[17] -attr @rip pc_next_carry__1_i_1_0[7] -attr @name instruction[17] -pin core_inst|decoder_inst instruction[7] -pin core_inst|search_inst pc_next_carry__1_i_1_0[7]
load net core_inst|instruction[18] -attr @rip pc_next_carry__1_i_1_0[8] -attr @name instruction[18] -pin core_inst|decoder_inst instruction[8] -pin core_inst|search_inst pc_next_carry__1_i_1_0[8]
load net core_inst|instruction[19] -attr @rip pc_next_carry__1_i_1_0[9] -attr @name instruction[19] -pin core_inst|decoder_inst instruction[9] -pin core_inst|search_inst pc_next_carry__1_i_1_0[9]
load net core_inst|instruction[20] -attr @rip pc_next_carry__1_i_1_0[10] -attr @name instruction[20] -pin core_inst|decoder_inst instruction[10] -pin core_inst|search_inst pc_next_carry__1_i_1_0[10]
load net core_inst|instruction[21] -attr @rip pc_next_carry__1_i_1_0[11] -attr @name instruction[21] -pin core_inst|decoder_inst instruction[11] -pin core_inst|search_inst pc_next_carry__1_i_1_0[11]
load net core_inst|instruction[22] -attr @rip pc_next_carry__1_i_1_0[12] -attr @name instruction[22] -pin core_inst|decoder_inst instruction[12] -pin core_inst|search_inst pc_next_carry__1_i_1_0[12]
load net core_inst|instruction[23] -attr @rip pc_next_carry__1_i_1_0[13] -attr @name instruction[23] -pin core_inst|decoder_inst instruction[13] -pin core_inst|search_inst pc_next_carry__1_i_1_0[13]
load net core_inst|instruction[24] -attr @rip pc_next_carry__1_i_1_0[14] -attr @name instruction[24] -pin core_inst|decoder_inst instruction[14] -pin core_inst|search_inst pc_next_carry__1_i_1_0[14]
load net core_inst|instruction[7] -attr @rip pc_next_carry__1_i_1_0[0] -attr @name instruction[7] -pin core_inst|decoder_inst instruction[0] -pin core_inst|search_inst pc_next_carry__1_i_1_0[0]
load net core_inst|instruction[8] -attr @rip pc_next_carry__1_i_1_0[1] -attr @name instruction[8] -pin core_inst|decoder_inst instruction[1] -pin core_inst|search_inst pc_next_carry__1_i_1_0[1]
load net core_inst|instruction[9] -attr @rip pc_next_carry__1_i_1_0[2] -attr @name instruction[9] -pin core_inst|decoder_inst instruction[2] -pin core_inst|search_inst pc_next_carry__1_i_1_0[2]
load net core_inst|lopt -attr @name lopt -hierPin core_inst lopt -pin core_inst|data_memory_inst lopt
netloc core_inst|lopt 1 4 1 N 3068
load net core_inst|lopt_1 -attr @name lopt_1 -hierPin core_inst lopt_1 -pin core_inst|data_memory_inst lopt_1
netloc core_inst|lopt_1 1 4 1 N 3088
load net core_inst|lopt_10 -attr @name lopt_10 -hierPin core_inst lopt_10 -pin core_inst|data_memory_inst lopt_10
netloc core_inst|lopt_10 1 4 1 N 3268
load net core_inst|lopt_11 -attr @name lopt_11 -hierPin core_inst lopt_11 -pin core_inst|data_memory_inst lopt_11
netloc core_inst|lopt_11 1 4 1 N 3288
load net core_inst|lopt_12 -attr @name lopt_12 -hierPin core_inst lopt_12 -pin core_inst|data_memory_inst lopt_12
netloc core_inst|lopt_12 1 4 1 N 3308
load net core_inst|lopt_13 -attr @name lopt_13 -hierPin core_inst lopt_13 -pin core_inst|data_memory_inst lopt_13
netloc core_inst|lopt_13 1 4 1 N 3328
load net core_inst|lopt_14 -attr @name lopt_14 -hierPin core_inst lopt_14 -pin core_inst|data_memory_inst lopt_14
netloc core_inst|lopt_14 1 4 1 N 3348
load net core_inst|lopt_15 -attr @name lopt_15 -hierPin core_inst lopt_15 -pin core_inst|data_memory_inst lopt_15
netloc core_inst|lopt_15 1 4 1 N 3368
load net core_inst|lopt_16 -attr @name lopt_16 -hierPin core_inst lopt_16 -pin core_inst|data_memory_inst lopt_16
netloc core_inst|lopt_16 1 4 1 N 3388
load net core_inst|lopt_17 -attr @name lopt_17 -hierPin core_inst lopt_17 -pin core_inst|data_memory_inst lopt_17
netloc core_inst|lopt_17 1 4 1 N 3408
load net core_inst|lopt_18 -attr @name lopt_18 -hierPin core_inst lopt_18 -pin core_inst|data_memory_inst lopt_18
netloc core_inst|lopt_18 1 4 1 N 3428
load net core_inst|lopt_19 -attr @name lopt_19 -hierPin core_inst lopt_19 -pin core_inst|data_memory_inst lopt_19
netloc core_inst|lopt_19 1 4 1 N 3448
load net core_inst|lopt_2 -attr @name lopt_2 -hierPin core_inst lopt_2 -pin core_inst|data_memory_inst lopt_2
netloc core_inst|lopt_2 1 4 1 N 3108
load net core_inst|lopt_20 -attr @name lopt_20 -hierPin core_inst lopt_20 -pin core_inst|data_memory_inst lopt_20
netloc core_inst|lopt_20 1 4 1 N 3468
load net core_inst|lopt_21 -attr @name lopt_21 -hierPin core_inst lopt_21 -pin core_inst|data_memory_inst lopt_21
netloc core_inst|lopt_21 1 4 1 N 3488
load net core_inst|lopt_22 -attr @name lopt_22 -hierPin core_inst lopt_22 -pin core_inst|data_memory_inst lopt_22
netloc core_inst|lopt_22 1 4 1 N 3508
load net core_inst|lopt_23 -attr @name lopt_23 -hierPin core_inst lopt_23 -pin core_inst|data_memory_inst lopt_23
netloc core_inst|lopt_23 1 4 1 N 3528
load net core_inst|lopt_24 -attr @name lopt_24 -hierPin core_inst lopt_24 -pin core_inst|data_memory_inst lopt_24
netloc core_inst|lopt_24 1 4 1 N 3548
load net core_inst|lopt_25 -attr @name lopt_25 -hierPin core_inst lopt_25 -pin core_inst|data_memory_inst lopt_25
netloc core_inst|lopt_25 1 4 1 N 3568
load net core_inst|lopt_26 -attr @name lopt_26 -hierPin core_inst lopt_26 -pin core_inst|data_memory_inst lopt_26
netloc core_inst|lopt_26 1 4 1 N 3588
load net core_inst|lopt_27 -attr @name lopt_27 -hierPin core_inst lopt_27 -pin core_inst|data_memory_inst lopt_27
netloc core_inst|lopt_27 1 4 1 N 3608
load net core_inst|lopt_28 -attr @name lopt_28 -hierPin core_inst lopt_28 -pin core_inst|data_memory_inst lopt_28
netloc core_inst|lopt_28 1 4 1 N 3628
load net core_inst|lopt_29 -attr @name lopt_29 -hierPin core_inst lopt_29 -pin core_inst|data_memory_inst lopt_29
netloc core_inst|lopt_29 1 4 1 N 3648
load net core_inst|lopt_3 -attr @name lopt_3 -hierPin core_inst lopt_3 -pin core_inst|data_memory_inst lopt_3
netloc core_inst|lopt_3 1 4 1 N 3128
load net core_inst|lopt_30 -attr @name lopt_30 -hierPin core_inst lopt_30 -pin core_inst|data_memory_inst lopt_30
netloc core_inst|lopt_30 1 4 1 N 3668
load net core_inst|lopt_31 -attr @name lopt_31 -hierPin core_inst lopt_31 -pin core_inst|data_memory_inst lopt_31
netloc core_inst|lopt_31 1 4 1 N 3688
load net core_inst|lopt_4 -attr @name lopt_4 -hierPin core_inst lopt_4 -pin core_inst|data_memory_inst lopt_4
netloc core_inst|lopt_4 1 4 1 N 3148
load net core_inst|lopt_5 -attr @name lopt_5 -hierPin core_inst lopt_5 -pin core_inst|data_memory_inst lopt_5
netloc core_inst|lopt_5 1 4 1 N 3168
load net core_inst|lopt_6 -attr @name lopt_6 -hierPin core_inst lopt_6 -pin core_inst|data_memory_inst lopt_6
netloc core_inst|lopt_6 1 4 1 N 3188
load net core_inst|lopt_7 -attr @name lopt_7 -hierPin core_inst lopt_7 -pin core_inst|data_memory_inst lopt_7
netloc core_inst|lopt_7 1 4 1 N 3208
load net core_inst|lopt_8 -attr @name lopt_8 -hierPin core_inst lopt_8 -pin core_inst|data_memory_inst lopt_8
netloc core_inst|lopt_8 1 4 1 N 3228
load net core_inst|lopt_9 -attr @name lopt_9 -hierPin core_inst lopt_9 -pin core_inst|data_memory_inst lopt_9
netloc core_inst|lopt_9 1 4 1 N 3248
load net core_inst|mem_reg_0_255_31_31_0[21]_repN_1_alias -attr @name mem_reg_0_255_31_31_0[21]_repN_1_alias -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[21]_repN_1_alias -pin core_inst|search_inst mem_reg_0_255_31_31_0[21]_repN_1_alias
netloc core_inst|mem_reg_0_255_31_31_0[21]_repN_1_alias 1 2 3 3910 2548 5580J 4248 6780
load net core_inst|mem_reg_0_255_31_31_0[21]_repN_2_alias -attr @name mem_reg_0_255_31_31_0[21]_repN_2_alias -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[21]_repN_2_alias -pin core_inst|search_inst mem_reg_0_255_31_31_0[21]_repN_2_alias
netloc core_inst|mem_reg_0_255_31_31_0[21]_repN_2_alias 1 2 3 3930 2568 5540J 4268 6720
load net core_inst|mem_reg_0_255_31_31_0[21]_repN_alias -attr @name mem_reg_0_255_31_31_0[21]_repN_alias -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[21]_repN_alias -pin core_inst|search_inst mem_reg_0_255_31_31_0[21]_repN_alias
netloc core_inst|mem_reg_0_255_31_31_0[21]_repN_alias 1 2 3 3890 2528 5620J 4228 6860
load net core_inst|p_0_in -attr @name p_0_in -pin core_inst|decoder_inst p_0_in -pin core_inst|search_inst p_0_in
netloc core_inst|p_0_in 1 0 4 1870 3488 NJ 3488 3110J 2668 4860
load net core_inst|p_1_in__0[0] -attr @rip p_1_in__0[0] -attr @name p_1_in__0[0] -pin core_inst|data_memory_inst p_1_in__0[0] -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_7_0[0]
load net core_inst|p_1_in__0[4] -attr @rip p_1_in__0[1] -attr @name p_1_in__0[4] -pin core_inst|data_memory_inst p_1_in__0[1] -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_7_0[1]
load net core_inst|pc[28] -attr @rip pc_reg_reg[30]_0[0] -attr @name pc[28] -pin core_inst|execution_inst pc[0] -pin core_inst|search_inst pc_reg_reg[30]_0[0]
load net core_inst|pc[29] -attr @rip pc_reg_reg[30]_0[1] -attr @name pc[29] -pin core_inst|execution_inst pc[1] -pin core_inst|search_inst pc_reg_reg[30]_0[1]
load net core_inst|pc[30] -attr @rip pc_reg_reg[30]_0[2] -attr @name pc[30] -pin core_inst|execution_inst pc[2] -pin core_inst|search_inst pc_reg_reg[30]_0[2]
load net core_inst|pc_branch[10] -attr @rip pc_branch[9] -attr @name pc_branch[10] -pin core_inst|execution_inst pc_branch[9] -pin core_inst|search_inst pc_branch[9]
load net core_inst|pc_branch[11] -attr @rip pc_branch[10] -attr @name pc_branch[11] -pin core_inst|execution_inst pc_branch[10] -pin core_inst|search_inst pc_branch[10]
load net core_inst|pc_branch[12] -attr @rip pc_branch[11] -attr @name pc_branch[12] -pin core_inst|execution_inst pc_branch[11] -pin core_inst|search_inst pc_branch[11]
load net core_inst|pc_branch[13] -attr @rip pc_branch[12] -attr @name pc_branch[13] -pin core_inst|execution_inst pc_branch[12] -pin core_inst|search_inst pc_branch[12]
load net core_inst|pc_branch[14] -attr @rip pc_branch[13] -attr @name pc_branch[14] -pin core_inst|execution_inst pc_branch[13] -pin core_inst|search_inst pc_branch[13]
load net core_inst|pc_branch[15] -attr @rip pc_branch[14] -attr @name pc_branch[15] -pin core_inst|execution_inst pc_branch[14] -pin core_inst|search_inst pc_branch[14]
load net core_inst|pc_branch[16] -attr @rip pc_branch[15] -attr @name pc_branch[16] -pin core_inst|execution_inst pc_branch[15] -pin core_inst|search_inst pc_branch[15]
load net core_inst|pc_branch[17] -attr @rip pc_branch[16] -attr @name pc_branch[17] -pin core_inst|execution_inst pc_branch[16] -pin core_inst|search_inst pc_branch[16]
load net core_inst|pc_branch[18] -attr @rip pc_branch[17] -attr @name pc_branch[18] -pin core_inst|execution_inst pc_branch[17] -pin core_inst|search_inst pc_branch[17]
load net core_inst|pc_branch[19] -attr @rip pc_branch[18] -attr @name pc_branch[19] -pin core_inst|execution_inst pc_branch[18] -pin core_inst|search_inst pc_branch[18]
load net core_inst|pc_branch[1] -attr @rip pc_branch[0] -attr @name pc_branch[1] -pin core_inst|execution_inst pc_branch[0] -pin core_inst|search_inst pc_branch[0]
load net core_inst|pc_branch[20] -attr @rip pc_branch[19] -attr @name pc_branch[20] -pin core_inst|execution_inst pc_branch[19] -pin core_inst|search_inst pc_branch[19]
load net core_inst|pc_branch[21] -attr @rip pc_branch[20] -attr @name pc_branch[21] -pin core_inst|execution_inst pc_branch[20] -pin core_inst|search_inst pc_branch[20]
load net core_inst|pc_branch[22] -attr @rip pc_branch[21] -attr @name pc_branch[22] -pin core_inst|execution_inst pc_branch[21] -pin core_inst|search_inst pc_branch[21]
load net core_inst|pc_branch[23] -attr @rip pc_branch[22] -attr @name pc_branch[23] -pin core_inst|execution_inst pc_branch[22] -pin core_inst|search_inst pc_branch[22]
load net core_inst|pc_branch[24] -attr @rip pc_branch[23] -attr @name pc_branch[24] -pin core_inst|execution_inst pc_branch[23] -pin core_inst|search_inst pc_branch[23]
load net core_inst|pc_branch[25] -attr @rip pc_branch[24] -attr @name pc_branch[25] -pin core_inst|execution_inst pc_branch[24] -pin core_inst|search_inst pc_branch[24]
load net core_inst|pc_branch[26] -attr @rip pc_branch[25] -attr @name pc_branch[26] -pin core_inst|execution_inst pc_branch[25] -pin core_inst|search_inst pc_branch[25]
load net core_inst|pc_branch[27] -attr @rip pc_branch[26] -attr @name pc_branch[27] -pin core_inst|execution_inst pc_branch[26] -pin core_inst|search_inst pc_branch[26]
load net core_inst|pc_branch[28] -attr @rip pc_branch[27] -attr @name pc_branch[28] -pin core_inst|execution_inst pc_branch[27] -pin core_inst|search_inst pc_branch[27]
load net core_inst|pc_branch[29] -attr @rip pc_branch[28] -attr @name pc_branch[29] -pin core_inst|execution_inst pc_branch[28] -pin core_inst|search_inst pc_branch[28]
load net core_inst|pc_branch[2] -attr @rip pc_branch[1] -attr @name pc_branch[2] -pin core_inst|execution_inst pc_branch[1] -pin core_inst|search_inst pc_branch[1]
load net core_inst|pc_branch[30] -attr @rip pc_branch[29] -attr @name pc_branch[30] -pin core_inst|execution_inst pc_branch[29] -pin core_inst|search_inst pc_branch[29]
load net core_inst|pc_branch[31] -attr @rip pc_branch[30] -attr @name pc_branch[31] -pin core_inst|execution_inst pc_branch[30] -pin core_inst|search_inst pc_branch[30]
load net core_inst|pc_branch[3] -attr @rip pc_branch[2] -attr @name pc_branch[3] -pin core_inst|execution_inst pc_branch[2] -pin core_inst|search_inst pc_branch[2]
load net core_inst|pc_branch[4] -attr @rip pc_branch[3] -attr @name pc_branch[4] -pin core_inst|execution_inst pc_branch[3] -pin core_inst|search_inst pc_branch[3]
load net core_inst|pc_branch[5] -attr @rip pc_branch[4] -attr @name pc_branch[5] -pin core_inst|execution_inst pc_branch[4] -pin core_inst|search_inst pc_branch[4]
load net core_inst|pc_branch[6] -attr @rip pc_branch[5] -attr @name pc_branch[6] -pin core_inst|execution_inst pc_branch[5] -pin core_inst|search_inst pc_branch[5]
load net core_inst|pc_branch[7] -attr @rip pc_branch[6] -attr @name pc_branch[7] -pin core_inst|execution_inst pc_branch[6] -pin core_inst|search_inst pc_branch[6]
load net core_inst|pc_branch[8] -attr @rip pc_branch[7] -attr @name pc_branch[8] -pin core_inst|execution_inst pc_branch[7] -pin core_inst|search_inst pc_branch[7]
load net core_inst|pc_branch[9] -attr @rip pc_branch[8] -attr @name pc_branch[9] -pin core_inst|execution_inst pc_branch[8] -pin core_inst|search_inst pc_branch[8]
load net core_inst|pc_next_carry__0_i_1 -attr @rip 0 -attr @name pc_next_carry__0_i_1 -hierPin core_inst pc_next_carry__0_i_1 -pin core_inst|decoder_inst register_file_reg_r1_0_31_0_5_i_54_0 -pin core_inst|search_inst pc_next_carry__0_i_1_0[0]
load net core_inst|pc_next_carry__0_i_1_0 -attr @rip 3 -attr @name pc_next_carry__0_i_1_0 -hierPin core_inst pc_next_carry__0_i_1_0 -pin core_inst|search_inst pc_next_carry__0_i_1_0[3]
load net core_inst|pc_next_carry__0_i_1_1 -attr @rip 2 -attr @name pc_next_carry__0_i_1_1 -hierPin core_inst pc_next_carry__0_i_1_1 -pin core_inst|search_inst pc_next_carry__0_i_1_0[2]
load net core_inst|pc_next_carry__0_i_1_2 -attr @rip 1 -attr @name pc_next_carry__0_i_1_2 -hierPin core_inst pc_next_carry__0_i_1_2 -pin core_inst|search_inst pc_next_carry__0_i_1_0[1]
load net core_inst|pc_next_carry__0_i_2_n_0_repN_1_alias -attr @name pc_next_carry__0_i_2_n_0_repN_1_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_1_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_1_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_1_alias 1 0 3 NJ 3048 NJ 3048 3350
load net core_inst|pc_next_carry__0_i_2_n_0_repN_2_alias -attr @name pc_next_carry__0_i_2_n_0_repN_2_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_2_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_2_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_2_alias 1 0 3 NJ 3068 NJ 3068 3710
load net core_inst|pc_next_carry__0_i_2_n_0_repN_3_alias -attr @name pc_next_carry__0_i_2_n_0_repN_3_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_3_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_3_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_3_alias 1 0 3 NJ 3088 NJ 3088 3690
load net core_inst|pc_next_carry__0_i_2_n_0_repN_4_alias -attr @name pc_next_carry__0_i_2_n_0_repN_4_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_4_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_4_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_4_alias 1 0 3 NJ 3108 NJ 3108 3670
load net core_inst|pc_next_carry__0_i_2_n_0_repN_5_alias -attr @name pc_next_carry__0_i_2_n_0_repN_5_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_5_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_5_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_5_alias 1 0 3 NJ 3128 NJ 3128 3130
load net core_inst|pc_next_carry__0_i_2_n_0_repN_6_alias -attr @name pc_next_carry__0_i_2_n_0_repN_6_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_6_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_6_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_6_alias 1 0 3 NJ 3148 NJ 3148 3390
load net core_inst|pc_next_carry__0_i_2_n_0_repN_7_alias -attr @name pc_next_carry__0_i_2_n_0_repN_7_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_7_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_7_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_7_alias 1 0 3 NJ 3168 NJ 3168 3650
load net core_inst|pc_next_carry__0_i_2_n_0_repN_8_alias -attr @name pc_next_carry__0_i_2_n_0_repN_8_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_8_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_8_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_8_alias 1 0 3 NJ 3188 NJ 3188 3630
load net core_inst|pc_next_carry__0_i_2_n_0_repN_alias -attr @name pc_next_carry__0_i_2_n_0_repN_alias -hierPin core_inst pc_next_carry__0_i_2_n_0_repN_alias -pin core_inst|search_inst pc_next_carry__0_i_2_n_0_repN_alias
netloc core_inst|pc_next_carry__0_i_2_n_0_repN_alias 1 0 3 NJ 3028 NJ 3028 3730
load net core_inst|pc_next_carry__0_i_3_n_0_repN_1_alias -attr @name pc_next_carry__0_i_3_n_0_repN_1_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_1_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_1_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_1_alias 1 0 3 NJ 3228 NJ 3228 3590
load net core_inst|pc_next_carry__0_i_3_n_0_repN_2_alias -attr @name pc_next_carry__0_i_3_n_0_repN_2_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_2_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_2_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_2_alias 1 0 3 NJ 3248 NJ 3248 3210
load net core_inst|pc_next_carry__0_i_3_n_0_repN_3_alias -attr @name pc_next_carry__0_i_3_n_0_repN_3_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_3_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_3_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_3_alias 1 0 3 NJ 3268 NJ 3268 3570
load net core_inst|pc_next_carry__0_i_3_n_0_repN_4_alias -attr @name pc_next_carry__0_i_3_n_0_repN_4_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_4_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_4_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_4_alias 1 0 3 NJ 3288 NJ 3288 3550
load net core_inst|pc_next_carry__0_i_3_n_0_repN_5_alias -attr @name pc_next_carry__0_i_3_n_0_repN_5_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_5_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_5_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_5_alias 1 0 3 NJ 3308 NJ 3308 3290
load net core_inst|pc_next_carry__0_i_3_n_0_repN_6_alias -attr @name pc_next_carry__0_i_3_n_0_repN_6_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_6_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_6_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_6_alias 1 0 3 NJ 3328 NJ 3328 3530
load net core_inst|pc_next_carry__0_i_3_n_0_repN_7_alias -attr @name pc_next_carry__0_i_3_n_0_repN_7_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_7_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_7_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_7_alias 1 0 3 NJ 3348 NJ 3348 3510
load net core_inst|pc_next_carry__0_i_3_n_0_repN_alias -attr @name pc_next_carry__0_i_3_n_0_repN_alias -hierPin core_inst pc_next_carry__0_i_3_n_0_repN_alias -pin core_inst|search_inst pc_next_carry__0_i_3_n_0_repN_alias
netloc core_inst|pc_next_carry__0_i_3_n_0_repN_alias 1 0 3 NJ 3208 NJ 3208 3610
load net core_inst|pc_next_carry_i_2 -attr @rip 0 -attr @name pc_next_carry_i_2 -hierPin core_inst pc_next_carry_i_2 -pin core_inst|decoder_inst register_file_reg_r1_0_31_0_5_i_54 -pin core_inst|search_inst S[0]
load net core_inst|pc_next_carry_i_2_0 -attr @rip 1 -attr @name pc_next_carry_i_2_0 -hierPin core_inst pc_next_carry_i_2_0 -pin core_inst|search_inst S[1]
load net core_inst|pc_next_carry_i_2_1 -attr @name pc_next_carry_i_2_1 -hierPin core_inst pc_next_carry_i_2_1 -pin core_inst|search_inst pc_next_carry_i_2
netloc core_inst|pc_next_carry_i_2_1 1 0 3 1810J 3628 NJ 3628 N
load net core_inst|pc_next_carry_i_2_n_0_repN_1_alias -attr @name pc_next_carry_i_2_n_0_repN_1_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_1_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_1_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_1_alias 1 0 3 NJ 4368 2510J 4408 3530
load net core_inst|pc_next_carry_i_2_n_0_repN_2_alias -attr @name pc_next_carry_i_2_n_0_repN_2_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_2_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_2_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_2_alias 1 0 3 NJ 4388 2490J 4428 3550
load net core_inst|pc_next_carry_i_2_n_0_repN_3_alias -attr @name pc_next_carry_i_2_n_0_repN_3_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_3_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_3_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_3_alias 1 0 3 NJ 4408 2450J 4448 3570
load net core_inst|pc_next_carry_i_2_n_0_repN_4_alias -attr @name pc_next_carry_i_2_n_0_repN_4_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_4_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_4_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_4_alias 1 0 3 NJ 4428 2430J 4468 3590
load net core_inst|pc_next_carry_i_2_n_0_repN_5_alias -attr @name pc_next_carry_i_2_n_0_repN_5_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_5_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_5_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_5_alias 1 0 3 NJ 4448 2410J 4488 3610
load net core_inst|pc_next_carry_i_2_n_0_repN_6_alias -attr @name pc_next_carry_i_2_n_0_repN_6_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_6_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_6_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_6_alias 1 0 3 NJ 4468 2390J 4508 3630
load net core_inst|pc_next_carry_i_2_n_0_repN_7_alias -attr @name pc_next_carry_i_2_n_0_repN_7_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_7_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_7_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_7_alias 1 0 3 NJ 4488 2370J 4528 3670
load net core_inst|pc_next_carry_i_2_n_0_repN_alias -attr @name pc_next_carry_i_2_n_0_repN_alias -hierPin core_inst pc_next_carry_i_2_n_0_repN_alias -pin core_inst|search_inst pc_next_carry_i_2_n_0_repN_alias
netloc core_inst|pc_next_carry_i_2_n_0_repN_alias 1 0 3 NJ 3388 NJ 3388 3090
load net core_inst|pc_next_carry_i_3_n_0_repN_10_alias -attr @name pc_next_carry_i_3_n_0_repN_10_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_10_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_10_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_10_alias 1 0 3 NJ 4748 NJ 4748 3210
load net core_inst|pc_next_carry_i_3_n_0_repN_11_alias -attr @name pc_next_carry_i_3_n_0_repN_11_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_11_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_11_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_11_alias 1 0 3 NJ 4768 NJ 4768 3230
load net core_inst|pc_next_carry_i_3_n_0_repN_12_alias -attr @name pc_next_carry_i_3_n_0_repN_12_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_12_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_12_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_12_alias 1 0 3 NJ 4788 NJ 4788 3250
load net core_inst|pc_next_carry_i_3_n_0_repN_1_alias -attr @name pc_next_carry_i_3_n_0_repN_1_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_1_alias -pin core_inst|decoder_inst pc_next_carry_i_3_n_0_repN_1_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_1_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_1_alias 1 0 3 1870 4568 NJ 4568 3750
load net core_inst|pc_next_carry_i_3_n_0_repN_2_alias -attr @name pc_next_carry_i_3_n_0_repN_2_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_2_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_2_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_2_alias 1 0 3 NJ 4588 NJ 4588 3790
load net core_inst|pc_next_carry_i_3_n_0_repN_3_alias -attr @name pc_next_carry_i_3_n_0_repN_3_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_3_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_3_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_3_alias 1 0 3 NJ 4608 NJ 4608 3850
load net core_inst|pc_next_carry_i_3_n_0_repN_4_alias -attr @name pc_next_carry_i_3_n_0_repN_4_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_4_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_4_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_4_alias 1 0 3 NJ 4628 NJ 4628 3890
load net core_inst|pc_next_carry_i_3_n_0_repN_5_alias -attr @name pc_next_carry_i_3_n_0_repN_5_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_5_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_5_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_5_alias 1 0 3 NJ 4648 NJ 4648 3110
load net core_inst|pc_next_carry_i_3_n_0_repN_6_alias -attr @name pc_next_carry_i_3_n_0_repN_6_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_6_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_6_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_6_alias 1 0 3 NJ 4668 NJ 4668 3030
load net core_inst|pc_next_carry_i_3_n_0_repN_7_alias -attr @name pc_next_carry_i_3_n_0_repN_7_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_7_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_7_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_7_alias 1 0 3 NJ 4688 NJ 4688 3130
load net core_inst|pc_next_carry_i_3_n_0_repN_8_alias -attr @name pc_next_carry_i_3_n_0_repN_8_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_8_alias -pin core_inst|decoder_inst pc_next_carry_i_3_n_0_repN_8_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_8_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_8_alias 1 0 3 1890 4708 NJ 4708 3150
load net core_inst|pc_next_carry_i_3_n_0_repN_9_alias -attr @name pc_next_carry_i_3_n_0_repN_9_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_9_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_9_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_9_alias 1 0 3 NJ 4728 NJ 4728 3190
load net core_inst|pc_next_carry_i_3_n_0_repN_alias -attr @name pc_next_carry_i_3_n_0_repN_alias -hierPin core_inst pc_next_carry_i_3_n_0_repN_alias -pin core_inst|decoder_inst pc_next_carry_i_3_n_0_repN_alias -pin core_inst|search_inst pc_next_carry_i_3_n_0_repN_alias
netloc core_inst|pc_next_carry_i_3_n_0_repN_alias 1 0 3 1850 4548 NJ 4548 3710
load net core_inst|pc_reg_reg[12][0] -attr @rip pc_reg_reg[12]_0[0] -attr @name pc_reg_reg[12][0] -hierPin core_inst pc_reg_reg[12][0] -pin core_inst|search_inst pc_reg_reg[12]_0[0]
load net core_inst|pc_reg_reg[12][1] -attr @rip pc_reg_reg[12]_0[1] -attr @name pc_reg_reg[12][1] -hierPin core_inst pc_reg_reg[12][1] -pin core_inst|search_inst pc_reg_reg[12]_0[1]
load net core_inst|pc_reg_reg[12][2] -attr @rip pc_reg_reg[12]_0[2] -attr @name pc_reg_reg[12][2] -hierPin core_inst pc_reg_reg[12][2] -pin core_inst|search_inst pc_reg_reg[12]_0[2]
load net core_inst|pc_reg_reg[12][3] -attr @rip pc_reg_reg[12]_0[3] -attr @name pc_reg_reg[12][3] -hierPin core_inst pc_reg_reg[12][3] -pin core_inst|search_inst pc_reg_reg[12]_0[3]
load net core_inst|pc_reg_reg[12][4] -attr @rip pc_reg_reg[12]_0[4] -attr @name pc_reg_reg[12][4] -hierPin core_inst pc_reg_reg[12][4] -pin core_inst|search_inst pc_reg_reg[12]_0[4]
load net core_inst|pc_reg_reg[12][5] -attr @rip pc_reg_reg[12]_0[5] -attr @name pc_reg_reg[12][5] -hierPin core_inst pc_reg_reg[12][5] -pin core_inst|search_inst pc_reg_reg[12]_0[5]
load net core_inst|pc_reg_reg[12][6] -attr @rip pc_reg_reg[12]_0[6] -attr @name pc_reg_reg[12][6] -hierPin core_inst pc_reg_reg[12][6] -pin core_inst|search_inst pc_reg_reg[12]_0[6]
load net core_inst|pc_reg_reg[12][7] -attr @rip pc_reg_reg[12]_0[7] -attr @name pc_reg_reg[12][7] -hierPin core_inst pc_reg_reg[12][7] -pin core_inst|search_inst pc_reg_reg[12]_0[7]
load net core_inst|pc_reg_reg[12][8] -attr @rip pc_reg_reg[12]_0[8] -attr @name pc_reg_reg[12][8] -hierPin core_inst pc_reg_reg[12][8] -pin core_inst|search_inst pc_reg_reg[12]_0[8]
load net core_inst|pc_reg_reg[12]_0 -attr @rip 1 -attr @name pc_reg_reg[12]_0 -hierPin core_inst pc_reg_reg[12]_0 -pin core_inst|search_inst pc_reg_reg[12]_1[1]
load net core_inst|pc_reg_reg[12]_1 -attr @rip 0 -attr @name pc_reg_reg[12]_1 -hierPin core_inst pc_reg_reg[12]_1 -pin core_inst|search_inst pc_reg_reg[12]_1[0]
load net core_inst|pmod_col_o0 -attr @rip led_o[7]_i_3_0[0] -attr @name pmod_col_o0 -pin core_inst|data_memory_inst pmod_col_o_reg[3]_2[0] -pin core_inst|search_inst led_o[7]_i_3_0[0]
netloc core_inst|pmod_col_o0 1 3 1 5080 3008n
load net core_inst|pmod_col_o_reg[3][0] -attr @rip pmod_col_o_reg[3]_0[0] -attr @name pmod_col_o_reg[3][0] -hierPin core_inst pmod_col_o_reg[3][0] -pin core_inst|data_memory_inst pmod_col_o_reg[3]_0[0]
load net core_inst|pmod_col_o_reg[3][1] -attr @rip pmod_col_o_reg[3]_0[1] -attr @name pmod_col_o_reg[3][1] -hierPin core_inst pmod_col_o_reg[3][1] -pin core_inst|data_memory_inst pmod_col_o_reg[3]_0[1]
load net core_inst|pmod_col_o_reg[3][2] -attr @rip pmod_col_o_reg[3]_0[2] -attr @name pmod_col_o_reg[3][2] -hierPin core_inst pmod_col_o_reg[3][2] -pin core_inst|data_memory_inst pmod_col_o_reg[3]_0[2]
load net core_inst|pmod_col_o_reg[3][3] -attr @rip pmod_col_o_reg[3]_0[3] -attr @name pmod_col_o_reg[3][3] -hierPin core_inst pmod_col_o_reg[3][3] -pin core_inst|data_memory_inst pmod_col_o_reg[3]_0[3]
load net core_inst|ram_word_data0[10] -attr @rip mem_reg_0_255_31_31_0[8] -attr @name ram_word_data0[10] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[8] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[8]
load net core_inst|ram_word_data0[11] -attr @rip mem_reg_0_255_31_31_0[9] -attr @name ram_word_data0[11] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[9] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[9]
load net core_inst|ram_word_data0[12] -attr @rip mem_reg_0_255_31_31_0[10] -attr @name ram_word_data0[12] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[10] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[10]
load net core_inst|ram_word_data0[13] -attr @rip mem_reg_0_255_31_31_0[11] -attr @name ram_word_data0[13] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[11] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[11]
load net core_inst|ram_word_data0[14] -attr @rip mem_reg_0_255_31_31_0[12] -attr @name ram_word_data0[14] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[12] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[12]
load net core_inst|ram_word_data0[15] -attr @rip mem_reg_0_255_31_31_0[13] -attr @name ram_word_data0[15] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[13] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[13]
load net core_inst|ram_word_data0[16] -attr @rip mem_reg_0_255_31_31_0[14] -attr @name ram_word_data0[16] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[14] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[14]
load net core_inst|ram_word_data0[17] -attr @rip mem_reg_0_255_31_31_0[15] -attr @name ram_word_data0[17] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[15] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[15]
load net core_inst|ram_word_data0[18] -attr @rip mem_reg_0_255_31_31_0[16] -attr @name ram_word_data0[18] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[16] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[16]
load net core_inst|ram_word_data0[19] -attr @rip mem_reg_0_255_31_31_0[17] -attr @name ram_word_data0[19] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[17] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[17]
load net core_inst|ram_word_data0[1] -attr @rip mem_reg_0_255_31_31_0[0] -attr @name ram_word_data0[1] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[0] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[0]
load net core_inst|ram_word_data0[20] -attr @rip mem_reg_0_255_31_31_0[18] -attr @name ram_word_data0[20] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[18] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[18]
load net core_inst|ram_word_data0[21] -attr @rip mem_reg_0_255_31_31_0[19] -attr @name ram_word_data0[21] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[19] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[19]
load net core_inst|ram_word_data0[22] -attr @rip mem_reg_0_255_31_31_0[20] -attr @name ram_word_data0[22] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[20] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[20]
load net core_inst|ram_word_data0[23] -attr @rip mem_reg_0_255_31_31_0[21] -attr @name ram_word_data0[23] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[21] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[21]
load net core_inst|ram_word_data0[24] -attr @rip mem_reg_0_255_31_31_0[22] -attr @name ram_word_data0[24] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[22] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[22]
load net core_inst|ram_word_data0[25] -attr @rip mem_reg_0_255_31_31_0[23] -attr @name ram_word_data0[25] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[23] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[23]
load net core_inst|ram_word_data0[26] -attr @rip mem_reg_0_255_31_31_0[24] -attr @name ram_word_data0[26] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[24] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[24]
load net core_inst|ram_word_data0[27] -attr @rip mem_reg_0_255_31_31_0[25] -attr @name ram_word_data0[27] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[25] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[25]
load net core_inst|ram_word_data0[28] -attr @rip mem_reg_0_255_31_31_0[26] -attr @name ram_word_data0[28] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[26] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[26]
load net core_inst|ram_word_data0[29] -attr @rip mem_reg_0_255_31_31_0[27] -attr @name ram_word_data0[29] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[27] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[27]
load net core_inst|ram_word_data0[2] -attr @rip mem_reg_0_255_31_31_0[1] -attr @name ram_word_data0[2] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[1] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[1]
load net core_inst|ram_word_data0[30] -attr @rip mem_reg_0_255_31_31_0[28] -attr @name ram_word_data0[30] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[28] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[28]
load net core_inst|ram_word_data0[31] -attr @rip mem_reg_0_255_31_31_0[29] -attr @name ram_word_data0[31] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[29] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[29]
load net core_inst|ram_word_data0[3] -attr @rip mem_reg_0_255_31_31_0[2] -attr @name ram_word_data0[3] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[2] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[2]
load net core_inst|ram_word_data0[5] -attr @rip mem_reg_0_255_31_31_0[3] -attr @name ram_word_data0[5] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[3] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[3]
load net core_inst|ram_word_data0[6] -attr @rip mem_reg_0_255_31_31_0[4] -attr @name ram_word_data0[6] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[4] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[4]
load net core_inst|ram_word_data0[7] -attr @rip mem_reg_0_255_31_31_0[5] -attr @name ram_word_data0[7] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[5] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[5]
load net core_inst|ram_word_data0[8] -attr @rip mem_reg_0_255_31_31_0[6] -attr @name ram_word_data0[8] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[6] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[6]
load net core_inst|ram_word_data0[9] -attr @rip mem_reg_0_255_31_31_0[7] -attr @name ram_word_data0[9] -pin core_inst|data_memory_inst mem_reg_0_255_31_31_0[7] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_21_0[7]
load net core_inst|reset_i -attr @name reset_i -hierPin core_inst reset_i -pin core_inst|search_inst CPU_RESETN
netloc core_inst|reset_i 1 3 2 5420 4688 NJ
load net core_inst|rs1_o0[0] -attr @rip rs1_o0[0] -attr @name rs1_o0[0] -pin core_inst|decoder_inst rs1_o0[0] -pin core_inst|search_inst rs1_o0[0]
load net core_inst|rs1_o0[10] -attr @rip rs1_o0[10] -attr @name rs1_o0[10] -pin core_inst|decoder_inst rs1_o0[10] -pin core_inst|search_inst rs1_o0[10]
load net core_inst|rs1_o0[11] -attr @rip rs1_o0[11] -attr @name rs1_o0[11] -pin core_inst|decoder_inst rs1_o0[11] -pin core_inst|search_inst rs1_o0[11]
load net core_inst|rs1_o0[12] -attr @rip rs1_o0[12] -attr @name rs1_o0[12] -pin core_inst|decoder_inst rs1_o0[12] -pin core_inst|search_inst rs1_o0[12]
load net core_inst|rs1_o0[13] -attr @rip rs1_o0[13] -attr @name rs1_o0[13] -pin core_inst|decoder_inst rs1_o0[13] -pin core_inst|search_inst rs1_o0[13]
load net core_inst|rs1_o0[14] -attr @rip rs1_o0[14] -attr @name rs1_o0[14] -pin core_inst|decoder_inst rs1_o0[14] -pin core_inst|search_inst rs1_o0[14]
load net core_inst|rs1_o0[15] -attr @rip rs1_o0[15] -attr @name rs1_o0[15] -pin core_inst|decoder_inst rs1_o0[15] -pin core_inst|search_inst rs1_o0[15]
load net core_inst|rs1_o0[16] -attr @rip rs1_o0[16] -attr @name rs1_o0[16] -pin core_inst|decoder_inst rs1_o0[16] -pin core_inst|search_inst rs1_o0[16]
load net core_inst|rs1_o0[17] -attr @rip rs1_o0[17] -attr @name rs1_o0[17] -pin core_inst|decoder_inst rs1_o0[17] -pin core_inst|search_inst rs1_o0[17]
load net core_inst|rs1_o0[18] -attr @rip rs1_o0[18] -attr @name rs1_o0[18] -pin core_inst|decoder_inst rs1_o0[18] -pin core_inst|search_inst rs1_o0[18]
load net core_inst|rs1_o0[19] -attr @rip rs1_o0[19] -attr @name rs1_o0[19] -pin core_inst|decoder_inst rs1_o0[19] -pin core_inst|search_inst rs1_o0[19]
load net core_inst|rs1_o0[1] -attr @rip rs1_o0[1] -attr @name rs1_o0[1] -pin core_inst|decoder_inst rs1_o0[1] -pin core_inst|search_inst rs1_o0[1]
load net core_inst|rs1_o0[20] -attr @rip rs1_o0[20] -attr @name rs1_o0[20] -pin core_inst|decoder_inst rs1_o0[20] -pin core_inst|search_inst rs1_o0[20]
load net core_inst|rs1_o0[21] -attr @rip rs1_o0[21] -attr @name rs1_o0[21] -pin core_inst|decoder_inst rs1_o0[21] -pin core_inst|search_inst rs1_o0[21]
load net core_inst|rs1_o0[22] -attr @rip rs1_o0[22] -attr @name rs1_o0[22] -pin core_inst|decoder_inst rs1_o0[22] -pin core_inst|search_inst rs1_o0[22]
load net core_inst|rs1_o0[23] -attr @rip rs1_o0[23] -attr @name rs1_o0[23] -pin core_inst|decoder_inst rs1_o0[23] -pin core_inst|search_inst rs1_o0[23]
load net core_inst|rs1_o0[24] -attr @rip rs1_o0[24] -attr @name rs1_o0[24] -pin core_inst|decoder_inst rs1_o0[24] -pin core_inst|search_inst rs1_o0[24]
load net core_inst|rs1_o0[25] -attr @rip rs1_o0[25] -attr @name rs1_o0[25] -pin core_inst|decoder_inst rs1_o0[25] -pin core_inst|search_inst rs1_o0[25]
load net core_inst|rs1_o0[26] -attr @rip rs1_o0[26] -attr @name rs1_o0[26] -pin core_inst|decoder_inst rs1_o0[26] -pin core_inst|search_inst rs1_o0[26]
load net core_inst|rs1_o0[27] -attr @rip rs1_o0[27] -attr @name rs1_o0[27] -pin core_inst|decoder_inst rs1_o0[27] -pin core_inst|search_inst rs1_o0[27]
load net core_inst|rs1_o0[28] -attr @rip rs1_o0[28] -attr @name rs1_o0[28] -pin core_inst|decoder_inst rs1_o0[28] -pin core_inst|execution_inst rs1_o0[0] -pin core_inst|search_inst rs1_o0[28]
load net core_inst|rs1_o0[29] -attr @rip rs1_o0[29] -attr @name rs1_o0[29] -pin core_inst|decoder_inst rs1_o0[29] -pin core_inst|execution_inst rs1_o0[1] -pin core_inst|search_inst rs1_o0[29]
load net core_inst|rs1_o0[2] -attr @rip rs1_o0[2] -attr @name rs1_o0[2] -pin core_inst|decoder_inst rs1_o0[2] -pin core_inst|search_inst rs1_o0[2]
load net core_inst|rs1_o0[30] -attr @rip rs1_o0[30] -attr @name rs1_o0[30] -pin core_inst|decoder_inst rs1_o0[30] -pin core_inst|execution_inst rs1_o0[2] -pin core_inst|search_inst rs1_o0[30]
load net core_inst|rs1_o0[31] -attr @rip rs1_o0[31] -attr @name rs1_o0[31] -pin core_inst|decoder_inst rs1_o0[31] -pin core_inst|search_inst rs1_o0[31]
load net core_inst|rs1_o0[3] -attr @rip rs1_o0[3] -attr @name rs1_o0[3] -pin core_inst|decoder_inst rs1_o0[3] -pin core_inst|search_inst rs1_o0[3]
load net core_inst|rs1_o0[4] -attr @rip rs1_o0[4] -attr @name rs1_o0[4] -pin core_inst|decoder_inst rs1_o0[4] -pin core_inst|search_inst rs1_o0[4]
load net core_inst|rs1_o0[5] -attr @rip rs1_o0[5] -attr @name rs1_o0[5] -pin core_inst|decoder_inst rs1_o0[5] -pin core_inst|search_inst rs1_o0[5]
load net core_inst|rs1_o0[6] -attr @rip rs1_o0[6] -attr @name rs1_o0[6] -pin core_inst|decoder_inst rs1_o0[6] -pin core_inst|search_inst rs1_o0[6]
load net core_inst|rs1_o0[7] -attr @rip rs1_o0[7] -attr @name rs1_o0[7] -pin core_inst|decoder_inst rs1_o0[7] -pin core_inst|search_inst rs1_o0[7]
load net core_inst|rs1_o0[8] -attr @rip rs1_o0[8] -attr @name rs1_o0[8] -pin core_inst|decoder_inst rs1_o0[8] -pin core_inst|search_inst rs1_o0[8]
load net core_inst|rs1_o0[9] -attr @rip rs1_o0[9] -attr @name rs1_o0[9] -pin core_inst|decoder_inst rs1_o0[9] -pin core_inst|search_inst rs1_o0[9]
load net core_inst|rs2_data[10] -attr @rip rs2_data[5] -attr @name rs2_data[10] -pin core_inst|decoder_inst rs2_data[5] -pin core_inst|search_inst pc_reg[31]_i_21[5]
load net core_inst|rs2_data[11] -attr @rip rs2_data[6] -attr @name rs2_data[11] -pin core_inst|decoder_inst rs2_data[6] -pin core_inst|search_inst pc_reg[31]_i_21[6]
load net core_inst|rs2_data[12] -attr @rip rs2_data[7] -attr @name rs2_data[12] -pin core_inst|decoder_inst rs2_data[7] -pin core_inst|search_inst pc_reg[31]_i_21[7]
load net core_inst|rs2_data[13] -attr @rip rs2_data[8] -attr @name rs2_data[13] -pin core_inst|decoder_inst rs2_data[8] -pin core_inst|search_inst pc_reg[31]_i_21[8]
load net core_inst|rs2_data[14] -attr @rip rs2_data[9] -attr @name rs2_data[14] -pin core_inst|decoder_inst rs2_data[9] -pin core_inst|search_inst pc_reg[31]_i_21[9]
load net core_inst|rs2_data[15] -attr @rip rs2_data[10] -attr @name rs2_data[15] -pin core_inst|decoder_inst rs2_data[10] -pin core_inst|search_inst pc_reg[31]_i_21[10]
load net core_inst|rs2_data[16] -attr @rip rs2_data[11] -attr @name rs2_data[16] -pin core_inst|decoder_inst rs2_data[11] -pin core_inst|search_inst pc_reg[31]_i_21[11]
load net core_inst|rs2_data[17] -attr @rip rs2_data[12] -attr @name rs2_data[17] -pin core_inst|decoder_inst rs2_data[12] -pin core_inst|search_inst pc_reg[31]_i_21[12]
load net core_inst|rs2_data[18] -attr @rip rs2_data[13] -attr @name rs2_data[18] -pin core_inst|decoder_inst rs2_data[13] -pin core_inst|search_inst pc_reg[31]_i_21[13]
load net core_inst|rs2_data[19] -attr @rip rs2_data[14] -attr @name rs2_data[19] -pin core_inst|decoder_inst rs2_data[14] -pin core_inst|search_inst pc_reg[31]_i_21[14]
load net core_inst|rs2_data[20] -attr @rip rs2_data[15] -attr @name rs2_data[20] -pin core_inst|decoder_inst rs2_data[15] -pin core_inst|search_inst pc_reg[31]_i_21[15]
load net core_inst|rs2_data[21] -attr @rip rs2_data[16] -attr @name rs2_data[21] -pin core_inst|decoder_inst rs2_data[16] -pin core_inst|search_inst pc_reg[31]_i_21[16]
load net core_inst|rs2_data[22] -attr @rip rs2_data[17] -attr @name rs2_data[22] -pin core_inst|decoder_inst rs2_data[17] -pin core_inst|search_inst pc_reg[31]_i_21[17]
load net core_inst|rs2_data[23] -attr @rip rs2_data[18] -attr @name rs2_data[23] -pin core_inst|decoder_inst rs2_data[18] -pin core_inst|search_inst pc_reg[31]_i_21[18]
load net core_inst|rs2_data[24] -attr @rip rs2_data[19] -attr @name rs2_data[24] -pin core_inst|decoder_inst rs2_data[19] -pin core_inst|search_inst pc_reg[31]_i_21[19]
load net core_inst|rs2_data[25] -attr @rip rs2_data[20] -attr @name rs2_data[25] -pin core_inst|decoder_inst rs2_data[20] -pin core_inst|search_inst pc_reg[31]_i_21[20]
load net core_inst|rs2_data[26] -attr @rip rs2_data[21] -attr @name rs2_data[26] -pin core_inst|decoder_inst rs2_data[21] -pin core_inst|search_inst pc_reg[31]_i_21[21]
load net core_inst|rs2_data[27] -attr @rip rs2_data[22] -attr @name rs2_data[27] -pin core_inst|decoder_inst rs2_data[22] -pin core_inst|search_inst pc_reg[31]_i_21[22]
load net core_inst|rs2_data[28] -attr @rip rs2_data[23] -attr @name rs2_data[28] -pin core_inst|decoder_inst rs2_data[23] -pin core_inst|search_inst pc_reg[31]_i_21[23]
load net core_inst|rs2_data[29] -attr @rip rs2_data[24] -attr @name rs2_data[29] -pin core_inst|decoder_inst rs2_data[24] -pin core_inst|search_inst pc_reg[31]_i_21[24]
load net core_inst|rs2_data[30] -attr @rip rs2_data[25] -attr @name rs2_data[30] -pin core_inst|decoder_inst rs2_data[25] -pin core_inst|search_inst pc_reg[31]_i_21[25]
load net core_inst|rs2_data[31] -attr @rip rs2_data[26] -attr @name rs2_data[31] -pin core_inst|decoder_inst rs2_data[26] -pin core_inst|search_inst pc_reg[31]_i_21[26]
load net core_inst|rs2_data[5] -attr @rip rs2_data[0] -attr @name rs2_data[5] -pin core_inst|decoder_inst rs2_data[0] -pin core_inst|search_inst pc_reg[31]_i_21[0]
load net core_inst|rs2_data[6] -attr @rip rs2_data[1] -attr @name rs2_data[6] -pin core_inst|decoder_inst rs2_data[1] -pin core_inst|search_inst pc_reg[31]_i_21[1]
load net core_inst|rs2_data[7] -attr @rip rs2_data[2] -attr @name rs2_data[7] -pin core_inst|decoder_inst rs2_data[2] -pin core_inst|search_inst pc_reg[31]_i_21[2]
load net core_inst|rs2_data[8] -attr @rip rs2_data[3] -attr @name rs2_data[8] -pin core_inst|decoder_inst rs2_data[3] -pin core_inst|search_inst pc_reg[31]_i_21[3]
load net core_inst|rs2_data[9] -attr @rip rs2_data[4] -attr @name rs2_data[9] -pin core_inst|decoder_inst rs2_data[4] -pin core_inst|search_inst pc_reg[31]_i_21[4]
load net core_inst|rs2_o0[0] -attr @rip rs2_o0[0] -attr @name rs2_o0[0] -pin core_inst|decoder_inst rs2_o0[0] -pin core_inst|search_inst rs2_o0[0]
load net core_inst|rs2_o0[10] -attr @rip rs2_o0[10] -attr @name rs2_o0[10] -pin core_inst|decoder_inst rs2_o0[10] -pin core_inst|search_inst rs2_o0[10]
load net core_inst|rs2_o0[11] -attr @rip rs2_o0[11] -attr @name rs2_o0[11] -pin core_inst|decoder_inst rs2_o0[11] -pin core_inst|search_inst rs2_o0[11]
load net core_inst|rs2_o0[12] -attr @rip rs2_o0[12] -attr @name rs2_o0[12] -pin core_inst|decoder_inst rs2_o0[12] -pin core_inst|search_inst rs2_o0[12]
load net core_inst|rs2_o0[13] -attr @rip rs2_o0[13] -attr @name rs2_o0[13] -pin core_inst|decoder_inst rs2_o0[13] -pin core_inst|search_inst rs2_o0[13]
load net core_inst|rs2_o0[14] -attr @rip rs2_o0[14] -attr @name rs2_o0[14] -pin core_inst|decoder_inst rs2_o0[14] -pin core_inst|search_inst rs2_o0[14]
load net core_inst|rs2_o0[15] -attr @rip rs2_o0[15] -attr @name rs2_o0[15] -pin core_inst|decoder_inst rs2_o0[15] -pin core_inst|search_inst rs2_o0[15]
load net core_inst|rs2_o0[16] -attr @rip rs2_o0[16] -attr @name rs2_o0[16] -pin core_inst|decoder_inst rs2_o0[16] -pin core_inst|search_inst rs2_o0[16]
load net core_inst|rs2_o0[17] -attr @rip rs2_o0[17] -attr @name rs2_o0[17] -pin core_inst|decoder_inst rs2_o0[17] -pin core_inst|search_inst rs2_o0[17]
load net core_inst|rs2_o0[18] -attr @rip rs2_o0[18] -attr @name rs2_o0[18] -pin core_inst|decoder_inst rs2_o0[18] -pin core_inst|search_inst rs2_o0[18]
load net core_inst|rs2_o0[19] -attr @rip rs2_o0[19] -attr @name rs2_o0[19] -pin core_inst|decoder_inst rs2_o0[19] -pin core_inst|search_inst rs2_o0[19]
load net core_inst|rs2_o0[1] -attr @rip rs2_o0[1] -attr @name rs2_o0[1] -pin core_inst|decoder_inst rs2_o0[1] -pin core_inst|search_inst rs2_o0[1]
load net core_inst|rs2_o0[20] -attr @rip rs2_o0[20] -attr @name rs2_o0[20] -pin core_inst|decoder_inst rs2_o0[20] -pin core_inst|search_inst rs2_o0[20]
load net core_inst|rs2_o0[21] -attr @rip rs2_o0[21] -attr @name rs2_o0[21] -pin core_inst|decoder_inst rs2_o0[21] -pin core_inst|search_inst rs2_o0[21]
load net core_inst|rs2_o0[22] -attr @rip rs2_o0[22] -attr @name rs2_o0[22] -pin core_inst|decoder_inst rs2_o0[22] -pin core_inst|search_inst rs2_o0[22]
load net core_inst|rs2_o0[23] -attr @rip rs2_o0[23] -attr @name rs2_o0[23] -pin core_inst|decoder_inst rs2_o0[23] -pin core_inst|search_inst rs2_o0[23]
load net core_inst|rs2_o0[24] -attr @rip rs2_o0[24] -attr @name rs2_o0[24] -pin core_inst|decoder_inst rs2_o0[24] -pin core_inst|search_inst rs2_o0[24]
load net core_inst|rs2_o0[25] -attr @rip rs2_o0[25] -attr @name rs2_o0[25] -pin core_inst|decoder_inst rs2_o0[25] -pin core_inst|search_inst rs2_o0[25]
load net core_inst|rs2_o0[26] -attr @rip rs2_o0[26] -attr @name rs2_o0[26] -pin core_inst|decoder_inst rs2_o0[26] -pin core_inst|search_inst rs2_o0[26]
load net core_inst|rs2_o0[27] -attr @rip rs2_o0[27] -attr @name rs2_o0[27] -pin core_inst|decoder_inst rs2_o0[27] -pin core_inst|search_inst rs2_o0[27]
load net core_inst|rs2_o0[28] -attr @rip rs2_o0[28] -attr @name rs2_o0[28] -pin core_inst|decoder_inst rs2_o0[28] -pin core_inst|search_inst rs2_o0[28]
load net core_inst|rs2_o0[29] -attr @rip rs2_o0[29] -attr @name rs2_o0[29] -pin core_inst|decoder_inst rs2_o0[29] -pin core_inst|search_inst rs2_o0[29]
load net core_inst|rs2_o0[2] -attr @rip rs2_o0[2] -attr @name rs2_o0[2] -pin core_inst|decoder_inst rs2_o0[2] -pin core_inst|search_inst rs2_o0[2]
load net core_inst|rs2_o0[30] -attr @rip rs2_o0[30] -attr @name rs2_o0[30] -pin core_inst|decoder_inst rs2_o0[30] -pin core_inst|search_inst rs2_o0[30]
load net core_inst|rs2_o0[31] -attr @rip rs2_o0[31] -attr @name rs2_o0[31] -pin core_inst|decoder_inst rs2_o0[31] -pin core_inst|search_inst rs2_o0[31]
load net core_inst|rs2_o0[3] -attr @rip rs2_o0[3] -attr @name rs2_o0[3] -pin core_inst|decoder_inst rs2_o0[3] -pin core_inst|search_inst rs2_o0[3]
load net core_inst|rs2_o0[4] -attr @rip rs2_o0[4] -attr @name rs2_o0[4] -pin core_inst|decoder_inst rs2_o0[4] -pin core_inst|search_inst rs2_o0[4]
load net core_inst|rs2_o0[5] -attr @rip rs2_o0[5] -attr @name rs2_o0[5] -pin core_inst|decoder_inst rs2_o0[5] -pin core_inst|search_inst rs2_o0[5]
load net core_inst|rs2_o0[6] -attr @rip rs2_o0[6] -attr @name rs2_o0[6] -pin core_inst|decoder_inst rs2_o0[6] -pin core_inst|search_inst rs2_o0[6]
load net core_inst|rs2_o0[7] -attr @rip rs2_o0[7] -attr @name rs2_o0[7] -pin core_inst|decoder_inst rs2_o0[7] -pin core_inst|search_inst rs2_o0[7]
load net core_inst|rs2_o0[8] -attr @rip rs2_o0[8] -attr @name rs2_o0[8] -pin core_inst|decoder_inst rs2_o0[8] -pin core_inst|search_inst rs2_o0[8]
load net core_inst|rs2_o0[9] -attr @rip rs2_o0[9] -attr @name rs2_o0[9] -pin core_inst|decoder_inst rs2_o0[9] -pin core_inst|search_inst rs2_o0[9]
load net core_inst|search_inst_n_120 -attr @name search_inst_n_120 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_24_2 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_21_0
netloc core_inst|search_inst_n_120 1 3 1 5040 3128n
load net core_inst|search_inst_n_121 -attr @name search_inst_n_121 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_24_1 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_0
netloc core_inst|search_inst_n_121 1 3 1 5280 3108n
load net core_inst|search_inst_n_122 -attr @name search_inst_n_122 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_24_3 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_1
netloc core_inst|search_inst_n_122 1 3 1 5380 3148n
load net core_inst|search_inst_n_123 -attr @name search_inst_n_123 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_24_0 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_2
netloc core_inst|search_inst_n_123 1 3 1 5300 3088n
load net core_inst|search_inst_n_124 -attr @rip A[2] -attr @name search_inst_n_124 -pin core_inst|data_memory_inst A[2] -pin core_inst|search_inst A[2]
load net core_inst|search_inst_n_125 -attr @rip A[1] -attr @name search_inst_n_125 -pin core_inst|data_memory_inst A[1] -pin core_inst|search_inst A[1]
load net core_inst|search_inst_n_126 -attr @rip A[0] -attr @name search_inst_n_126 -pin core_inst|data_memory_inst A[0] -pin core_inst|search_inst A[0]
load net core_inst|search_inst_n_127 -attr @name search_inst_n_127 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_18_23_i_11_0 -pin core_inst|search_inst led_o[15]_i_6_0
netloc core_inst|search_inst_n_127 1 3 1 4960 3048n
load net core_inst|search_inst_n_128 -attr @name search_inst_n_128 -pin core_inst|decoder_inst mem_reg_0_255_0_0_i_74 -pin core_inst|search_inst pc_next_carry__0_i_1
netloc core_inst|search_inst_n_128 1 0 4 1890 3508 NJ 3508 3150J 2688 4840
load net core_inst|search_inst_n_129 -attr @name search_inst_n_129 -pin core_inst|data_memory_inst seg7_o_reg[7]_0 -pin core_inst|search_inst led_o[15]_i_6_1
netloc core_inst|search_inst_n_129 1 3 1 5060 3068n
load net core_inst|search_inst_n_130 -attr @name search_inst_n_130 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_6_11_i_11_0 -pin core_inst|search_inst led_o[15]_i_6_2
netloc core_inst|search_inst_n_130 1 3 1 5260 3088n
load net core_inst|search_inst_n_131 -attr @name search_inst_n_131 -pin core_inst|data_memory_inst seg7_o_reg[6]_0 -pin core_inst|search_inst led_o[15]_i_6_3
netloc core_inst|search_inst_n_131 1 3 1 5220 3108n
load net core_inst|search_inst_n_132 -attr @name search_inst_n_132 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_34_0 -pin core_inst|search_inst led_o[15]_i_6_4
netloc core_inst|search_inst_n_132 1 3 1 5000 3128n
load net core_inst|search_inst_n_133 -attr @name search_inst_n_133 -pin core_inst|data_memory_inst seg7_o_reg[5]_0 -pin core_inst|search_inst led_o[15]_i_6_5
netloc core_inst|search_inst_n_133 1 3 1 5360 3148n
load net core_inst|search_inst_n_134 -attr @name search_inst_n_134 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_36_0 -pin core_inst|search_inst led_o[15]_i_6_6
netloc core_inst|search_inst_n_134 1 3 1 4880 3168n
load net core_inst|search_inst_n_135 -attr @name search_inst_n_135 -pin core_inst|data_memory_inst seg7_o_reg[4]_0 -pin core_inst|search_inst led_o[15]_i_6_7
netloc core_inst|search_inst_n_135 1 3 1 5080 3188n
load net core_inst|search_inst_n_136 -attr @name search_inst_n_136 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_30_1 -pin core_inst|search_inst led_o[15]_i_6_8
netloc core_inst|search_inst_n_136 1 3 1 5200 3208n
load net core_inst|search_inst_n_137 -attr @name search_inst_n_137 -pin core_inst|data_memory_inst pmod_col_o_reg[3]_1 -pin core_inst|search_inst led_o[15]_i_6_9
netloc core_inst|search_inst_n_137 1 3 1 5020 3048n
load net core_inst|search_inst_n_138 -attr @name search_inst_n_138 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_32_1 -pin core_inst|search_inst led_o[15]_i_6_10
netloc core_inst|search_inst_n_138 1 3 1 5160 3248n
load net core_inst|search_inst_n_139 -attr @name search_inst_n_139 -pin core_inst|data_memory_inst pmod_col_o_reg[2]_0 -pin core_inst|search_inst led_o[15]_i_6_11
netloc core_inst|search_inst_n_139 1 3 1 4920 3028n
load net core_inst|search_inst_n_140 -attr @name search_inst_n_140 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_24_4 -pin core_inst|search_inst led_o[15]_i_6_12
netloc core_inst|search_inst_n_140 1 3 1 5120 3168n
load net core_inst|search_inst_n_141 -attr @name search_inst_n_141 -pin core_inst|data_memory_inst pmod_col_o_reg[1]_0 -pin core_inst|search_inst led_o[15]_i_6_13
netloc core_inst|search_inst_n_141 1 3 1 5100 3008n
load net core_inst|search_inst_n_142 -attr @name search_inst_n_142 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_28_0 -pin core_inst|search_inst led_o[15]_i_6_14
netloc core_inst|search_inst_n_142 1 3 1 5140 3188n
load net core_inst|search_inst_n_143 -attr @name search_inst_n_143 -pin core_inst|data_memory_inst pmod_col_o_reg[0]_0 -pin core_inst|search_inst led_o[15]_i_6_15
netloc core_inst|search_inst_n_143 1 3 1 4980 2988n
load net core_inst|search_inst_n_144 -attr @name search_inst_n_144 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_29 -pin core_inst|search_inst mem_reg_0_255_0_0_i_6_0
netloc core_inst|search_inst_n_144 1 3 1 5240 3208n
load net core_inst|search_inst_n_146 -attr @name search_inst_n_146 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_29_1 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_83_1
netloc core_inst|search_inst_n_146 1 3 1 5180 3248n
load net core_inst|search_inst_n_147 -attr @name search_inst_n_147 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_178_2 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_21_1
netloc core_inst|search_inst_n_147 1 3 1 5560 3428n
load net core_inst|search_inst_n_148 -attr @name search_inst_n_148 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_178_1 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_3
netloc core_inst|search_inst_n_148 1 3 1 5480 3408n
load net core_inst|search_inst_n_149 -attr @name search_inst_n_149 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_178_3 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_4
netloc core_inst|search_inst_n_149 1 3 1 5720 3448n
load net core_inst|search_inst_n_15 -attr @name search_inst_n_15 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_7_0 -pin core_inst|search_inst mem_reg_0_255_24_24_i_3_1
netloc core_inst|search_inst_n_15 1 3 1 5400 3528n
load net core_inst|search_inst_n_150 -attr @name search_inst_n_150 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_178_0 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_5
netloc core_inst|search_inst_n_150 1 3 1 5680 3388n
load net core_inst|search_inst_n_151 -attr @name search_inst_n_151 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_6_11_i_39_2 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_21_2
netloc core_inst|search_inst_n_151 1 3 1 4880 3548n
load net core_inst|search_inst_n_152 -attr @name search_inst_n_152 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_6_11_i_39_1 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_6
netloc core_inst|search_inst_n_152 1 3 1 5440 3528n
load net core_inst|search_inst_n_153 -attr @name search_inst_n_153 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_6_11_i_39_3 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_7
netloc core_inst|search_inst_n_153 1 3 1 4860 3568n
load net core_inst|search_inst_n_154 -attr @name search_inst_n_154 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_6_11_i_39_0 -pin core_inst|search_inst register_file_reg_r1_0_31_6_11_i_24_8
netloc core_inst|search_inst_n_154 1 3 1 5760 3508n
load net core_inst|search_inst_n_155 -attr @name search_inst_n_155 -pin core_inst|execution_inst register_file_reg_r1_0_31_24_29_i_64 -pin core_inst|search_inst pc_next_carry__1_i_1_2
netloc core_inst|search_inst_n_155 1 1 3 2590 4388 3070J 4888 5000
load net core_inst|search_inst_n_158 -attr @name search_inst_n_158 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_7_2 -pin core_inst|search_inst mem_reg_0_255_0_0_i_11_0
netloc core_inst|search_inst_n_158 1 3 1 5500 3388n
load net core_inst|search_inst_n_159 -attr @name search_inst_n_159 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_7_1 -pin core_inst|search_inst mem_reg_0_255_0_0_i_11_1
netloc core_inst|search_inst_n_159 1 3 1 5460 3408n
load net core_inst|search_inst_n_160 -attr @name search_inst_n_160 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_30_31__0_i_2_0 -pin core_inst|search_inst register_file_reg_r2_0_31_30_31__0
netloc core_inst|search_inst_n_160 1 3 1 5920 3828n
load net core_inst|search_inst_n_161 -attr @name search_inst_n_161 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_30_31_i_2_0 -pin core_inst|search_inst register_file_reg_r2_0_31_30_31
netloc core_inst|search_inst_n_161 1 3 1 5940 3848n
load net core_inst|search_inst_n_162 -attr @name search_inst_n_162 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_15_0 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29
netloc core_inst|search_inst_n_162 1 3 1 5820 3788n
load net core_inst|search_inst_n_163 -attr @name search_inst_n_163 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_17_0 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29_0
netloc core_inst|search_inst_n_163 1 3 1 5880 3808n
load net core_inst|search_inst_n_164 -attr @name search_inst_n_164 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_11_0 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29_1
netloc core_inst|search_inst_n_164 1 3 1 5800 3748n
load net core_inst|search_inst_n_165 -attr @name search_inst_n_165 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_13_0 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29_2
netloc core_inst|search_inst_n_165 1 3 1 5860 3768n
load net core_inst|search_inst_n_166 -attr @name search_inst_n_166 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_7_4 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29_3
netloc core_inst|search_inst_n_166 1 3 1 5780 3708n
load net core_inst|search_inst_n_167 -attr @name search_inst_n_167 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_9_0 -pin core_inst|search_inst register_file_reg_r2_0_31_24_29_4
netloc core_inst|search_inst_n_167 1 3 1 5840 3728n
load net core_inst|search_inst_n_168 -attr @name search_inst_n_168 -pin core_inst|data_memory_inst seg7_o_reg[15]_1 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_0
netloc core_inst|search_inst_n_168 1 3 1 5480 4108n
load net core_inst|search_inst_n_169 -attr @name search_inst_n_169 -pin core_inst|data_memory_inst seg7_o_reg[8]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_1
netloc core_inst|search_inst_n_169 1 3 1 5600 3948n
load net core_inst|search_inst_n_170 -attr @name search_inst_n_170 -pin core_inst|data_memory_inst seg7_o_reg[9]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_2
netloc core_inst|search_inst_n_170 1 3 1 5640 3988n
load net core_inst|search_inst_n_171 -attr @name search_inst_n_171 -pin core_inst|data_memory_inst seg7_o_reg[10]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_3
netloc core_inst|search_inst_n_171 1 3 1 5520 4008n
load net core_inst|search_inst_n_172 -attr @name search_inst_n_172 -pin core_inst|data_memory_inst seg7_o_reg[11]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_4
netloc core_inst|search_inst_n_172 1 3 1 5400 4028n
load net core_inst|search_inst_n_173 -attr @name search_inst_n_173 -pin core_inst|data_memory_inst seg7_o_reg[12]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_5
netloc core_inst|search_inst_n_173 1 3 1 5500 4048n
load net core_inst|search_inst_n_174 -attr @name search_inst_n_174 -pin core_inst|data_memory_inst seg7_o_reg[13]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_6
netloc core_inst|search_inst_n_174 1 3 1 5900 4068n
load net core_inst|search_inst_n_175 -attr @name search_inst_n_175 -pin core_inst|data_memory_inst seg7_o_reg[14]_0 -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_14_7
netloc core_inst|search_inst_n_175 1 3 1 5960 4088n
load net core_inst|search_inst_n_176 -attr @name search_inst_n_176 -pin core_inst|execution_inst pc_reg[31]_i_22 -pin core_inst|search_inst register_file_reg_r1_0_31_24_29_i_43_0
netloc core_inst|search_inst_n_176 1 1 3 2430 4248 3390J 4748 4760
load net core_inst|search_inst_n_177 -attr @rip mem_reg_0_255_0_0_i_16_1[2] -attr @name search_inst_n_177 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_30_0[2] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_1[2]
load net core_inst|search_inst_n_178 -attr @rip mem_reg_0_255_0_0_i_16_1[1] -attr @name search_inst_n_178 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_30_0[1] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_1[1]
load net core_inst|search_inst_n_179 -attr @rip mem_reg_0_255_0_0_i_16_1[0] -attr @name search_inst_n_179 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_30_0[0] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_1[0]
load net core_inst|search_inst_n_180 -attr @rip mem_reg_0_255_0_0_i_16_2[3] -attr @name search_inst_n_180 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_190_0[3] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_2[3]
load net core_inst|search_inst_n_181 -attr @rip mem_reg_0_255_0_0_i_16_2[2] -attr @name search_inst_n_181 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_190_0[2] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_2[2]
load net core_inst|search_inst_n_182 -attr @rip mem_reg_0_255_0_0_i_16_2[1] -attr @name search_inst_n_182 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_190_0[1] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_2[1]
load net core_inst|search_inst_n_183 -attr @rip mem_reg_0_255_0_0_i_16_2[0] -attr @name search_inst_n_183 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_190_0[0] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_2[0]
load net core_inst|search_inst_n_184 -attr @rip mem_reg_0_255_0_0_i_16_3[1] -attr @name search_inst_n_184 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_32_0[1] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_3[1]
load net core_inst|search_inst_n_185 -attr @rip mem_reg_0_255_0_0_i_16_3[0] -attr @name search_inst_n_185 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_32_0[0] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_3[0]
load net core_inst|search_inst_n_186 -attr @rip pc_reg_reg[31]_1[3] -attr @name search_inst_n_186 -pin core_inst|execution_inst pc_reg_reg[31]_0[3] -pin core_inst|search_inst pc_reg_reg[31]_1[3]
load net core_inst|search_inst_n_187 -attr @rip pc_reg_reg[31]_1[2] -attr @name search_inst_n_187 -pin core_inst|execution_inst pc_reg_reg[31]_0[2] -pin core_inst|search_inst pc_reg_reg[31]_1[2]
load net core_inst|search_inst_n_188 -attr @rip pc_reg_reg[31]_1[1] -attr @name search_inst_n_188 -pin core_inst|execution_inst pc_reg_reg[31]_0[1] -pin core_inst|search_inst pc_reg_reg[31]_1[1]
load net core_inst|search_inst_n_189 -attr @rip pc_reg_reg[31]_1[0] -attr @name search_inst_n_189 -pin core_inst|execution_inst pc_reg_reg[31]_0[0] -pin core_inst|search_inst pc_reg_reg[31]_1[0]
load net core_inst|search_inst_n_190 -attr @rip CO[0] -attr @name search_inst_n_190 -pin core_inst|execution_inst CO[0] -pin core_inst|search_inst CO[0]
netloc core_inst|search_inst_n_190 1 1 3 2570 3408 3010J 2588 4880
load net core_inst|search_inst_n_191 -attr @rip pc_next_carry__1_i_1_3[3] -attr @name search_inst_n_191 -pin core_inst|execution_inst S[3] -pin core_inst|search_inst pc_next_carry__1_i_1_3[3]
load net core_inst|search_inst_n_192 -attr @rip pc_next_carry__1_i_1_3[2] -attr @name search_inst_n_192 -pin core_inst|execution_inst S[2] -pin core_inst|search_inst pc_next_carry__1_i_1_3[2]
load net core_inst|search_inst_n_193 -attr @rip pc_next_carry__1_i_1_3[1] -attr @name search_inst_n_193 -pin core_inst|execution_inst S[1] -pin core_inst|search_inst pc_next_carry__1_i_1_3[1]
load net core_inst|search_inst_n_194 -attr @rip pc_next_carry__1_i_1_3[0] -attr @name search_inst_n_194 -pin core_inst|execution_inst S[0] -pin core_inst|search_inst pc_next_carry__1_i_1_3[0]
load net core_inst|search_inst_n_195 -attr @rip pc_next_carry__0_i_2[3] -attr @name search_inst_n_195 -pin core_inst|execution_inst pc_next_carry__0_i_2[3] -pin core_inst|search_inst pc_next_carry__0_i_2[3]
load net core_inst|search_inst_n_196 -attr @rip pc_next_carry__0_i_2[2] -attr @name search_inst_n_196 -pin core_inst|execution_inst pc_next_carry__0_i_2[2] -pin core_inst|search_inst pc_next_carry__0_i_2[2]
load net core_inst|search_inst_n_197 -attr @rip pc_next_carry__0_i_2[1] -attr @name search_inst_n_197 -pin core_inst|execution_inst pc_next_carry__0_i_2[1] -pin core_inst|search_inst pc_next_carry__0_i_2[1]
load net core_inst|search_inst_n_198 -attr @rip pc_next_carry__0_i_2[0] -attr @name search_inst_n_198 -pin core_inst|execution_inst pc_next_carry__0_i_2[0] -pin core_inst|search_inst pc_next_carry__0_i_2[0]
load net core_inst|search_inst_n_199 -attr @rip pc_reg_reg[11]_0[3] -attr @name search_inst_n_199 -pin core_inst|execution_inst pc_reg_reg[11][3] -pin core_inst|search_inst pc_reg_reg[11]_0[3]
load net core_inst|search_inst_n_200 -attr @rip pc_reg_reg[11]_0[2] -attr @name search_inst_n_200 -pin core_inst|execution_inst pc_reg_reg[11][2] -pin core_inst|search_inst pc_reg_reg[11]_0[2]
load net core_inst|search_inst_n_201 -attr @rip pc_reg_reg[11]_0[1] -attr @name search_inst_n_201 -pin core_inst|execution_inst pc_reg_reg[11][1] -pin core_inst|search_inst pc_reg_reg[11]_0[1]
load net core_inst|search_inst_n_202 -attr @rip pc_reg_reg[11]_0[0] -attr @name search_inst_n_202 -pin core_inst|execution_inst pc_reg_reg[11][0] -pin core_inst|search_inst pc_reg_reg[11]_0[0]
load net core_inst|search_inst_n_203 -attr @rip pc_reg_reg[15]_0[3] -attr @name search_inst_n_203 -pin core_inst|execution_inst pc_reg_reg[15][3] -pin core_inst|search_inst pc_reg_reg[15]_0[3]
load net core_inst|search_inst_n_204 -attr @rip pc_reg_reg[15]_0[2] -attr @name search_inst_n_204 -pin core_inst|execution_inst pc_reg_reg[15][2] -pin core_inst|search_inst pc_reg_reg[15]_0[2]
load net core_inst|search_inst_n_205 -attr @rip pc_reg_reg[15]_0[1] -attr @name search_inst_n_205 -pin core_inst|execution_inst pc_reg_reg[15][1] -pin core_inst|search_inst pc_reg_reg[15]_0[1]
load net core_inst|search_inst_n_206 -attr @rip pc_reg_reg[15]_0[0] -attr @name search_inst_n_206 -pin core_inst|execution_inst pc_reg_reg[15][0] -pin core_inst|search_inst pc_reg_reg[15]_0[0]
load net core_inst|search_inst_n_207 -attr @rip pc_reg_reg[19]_0[3] -attr @name search_inst_n_207 -pin core_inst|execution_inst pc_reg_reg[19][3] -pin core_inst|search_inst pc_reg_reg[19]_0[3]
load net core_inst|search_inst_n_208 -attr @rip pc_reg_reg[19]_0[2] -attr @name search_inst_n_208 -pin core_inst|execution_inst pc_reg_reg[19][2] -pin core_inst|search_inst pc_reg_reg[19]_0[2]
load net core_inst|search_inst_n_209 -attr @rip pc_reg_reg[19]_0[1] -attr @name search_inst_n_209 -pin core_inst|execution_inst pc_reg_reg[19][1] -pin core_inst|search_inst pc_reg_reg[19]_0[1]
load net core_inst|search_inst_n_210 -attr @rip pc_reg_reg[19]_0[0] -attr @name search_inst_n_210 -pin core_inst|execution_inst pc_reg_reg[19][0] -pin core_inst|search_inst pc_reg_reg[19]_0[0]
load net core_inst|search_inst_n_211 -attr @rip pc_reg_reg[23]_0[3] -attr @name search_inst_n_211 -pin core_inst|execution_inst pc_reg_reg[23][3] -pin core_inst|search_inst pc_reg_reg[23]_0[3]
load net core_inst|search_inst_n_212 -attr @rip pc_reg_reg[23]_0[2] -attr @name search_inst_n_212 -pin core_inst|execution_inst pc_reg_reg[23][2] -pin core_inst|search_inst pc_reg_reg[23]_0[2]
load net core_inst|search_inst_n_213 -attr @rip pc_reg_reg[23]_0[1] -attr @name search_inst_n_213 -pin core_inst|execution_inst pc_reg_reg[23][1] -pin core_inst|search_inst pc_reg_reg[23]_0[1]
load net core_inst|search_inst_n_214 -attr @rip pc_reg_reg[23]_0[0] -attr @name search_inst_n_214 -pin core_inst|execution_inst pc_reg_reg[23][0] -pin core_inst|search_inst pc_reg_reg[23]_0[0]
load net core_inst|search_inst_n_215 -attr @rip pc_reg_reg[27]_0[3] -attr @name search_inst_n_215 -pin core_inst|execution_inst pc_reg_reg[27][3] -pin core_inst|search_inst pc_reg_reg[27]_0[3]
load net core_inst|search_inst_n_216 -attr @rip pc_reg_reg[27]_0[2] -attr @name search_inst_n_216 -pin core_inst|execution_inst pc_reg_reg[27][2] -pin core_inst|search_inst pc_reg_reg[27]_0[2]
load net core_inst|search_inst_n_217 -attr @rip pc_reg_reg[27]_0[1] -attr @name search_inst_n_217 -pin core_inst|execution_inst pc_reg_reg[27][1] -pin core_inst|search_inst pc_reg_reg[27]_0[1]
load net core_inst|search_inst_n_218 -attr @rip pc_reg_reg[27]_0[0] -attr @name search_inst_n_218 -pin core_inst|execution_inst pc_reg_reg[27][0] -pin core_inst|search_inst pc_reg_reg[27]_0[0]
load net core_inst|search_inst_n_4 -attr @name search_inst_n_4 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_24_29_i_7_3 -pin core_inst|search_inst mem_reg_0_255_24_24_i_3_0
netloc core_inst|search_inst_n_4 1 3 1 5340 3508n
load net core_inst|search_inst_n_48 -attr @name search_inst_n_48 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_0_5_i_29_0 -pin core_inst|search_inst register_file_reg_r1_0_31_0_5_i_83_0
netloc core_inst|search_inst_n_48 1 3 1 5320 3228n
load net core_inst|search_inst_n_49 -attr @rip E[1] -attr @name search_inst_n_49 -pin core_inst|data_memory_inst E[1] -pin core_inst|search_inst E[1]
load net core_inst|search_inst_n_50 -attr @rip E[0] -attr @name search_inst_n_50 -pin core_inst|data_memory_inst E[0] -pin core_inst|search_inst E[0]
load net core_inst|search_inst_n_51 -attr @rip mem_reg_0_255_0_0_i_16_0[1] -attr @name search_inst_n_51 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_12_17_i_42_0[1] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_0[1]
load net core_inst|search_inst_n_52 -attr @rip mem_reg_0_255_0_0_i_16_0[0] -attr @name search_inst_n_52 -pin core_inst|data_memory_inst register_file_reg_r1_0_31_12_17_i_42_0[0] -pin core_inst|search_inst mem_reg_0_255_0_0_i_16_0[0]
load net core_inst|search_inst_n_53 -attr @rip led_o[15]_i_5_0[1] -attr @name search_inst_n_53 -pin core_inst|data_memory_inst seg7_o_reg[8]_1[1] -pin core_inst|search_inst led_o[15]_i_5_0[1]
load net core_inst|search_inst_n_54 -attr @rip led_o[15]_i_5_0[0] -attr @name search_inst_n_54 -pin core_inst|data_memory_inst seg7_o_reg[8]_1[0] -pin core_inst|search_inst led_o[15]_i_5_0[0]
load net core_inst|seg7_o_reg[15][0] -attr @rip seg7_o_reg[15]_0[0] -attr @name seg7_o_reg[15][0] -hierPin core_inst seg7_o_reg[15][0] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[0]
load net core_inst|seg7_o_reg[15][10] -attr @rip seg7_o_reg[15]_0[10] -attr @name seg7_o_reg[15][10] -hierPin core_inst seg7_o_reg[15][10] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[10] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[5]
load net core_inst|seg7_o_reg[15][11] -attr @rip seg7_o_reg[15]_0[11] -attr @name seg7_o_reg[15][11] -hierPin core_inst seg7_o_reg[15][11] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[11] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[6]
load net core_inst|seg7_o_reg[15][12] -attr @rip seg7_o_reg[15]_0[12] -attr @name seg7_o_reg[15][12] -hierPin core_inst seg7_o_reg[15][12] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[12] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[7]
load net core_inst|seg7_o_reg[15][13] -attr @rip seg7_o_reg[15]_0[13] -attr @name seg7_o_reg[15][13] -hierPin core_inst seg7_o_reg[15][13] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[13] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[8]
load net core_inst|seg7_o_reg[15][14] -attr @rip seg7_o_reg[15]_0[14] -attr @name seg7_o_reg[15][14] -hierPin core_inst seg7_o_reg[15][14] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[14] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[9]
load net core_inst|seg7_o_reg[15][15] -attr @rip seg7_o_reg[15]_0[15] -attr @name seg7_o_reg[15][15] -hierPin core_inst seg7_o_reg[15][15] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[15] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[10]
load net core_inst|seg7_o_reg[15][1] -attr @rip seg7_o_reg[15]_0[1] -attr @name seg7_o_reg[15][1] -hierPin core_inst seg7_o_reg[15][1] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[1]
load net core_inst|seg7_o_reg[15][2] -attr @rip seg7_o_reg[15]_0[2] -attr @name seg7_o_reg[15][2] -hierPin core_inst seg7_o_reg[15][2] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[2]
load net core_inst|seg7_o_reg[15][3] -attr @rip seg7_o_reg[15]_0[3] -attr @name seg7_o_reg[15][3] -hierPin core_inst seg7_o_reg[15][3] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[3]
load net core_inst|seg7_o_reg[15][4] -attr @rip seg7_o_reg[15]_0[4] -attr @name seg7_o_reg[15][4] -hierPin core_inst seg7_o_reg[15][4] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[4]
load net core_inst|seg7_o_reg[15][5] -attr @rip seg7_o_reg[15]_0[5] -attr @name seg7_o_reg[15][5] -hierPin core_inst seg7_o_reg[15][5] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[5] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[0]
load net core_inst|seg7_o_reg[15][6] -attr @rip seg7_o_reg[15]_0[6] -attr @name seg7_o_reg[15][6] -hierPin core_inst seg7_o_reg[15][6] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[6] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[1]
load net core_inst|seg7_o_reg[15][7] -attr @rip seg7_o_reg[15]_0[7] -attr @name seg7_o_reg[15][7] -hierPin core_inst seg7_o_reg[15][7] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[7] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[2]
load net core_inst|seg7_o_reg[15][8] -attr @rip seg7_o_reg[15]_0[8] -attr @name seg7_o_reg[15][8] -hierPin core_inst seg7_o_reg[15][8] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[8] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[3]
load net core_inst|seg7_o_reg[15][9] -attr @rip seg7_o_reg[15]_0[9] -attr @name seg7_o_reg[15][9] -hierPin core_inst seg7_o_reg[15][9] -pin core_inst|data_memory_inst seg7_o_reg[15]_0[9] -pin core_inst|search_inst register_file_reg_r1_0_31_12_17_i_13_0[4]
load net core_inst|switch_IBUF[0] -attr @rip switch_IBUF[0] -attr @name switch_IBUF[0] -hierPin core_inst switch_IBUF[0] -pin core_inst|data_memory_inst switch_IBUF[0]
load net core_inst|switch_IBUF[10] -attr @rip switch_IBUF[10] -attr @name switch_IBUF[10] -hierPin core_inst switch_IBUF[10] -pin core_inst|search_inst switch_IBUF[5]
load net core_inst|switch_IBUF[11] -attr @rip switch_IBUF[11] -attr @name switch_IBUF[11] -hierPin core_inst switch_IBUF[11] -pin core_inst|search_inst switch_IBUF[6]
load net core_inst|switch_IBUF[12] -attr @rip switch_IBUF[12] -attr @name switch_IBUF[12] -hierPin core_inst switch_IBUF[12] -pin core_inst|search_inst switch_IBUF[7]
load net core_inst|switch_IBUF[13] -attr @rip switch_IBUF[13] -attr @name switch_IBUF[13] -hierPin core_inst switch_IBUF[13] -pin core_inst|search_inst switch_IBUF[8]
load net core_inst|switch_IBUF[14] -attr @rip switch_IBUF[14] -attr @name switch_IBUF[14] -hierPin core_inst switch_IBUF[14] -pin core_inst|search_inst switch_IBUF[9]
load net core_inst|switch_IBUF[15] -attr @rip switch_IBUF[15] -attr @name switch_IBUF[15] -hierPin core_inst switch_IBUF[15] -pin core_inst|search_inst switch_IBUF[10]
load net core_inst|switch_IBUF[1] -attr @rip switch_IBUF[1] -attr @name switch_IBUF[1] -hierPin core_inst switch_IBUF[1] -pin core_inst|data_memory_inst switch_IBUF[1]
load net core_inst|switch_IBUF[2] -attr @rip switch_IBUF[2] -attr @name switch_IBUF[2] -hierPin core_inst switch_IBUF[2] -pin core_inst|data_memory_inst switch_IBUF[2]
load net core_inst|switch_IBUF[3] -attr @rip switch_IBUF[3] -attr @name switch_IBUF[3] -hierPin core_inst switch_IBUF[3] -pin core_inst|data_memory_inst switch_IBUF[3]
load net core_inst|switch_IBUF[4] -attr @rip switch_IBUF[4] -attr @name switch_IBUF[4] -hierPin core_inst switch_IBUF[4] -pin core_inst|data_memory_inst switch_IBUF[4]
load net core_inst|switch_IBUF[5] -attr @rip switch_IBUF[5] -attr @name switch_IBUF[5] -hierPin core_inst switch_IBUF[5] -pin core_inst|search_inst switch_IBUF[0]
load net core_inst|switch_IBUF[6] -attr @rip switch_IBUF[6] -attr @name switch_IBUF[6] -hierPin core_inst switch_IBUF[6] -pin core_inst|search_inst switch_IBUF[1]
load net core_inst|switch_IBUF[7] -attr @rip switch_IBUF[7] -attr @name switch_IBUF[7] -hierPin core_inst switch_IBUF[7] -pin core_inst|search_inst switch_IBUF[2]
load net core_inst|switch_IBUF[8] -attr @rip switch_IBUF[8] -attr @name switch_IBUF[8] -hierPin core_inst switch_IBUF[8] -pin core_inst|search_inst switch_IBUF[3]
load net core_inst|switch_IBUF[9] -attr @rip switch_IBUF[9] -attr @name switch_IBUF[9] -hierPin core_inst switch_IBUF[9] -pin core_inst|search_inst switch_IBUF[4]
load net core_inst|write_back_data[0] -attr @rip write_back_data[0] -attr @name write_back_data[0] -pin core_inst|decoder_inst write_back_data[0] -pin core_inst|search_inst write_back_data[0]
load net core_inst|write_back_data[10] -attr @rip write_back_data[10] -attr @name write_back_data[10] -pin core_inst|decoder_inst write_back_data[10] -pin core_inst|search_inst write_back_data[10]
load net core_inst|write_back_data[11] -attr @rip write_back_data[11] -attr @name write_back_data[11] -pin core_inst|decoder_inst write_back_data[11] -pin core_inst|search_inst write_back_data[11]
load net core_inst|write_back_data[12] -attr @rip write_back_data[12] -attr @name write_back_data[12] -pin core_inst|decoder_inst write_back_data[12] -pin core_inst|search_inst write_back_data[12]
load net core_inst|write_back_data[13] -attr @rip write_back_data[13] -attr @name write_back_data[13] -pin core_inst|decoder_inst write_back_data[13] -pin core_inst|search_inst write_back_data[13]
load net core_inst|write_back_data[14] -attr @rip write_back_data[14] -attr @name write_back_data[14] -pin core_inst|decoder_inst write_back_data[14] -pin core_inst|search_inst write_back_data[14]
load net core_inst|write_back_data[15] -attr @rip write_back_data[15] -attr @name write_back_data[15] -pin core_inst|decoder_inst write_back_data[15] -pin core_inst|search_inst write_back_data[15]
load net core_inst|write_back_data[16] -attr @rip write_back_data[16] -attr @name write_back_data[16] -pin core_inst|decoder_inst write_back_data[16] -pin core_inst|search_inst write_back_data[16]
load net core_inst|write_back_data[17] -attr @rip write_back_data[17] -attr @name write_back_data[17] -pin core_inst|decoder_inst write_back_data[17] -pin core_inst|search_inst write_back_data[17]
load net core_inst|write_back_data[18] -attr @rip write_back_data[18] -attr @name write_back_data[18] -pin core_inst|decoder_inst write_back_data[18] -pin core_inst|search_inst write_back_data[18]
load net core_inst|write_back_data[19] -attr @rip write_back_data[19] -attr @name write_back_data[19] -pin core_inst|decoder_inst write_back_data[19] -pin core_inst|search_inst write_back_data[19]
load net core_inst|write_back_data[1] -attr @rip write_back_data[1] -attr @name write_back_data[1] -pin core_inst|decoder_inst write_back_data[1] -pin core_inst|search_inst write_back_data[1]
load net core_inst|write_back_data[20] -attr @rip write_back_data[20] -attr @name write_back_data[20] -pin core_inst|decoder_inst write_back_data[20] -pin core_inst|search_inst write_back_data[20]
load net core_inst|write_back_data[21] -attr @rip write_back_data[21] -attr @name write_back_data[21] -pin core_inst|decoder_inst write_back_data[21] -pin core_inst|search_inst write_back_data[21]
load net core_inst|write_back_data[22] -attr @rip write_back_data[22] -attr @name write_back_data[22] -pin core_inst|decoder_inst write_back_data[22] -pin core_inst|search_inst write_back_data[22]
load net core_inst|write_back_data[23] -attr @rip write_back_data[23] -attr @name write_back_data[23] -pin core_inst|decoder_inst write_back_data[23] -pin core_inst|search_inst write_back_data[23]
load net core_inst|write_back_data[24] -attr @rip write_back_data[24] -attr @name write_back_data[24] -pin core_inst|decoder_inst write_back_data[24] -pin core_inst|search_inst write_back_data[24]
load net core_inst|write_back_data[25] -attr @rip write_back_data[25] -attr @name write_back_data[25] -pin core_inst|decoder_inst write_back_data[25] -pin core_inst|search_inst write_back_data[25]
load net core_inst|write_back_data[26] -attr @rip write_back_data[26] -attr @name write_back_data[26] -pin core_inst|decoder_inst write_back_data[26] -pin core_inst|search_inst write_back_data[26]
load net core_inst|write_back_data[27] -attr @rip write_back_data[27] -attr @name write_back_data[27] -pin core_inst|decoder_inst write_back_data[27] -pin core_inst|search_inst write_back_data[27]
load net core_inst|write_back_data[28] -attr @rip write_back_data[28] -attr @name write_back_data[28] -pin core_inst|decoder_inst write_back_data[28] -pin core_inst|search_inst write_back_data[28]
load net core_inst|write_back_data[29] -attr @rip write_back_data[29] -attr @name write_back_data[29] -pin core_inst|decoder_inst write_back_data[29] -pin core_inst|search_inst write_back_data[29]
load net core_inst|write_back_data[2] -attr @rip write_back_data[2] -attr @name write_back_data[2] -pin core_inst|decoder_inst write_back_data[2] -pin core_inst|search_inst write_back_data[2]
load net core_inst|write_back_data[30] -attr @rip write_back_data[30] -attr @name write_back_data[30] -pin core_inst|decoder_inst write_back_data[30] -pin core_inst|search_inst write_back_data[30]
load net core_inst|write_back_data[31] -attr @rip write_back_data[31] -attr @name write_back_data[31] -pin core_inst|decoder_inst write_back_data[31] -pin core_inst|search_inst write_back_data[31]
load net core_inst|write_back_data[3] -attr @rip write_back_data[3] -attr @name write_back_data[3] -pin core_inst|decoder_inst write_back_data[3] -pin core_inst|search_inst write_back_data[3]
load net core_inst|write_back_data[4] -attr @rip write_back_data[4] -attr @name write_back_data[4] -pin core_inst|decoder_inst write_back_data[4] -pin core_inst|search_inst write_back_data[4]
load net core_inst|write_back_data[5] -attr @rip write_back_data[5] -attr @name write_back_data[5] -pin core_inst|decoder_inst write_back_data[5] -pin core_inst|search_inst write_back_data[5]
load net core_inst|write_back_data[6] -attr @rip write_back_data[6] -attr @name write_back_data[6] -pin core_inst|decoder_inst write_back_data[6] -pin core_inst|search_inst write_back_data[6]
load net core_inst|write_back_data[7] -attr @rip write_back_data[7] -attr @name write_back_data[7] -pin core_inst|decoder_inst write_back_data[7] -pin core_inst|search_inst write_back_data[7]
load net core_inst|write_back_data[8] -attr @rip write_back_data[8] -attr @name write_back_data[8] -pin core_inst|decoder_inst write_back_data[8] -pin core_inst|search_inst write_back_data[8]
load net core_inst|write_back_data[9] -attr @rip write_back_data[9] -attr @name write_back_data[9] -pin core_inst|decoder_inst write_back_data[9] -pin core_inst|search_inst write_back_data[9]
load netBundle @core_inst|JA_IBUF 4 core_inst|JA_IBUF[3] core_inst|JA_IBUF[2] core_inst|JA_IBUF[1] core_inst|JA_IBUF[0] -autobundled
netbloc @core_inst|JA_IBUF 1 0 4 NJ 2908 NJ 2908 3790 2428 5860J
load netBundle @core_inst|switch_IBUF 16 core_inst|switch_IBUF[15] core_inst|switch_IBUF[14] core_inst|switch_IBUF[13] core_inst|switch_IBUF[12] core_inst|switch_IBUF[11] core_inst|switch_IBUF[10] core_inst|switch_IBUF[9] core_inst|switch_IBUF[8] core_inst|switch_IBUF[7] core_inst|switch_IBUF[6] core_inst|switch_IBUF[5] core_inst|switch_IBUF[4] core_inst|switch_IBUF[3] core_inst|switch_IBUF[2] core_inst|switch_IBUF[1] core_inst|switch_IBUF[0] -autobundled
netbloc @core_inst|switch_IBUF 1 0 4 NJ 4848 NJ 4848 3290 4648 4900
load netBundle @core_inst|Q 16 core_inst|Q[15] core_inst|Q[14] core_inst|Q[13] core_inst|Q[12] core_inst|Q[11] core_inst|Q[10] core_inst|Q[9] core_inst|Q[8] core_inst|Q[7] core_inst|Q[6] core_inst|Q[5] core_inst|Q[4] core_inst|Q[3] core_inst|Q[2] core_inst|Q[1] core_inst|Q[0] -autobundled
netbloc @core_inst|Q 1 2 3 3870 2508 5660J 4208 6920
load netBundle @core_inst|ram_word_data0 30 core_inst|ram_word_data0[31] core_inst|ram_word_data0[30] core_inst|ram_word_data0[29] core_inst|ram_word_data0[28] core_inst|ram_word_data0[27] core_inst|ram_word_data0[26] core_inst|ram_word_data0[25] core_inst|ram_word_data0[24] core_inst|ram_word_data0[23] core_inst|ram_word_data0[22] core_inst|ram_word_data0[21] core_inst|ram_word_data0[20] core_inst|ram_word_data0[19] core_inst|ram_word_data0[18] core_inst|ram_word_data0[17] core_inst|ram_word_data0[16] core_inst|ram_word_data0[15] core_inst|ram_word_data0[14] core_inst|ram_word_data0[13] core_inst|ram_word_data0[12] core_inst|ram_word_data0[11] core_inst|ram_word_data0[10] core_inst|ram_word_data0[9] core_inst|ram_word_data0[8] core_inst|ram_word_data0[7] core_inst|ram_word_data0[6] core_inst|ram_word_data0[5] core_inst|ram_word_data0[3] core_inst|ram_word_data0[2] core_inst|ram_word_data0[1] -autobundled
netbloc @core_inst|ram_word_data0 1 2 3 3950 4628 NJ 4628 6880
load netBundle @core_inst|p_1_in__0 2 core_inst|p_1_in__0[4] core_inst|p_1_in__0[0] -autobundled
netbloc @core_inst|p_1_in__0 1 2 3 3930 4548 NJ 4548 6820
load netBundle @core_inst|pmod_col_o_reg 4 core_inst|pmod_col_o_reg[3][3] core_inst|pmod_col_o_reg[3][2] core_inst|pmod_col_o_reg[3][1] core_inst|pmod_col_o_reg[3][0] -autobundled
netbloc @core_inst|pmod_col_o_reg 1 4 1 6940 3808n
load netBundle @core_inst|seg7_o_reg 16 core_inst|seg7_o_reg[15][15] core_inst|seg7_o_reg[15][14] core_inst|seg7_o_reg[15][13] core_inst|seg7_o_reg[15][12] core_inst|seg7_o_reg[15][11] core_inst|seg7_o_reg[15][10] core_inst|seg7_o_reg[15][9] core_inst|seg7_o_reg[15][8] core_inst|seg7_o_reg[15][7] core_inst|seg7_o_reg[15][6] core_inst|seg7_o_reg[15][5] core_inst|seg7_o_reg[15][4] core_inst|seg7_o_reg[15][3] core_inst|seg7_o_reg[15][2] core_inst|seg7_o_reg[15][1] core_inst|seg7_o_reg[15][0] -autobundled
netbloc @core_inst|seg7_o_reg 1 2 3 3910 4908 NJ 4908 6900
load netBundle @core_inst|rs1_o0 32 core_inst|rs1_o0[31] core_inst|rs1_o0[30] core_inst|rs1_o0[29] core_inst|rs1_o0[28] core_inst|rs1_o0[27] core_inst|rs1_o0[26] core_inst|rs1_o0[25] core_inst|rs1_o0[24] core_inst|rs1_o0[23] core_inst|rs1_o0[22] core_inst|rs1_o0[21] core_inst|rs1_o0[20] core_inst|rs1_o0[19] core_inst|rs1_o0[18] core_inst|rs1_o0[17] core_inst|rs1_o0[16] core_inst|rs1_o0[15] core_inst|rs1_o0[14] core_inst|rs1_o0[13] core_inst|rs1_o0[12] core_inst|rs1_o0[11] core_inst|rs1_o0[10] core_inst|rs1_o0[9] core_inst|rs1_o0[8] core_inst|rs1_o0[7] core_inst|rs1_o0[6] core_inst|rs1_o0[5] core_inst|rs1_o0[4] core_inst|rs1_o0[3] core_inst|rs1_o0[2] core_inst|rs1_o0[1] core_inst|rs1_o0[0] -autobundled
netbloc @core_inst|rs1_o0 1 1 2 2410 4188 3450
load netBundle @core_inst|rs2_data 27 core_inst|rs2_data[31] core_inst|rs2_data[30] core_inst|rs2_data[29] core_inst|rs2_data[28] core_inst|rs2_data[27] core_inst|rs2_data[26] core_inst|rs2_data[25] core_inst|rs2_data[24] core_inst|rs2_data[23] core_inst|rs2_data[22] core_inst|rs2_data[21] core_inst|rs2_data[20] core_inst|rs2_data[19] core_inst|rs2_data[18] core_inst|rs2_data[17] core_inst|rs2_data[16] core_inst|rs2_data[15] core_inst|rs2_data[14] core_inst|rs2_data[13] core_inst|rs2_data[12] core_inst|rs2_data[11] core_inst|rs2_data[10] core_inst|rs2_data[9] core_inst|rs2_data[8] core_inst|rs2_data[7] core_inst|rs2_data[6] core_inst|rs2_data[5] -autobundled
netbloc @core_inst|rs2_data 1 1 2 NJ 4148 3830
load netBundle @core_inst|rs2_o0 32 core_inst|rs2_o0[31] core_inst|rs2_o0[30] core_inst|rs2_o0[29] core_inst|rs2_o0[28] core_inst|rs2_o0[27] core_inst|rs2_o0[26] core_inst|rs2_o0[25] core_inst|rs2_o0[24] core_inst|rs2_o0[23] core_inst|rs2_o0[22] core_inst|rs2_o0[21] core_inst|rs2_o0[20] core_inst|rs2_o0[19] core_inst|rs2_o0[18] core_inst|rs2_o0[17] core_inst|rs2_o0[16] core_inst|rs2_o0[15] core_inst|rs2_o0[14] core_inst|rs2_o0[13] core_inst|rs2_o0[12] core_inst|rs2_o0[11] core_inst|rs2_o0[10] core_inst|rs2_o0[9] core_inst|rs2_o0[8] core_inst|rs2_o0[7] core_inst|rs2_o0[6] core_inst|rs2_o0[5] core_inst|rs2_o0[4] core_inst|rs2_o0[3] core_inst|rs2_o0[2] core_inst|rs2_o0[1] core_inst|rs2_o0[0] -autobundled
netbloc @core_inst|rs2_o0 1 1 2 2370J 4208 3430
load netBundle @core_inst|execution_inst_n_ 4 core_inst|execution_inst_n_32 core_inst|execution_inst_n_33 core_inst|execution_inst_n_34 core_inst|execution_inst_n_35 -autobundled
netbloc @core_inst|execution_inst_n_ 1 2 1 3370 3048n
load netBundle @core_inst|pc_branch 31 core_inst|pc_branch[31] core_inst|pc_branch[30] core_inst|pc_branch[29] core_inst|pc_branch[28] core_inst|pc_branch[27] core_inst|pc_branch[26] core_inst|pc_branch[25] core_inst|pc_branch[24] core_inst|pc_branch[23] core_inst|pc_branch[22] core_inst|pc_branch[21] core_inst|pc_branch[20] core_inst|pc_branch[19] core_inst|pc_branch[18] core_inst|pc_branch[17] core_inst|pc_branch[16] core_inst|pc_branch[15] core_inst|pc_branch[14] core_inst|pc_branch[13] core_inst|pc_branch[12] core_inst|pc_branch[11] core_inst|pc_branch[10] core_inst|pc_branch[9] core_inst|pc_branch[8] core_inst|pc_branch[7] core_inst|pc_branch[6] core_inst|pc_branch[5] core_inst|pc_branch[4] core_inst|pc_branch[3] core_inst|pc_branch[2] core_inst|pc_branch[1] -autobundled
netbloc @core_inst|pc_branch 1 2 1 3490 3248n
load netBundle @core_inst|search_inst_n_ 3 core_inst|search_inst_n_124 core_inst|search_inst_n_125 core_inst|search_inst_n_126 -autobundled
netbloc @core_inst|search_inst_n_ 1 3 1 5420 2768n
load netBundle @core_inst|search_inst_n__1 2 core_inst|search_inst_n_49 core_inst|search_inst_n_50 -autobundled
netbloc @core_inst|search_inst_n__1 1 3 1 N 2888
load netBundle @core_inst|alu_result 10 core_inst|alu_result[11] core_inst|alu_result[10] core_inst|alu_result[9] core_inst|alu_result[8] core_inst|alu_result[7] core_inst|alu_result[6] core_inst|alu_result[5] core_inst|alu_result[4] core_inst|alu_result[3] core_inst|alu_result[2] -autobundled
netbloc @core_inst|alu_result 1 3 1 N 2928
load netBundle @core_inst|immediate 31 core_inst|immediate[30] core_inst|immediate[29] core_inst|immediate[28] core_inst|immediate[27] core_inst|immediate[26] core_inst|immediate[25] core_inst|immediate[24] core_inst|immediate[23] core_inst|immediate[22] core_inst|immediate[21] core_inst|immediate[20] core_inst|immediate[19] core_inst|immediate[18] core_inst|immediate[17] core_inst|immediate[16] core_inst|immediate[15] core_inst|immediate[14] core_inst|immediate[13] core_inst|immediate[12] core_inst|immediate[11] core_inst|immediate[10] core_inst|immediate[9] core_inst|immediate[8] core_inst|immediate[7] core_inst|immediate[6] core_inst|immediate[5] core_inst|immediate[4] core_inst|immediate[3] core_inst|immediate[2] core_inst|immediate[1] core_inst|immediate[0] -autobundled
netbloc @core_inst|immediate 1 1 3 2430 3448 3050J 2628 4980
load netBundle @core_inst|search_inst_n__2 2 core_inst|search_inst_n_53 core_inst|search_inst_n_54 -autobundled
netbloc @core_inst|search_inst_n__2 1 3 1 4900 3028n
load netBundle @core_inst|search_inst_n__3 2 core_inst|search_inst_n_51 core_inst|search_inst_n_52 -autobundled
netbloc @core_inst|search_inst_n__3 1 3 1 5520 3428n
load netBundle @core_inst|search_inst_n__4 3 core_inst|search_inst_n_177 core_inst|search_inst_n_178 core_inst|search_inst_n_179 -autobundled
netbloc @core_inst|search_inst_n__4 1 3 1 5340 3268n
load netBundle @core_inst|search_inst_n__5 4 core_inst|search_inst_n_180 core_inst|search_inst_n_181 core_inst|search_inst_n_182 core_inst|search_inst_n_183 -autobundled
netbloc @core_inst|search_inst_n__5 1 3 1 N 3468
load netBundle @core_inst|search_inst_n__6 2 core_inst|search_inst_n_184 core_inst|search_inst_n_185 -autobundled
netbloc @core_inst|search_inst_n__6 1 3 1 5200 3308n
load netBundle @core_inst|search_inst_n__7 4 core_inst|search_inst_n_195 core_inst|search_inst_n_196 core_inst|search_inst_n_197 core_inst|search_inst_n_198 -autobundled
netbloc @core_inst|search_inst_n__7 1 1 3 2410 3528 3230J 2708 4820
load netBundle @core_inst|alu_b__226 4 core_inst|alu_b__226[31] core_inst|alu_b__226[30] core_inst|alu_b__226[29] core_inst|alu_b__226[28] -autobundled
netbloc @core_inst|alu_b__226 1 1 3 2530 3548 3250J 2728 4800
load netBundle @core_inst|instruction 15 core_inst|instruction[24] core_inst|instruction[23] core_inst|instruction[22] core_inst|instruction[21] core_inst|instruction[20] core_inst|instruction[19] core_inst|instruction[18] core_inst|instruction[17] core_inst|instruction[16] core_inst|instruction[15] core_inst|instruction[11] core_inst|instruction[10] core_inst|instruction[9] core_inst|instruction[8] core_inst|instruction[7] -autobundled
netbloc @core_inst|instruction 1 0 4 1910 3568 NJ 3568 3270J 2748 4780
load netBundle @core_inst|search_inst_n__8 4 core_inst|search_inst_n_191 core_inst|search_inst_n_192 core_inst|search_inst_n_193 core_inst|search_inst_n_194 -autobundled
netbloc @core_inst|search_inst_n__8 1 1 3 2550 3648 3050J 4668 4980
load netBundle @core_inst|search_inst_n__9 4 core_inst|search_inst_n_199 core_inst|search_inst_n_200 core_inst|search_inst_n_201 core_inst|search_inst_n_202 -autobundled
netbloc @core_inst|search_inst_n__9 1 1 3 2450 4268 3370J 4768 4960
load netBundle @core_inst|pc_reg_reg 9 core_inst|pc_reg_reg[12][8] core_inst|pc_reg_reg[12][7] core_inst|pc_reg_reg[12][6] core_inst|pc_reg_reg[12][5] core_inst|pc_reg_reg[12][4] core_inst|pc_reg_reg[12][3] core_inst|pc_reg_reg[12][2] core_inst|pc_reg_reg[12][1] core_inst|pc_reg_reg[12][0] -autobundled
netbloc @core_inst|pc_reg_reg 1 3 2 5020 4648 NJ
load netBundle @core_inst|search_inst_n__10 4 core_inst|search_inst_n_203 core_inst|search_inst_n_204 core_inst|search_inst_n_205 core_inst|search_inst_n_206 -autobundled
netbloc @core_inst|search_inst_n__10 1 1 3 2470 4288 3350J 4788 4940
load netBundle @core_inst|search_inst_n__11 4 core_inst|search_inst_n_207 core_inst|search_inst_n_208 core_inst|search_inst_n_209 core_inst|search_inst_n_210 -autobundled
netbloc @core_inst|search_inst_n__11 1 1 3 2490 4308 3330J 4808 4920
load netBundle @core_inst|search_inst_n__12 4 core_inst|search_inst_n_211 core_inst|search_inst_n_212 core_inst|search_inst_n_213 core_inst|search_inst_n_214 -autobundled
netbloc @core_inst|search_inst_n__12 1 1 3 2510 4328 3010J 4828 4840
load netBundle @core_inst|search_inst_n__13 4 core_inst|search_inst_n_215 core_inst|search_inst_n_216 core_inst|search_inst_n_217 core_inst|search_inst_n_218 -autobundled
netbloc @core_inst|search_inst_n__13 1 1 3 2530 4348 3310J 4848 4820
load netBundle @core_inst|pc 3 core_inst|pc[30] core_inst|pc[29] core_inst|pc[28] -autobundled
netbloc @core_inst|pc 1 1 3 2570 4128 3170J 4708 4780
load netBundle @core_inst|alu_a 4 core_inst|alu_a[31] core_inst|alu_a[30] core_inst|alu_a[29] core_inst|alu_a[28] -autobundled
netbloc @core_inst|alu_a 1 1 3 2590 3668 3470J 4688 4740
load netBundle @core_inst|search_inst_n__14 4 core_inst|search_inst_n_186 core_inst|search_inst_n_187 core_inst|search_inst_n_188 core_inst|search_inst_n_189 -autobundled
netbloc @core_inst|search_inst_n__14 1 1 3 2550 4368 3090J 4868 4800
load netBundle @core_inst|write_back_data 32 core_inst|write_back_data[31] core_inst|write_back_data[30] core_inst|write_back_data[29] core_inst|write_back_data[28] core_inst|write_back_data[27] core_inst|write_back_data[26] core_inst|write_back_data[25] core_inst|write_back_data[24] core_inst|write_back_data[23] core_inst|write_back_data[22] core_inst|write_back_data[21] core_inst|write_back_data[20] core_inst|write_back_data[19] core_inst|write_back_data[18] core_inst|write_back_data[17] core_inst|write_back_data[16] core_inst|write_back_data[15] core_inst|write_back_data[14] core_inst|write_back_data[13] core_inst|write_back_data[12] core_inst|write_back_data[11] core_inst|write_back_data[10] core_inst|write_back_data[9] core_inst|write_back_data[8] core_inst|write_back_data[7] core_inst|write_back_data[6] core_inst|write_back_data[5] core_inst|write_back_data[4] core_inst|write_back_data[3] core_inst|write_back_data[2] core_inst|write_back_data[1] core_inst|write_back_data[0] -autobundled
netbloc @core_inst|write_back_data 1 0 4 1910 4268 2370J 4228 3410J 4728 4720
load netBundle @core_inst|pc_next_carry_i_2_ 2 core_inst|pc_next_carry_i_2_0 core_inst|pc_next_carry_i_2 -autobundled
netbloc @core_inst|pc_next_carry_i_2_ 1 0 3 1790 3368 NJ 3368 3190
load netBundle @core_inst|pc_next_carry__0_i_ 4 core_inst|pc_next_carry__0_i_1_0 core_inst|pc_next_carry__0_i_1_1 core_inst|pc_next_carry__0_i_1_2 core_inst|pc_next_carry__0_i_1 -autobundled
netbloc @core_inst|pc_next_carry__0_i_ 1 0 3 1830 3008 NJ 3008 3750
load netBundle @core_inst|pc_reg_reg_1 2 core_inst|pc_reg_reg[12]_0 core_inst|pc_reg_reg[12]_1 -autobundled
netbloc @core_inst|pc_reg_reg_1 1 0 3 1910 4808 NJ 4808 3270
load netBundle @JA 8 JA[10] JA[9] JA[8] JA[7] JA[4] JA[3] JA[2] JA[1] -autobundled
netbloc @JA 1 2 4 430 640 NJ 640 NJ 640 7970
load netBundle @switch 16 switch[15] switch[14] switch[13] switch[12] switch[11] switch[10] switch[9] switch[8] switch[7] switch[6] switch[5] switch[4] switch[3] switch[2] switch[1] switch[0] -autobundled
netbloc @switch 1 0 3 NJ 7920 NJ 7920 370
load netBundle @a_7_segment 8 a_7_segment[7] a_7_segment[6] a_7_segment[5] a_7_segment[4] a_7_segment[3] a_7_segment[2] a_7_segment[1] a_7_segment[0] -autobundled
netbloc @a_7_segment 1 5 1 7970 2290n
load netBundle @c_7_segment 8 c_7_segment[7] c_7_segment[6] c_7_segment[5] c_7_segment[4] c_7_segment[3] c_7_segment[2] c_7_segment[1] c_7_segment[0] -autobundled
netbloc @c_7_segment 1 5 1 7970 1730n
load netBundle @led 16 led[15] led[14] led[13] led[12] led[11] led[10] led[9] led[8] led[7] led[6] led[5] led[4] led[3] led[2] led[1] led[0] -autobundled
netbloc @led 1 5 1 7970 2850n
load netBundle @search_inst/p_0_in 9 search_inst/p_0_in[10] search_inst/p_0_in[9] search_inst/p_0_in[8] search_inst/p_0_in[7] search_inst/p_0_in[6] search_inst/p_0_in[5] search_inst/p_0_in[4] search_inst/p_0_in[3] search_inst/p_0_in[2] -autobundled
netbloc @search_inst/p_0_in 1 2 3 390 4410 760J 5878 7210
load netBundle @JA_IBUF__0 4 JA_IBUF__0[4] JA_IBUF__0[3] JA_IBUF__0[2] JA_IBUF__0[1] -autobundled
netbloc @JA_IBUF__0 1 4 1 7470 1080n
load netBundle @JA_IBUF 4 JA_IBUF[10] JA_IBUF[9] JA_IBUF[8] JA_IBUF[7] -autobundled
netbloc @JA_IBUF 1 3 1 1400 320n
load netBundle @switch_IBUF 16 switch_IBUF[15] switch_IBUF[14] switch_IBUF[13] switch_IBUF[12] switch_IBUF[11] switch_IBUF[10] switch_IBUF[9] switch_IBUF[8] switch_IBUF[7] switch_IBUF[6] switch_IBUF[5] switch_IBUF[4] switch_IBUF[3] switch_IBUF[2] switch_IBUF[1] switch_IBUF[0] -autobundled
netbloc @switch_IBUF 1 3 1 1500 4848n
levelinfo -pg 1 0 40 190 530 1760 7750 7990
levelinfo -hier core_inst * 2150 2830 4230 6230 *
pagesize -pg 1 -db -bbox -sgen -150 0 8160 9010
pagesize -hier core_inst -db -bbox -sgen 1760 2308 6970 4918
show
zoom 0.175644
scrollpos 165 292
#
# initialize ictrl to current module top_core work:top_core:NOFILE
ictrl init topinfo |
