# sim_bootvec.tcl - Vivado Tcl simulation script for boot vector debug
# Run: D:/Xilinx/Vivado/2023.2/bin/vivado.bat -mode batch -source sim_bootvec.tcl

set proj_name "sim_bootvec"
set proj_dir "./sim_bootvec_project"
set soc_root "C:/Users/16084/Documents/New project/e203_hbirdv2"
set rtl_root "$soc_root/rtl/e203"
set tb_file "./tb_bootvec.v"

# Create project
if {[file exists $proj_dir]} { file delete -force $proj_dir }
create_project $proj_name $proj_dir -part xc7a100tfgg484-2

# Add all Verilog source files from RTL
set rtl_files [glob -nocomplain -directory $rtl_root -types f *.v]
if {[llength $rtl_files] == 0} {
  # Search recursively
  set rtl_dirs [glob -nocomplain -directory $rtl_root -types d *]
  foreach dir $rtl_dirs {
    set sub_files [glob -nocomplain -directory $dir -types f *.v]
    lappend rtl_files {*}$sub_files
    set sub2_dirs [glob -nocomplain -directory $dir -types d *]
    foreach sub2 $sub2_dirs {
      set sub2_files [glob -nocomplain -directory $sub2 -types f *.v]
      lappend rtl_files {*}$sub2_files
    }
  }
}
puts "Found [llength $rtl_files] RTL source files"
add_files -norecurse $rtl_files

# Add include directories
set include_dirs [list $rtl_root/core $rtl_root/perips $rtl_root/soc $rtl_root/subsys $rtl_root/mems $rtl_root/debug $rtl_root/fab $rtl_root/general]
foreach d $include_dirs {
  if {[file isdirectory $d]} {
    set_property include_dirs $d [current_fileset]
    puts "Include dir: $d"
  }
}

# Define FPGA_SOURCE and E203_FORCE_BOOTROM_BOOT
set_property verilog_define {FPGA_SOURCE E203_FORCE_BOOTROM_BOOT} [get_filesets sim_1]

# Set top module
set_property top tb_bootvec [get_filesets sim_1]

# Add testbench
add_files -fileset sim_1 -norecurse $tb_file

# Run simulation for 100 us
set_property -name {xsim.simulate.runtime} -value {100us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

puts "Launching simulation..."
launch_simulation
puts "Simulation done."
