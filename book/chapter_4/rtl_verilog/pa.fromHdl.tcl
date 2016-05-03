
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name rtl_verilog -dir "E:/cq/papilio/ise/rtl_verilog/planAhead_run_1" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "rtl_verilog.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {rtl_verilog.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top rtl_verilog $srcset
add_files [list {rtl_verilog.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
