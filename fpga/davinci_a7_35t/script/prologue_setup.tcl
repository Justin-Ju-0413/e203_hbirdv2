set origin_dir [pwd]
set basedir $::env(BASEDIR)
set scriptdir [file normalize [file dirname [info script]]]
source [file join $scriptdir board.tcl]
set srcdir [file dirname [file normalize $::env(VSRCS)]]
set ipdir [file normalize [file join $origin_dir .ip_user_files]]
file mkdir obj
create_project -force $name $origin_dir/obj -part $part_fpga
set_property top system [current_fileset]
add_files -norecurse $::env(VSRCS)
if {[info exists ::env(EXTRA_VSRCS)] && $::env(EXTRA_VSRCS) ne ""} {
  add_files -norecurse $::env(EXTRA_VSRCS)
}
add_files -fileset constrs_1 [glob -nocomplain [file join $origin_dir constrs *.xdc]]
