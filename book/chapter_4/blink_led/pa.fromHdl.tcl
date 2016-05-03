
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name blink_led -dir "E:/cq/papilio/ise/blink_led/planAhead_run_2" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "blink_led.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {blink_led.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top blink_led $srcset
add_files [list {blink_led.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
