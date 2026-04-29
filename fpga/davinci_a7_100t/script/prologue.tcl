set origin_dir [pwd]
set basedir $::env(BASEDIR)
set scriptdir [file normalize [file dirname [info script]]]
source [file join $scriptdir board.tcl]
set srcfiles [split $::env(VSRCS) "\n"]
set srcdir [file normalize [file join $basedir install rtl]]
set ipdir [file normalize [file join $origin_dir .ip_user_files]]
file mkdir obj
create_project -force $name $origin_dir/obj -part $part_fpga
set_property SOURCE_MGMT_MODE None [current_project]
set_property top system [current_fileset]
add_files -norecurse $srcfiles
set_property verilog_define {E203_FORCE_BOOTROM_BOOT FPGA_SOURCE} [get_filesets sources_1]
if {[info exists ::env(EXTRA_VSRCS)] && $::env(EXTRA_VSRCS) ne ""} {
  set extra_srcfiles [split $::env(EXTRA_VSRCS) "\n"]
  add_files -norecurse $extra_srcfiles
}
add_files -fileset constrs_1 [glob -nocomplain [file join $origin_dir constrs *.xdc]]
if {[info exists ::env(EXTRA_XDCS)] && $::env(EXTRA_XDCS) ne ""} {
  set extra_xdcfiles [split $::env(EXTRA_XDCS) "\n"]
  add_files -fileset constrs_1 $extra_xdcfiles
}
