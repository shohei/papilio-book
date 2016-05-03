
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name stopwatch_top -dir "D:/home/yokomizo/CQ/desigin/FPGA/stopwatch_top/planAhead_run_2" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "stopwatch_top.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {src/chattering_cut.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {src/stopwatch.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {src/sevenseg_ctrl.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {src/stopwatch_top.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top stopwatch_top $srcset
add_files [list {stopwatch_top.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
