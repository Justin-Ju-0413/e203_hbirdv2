set origin_dir [pwd]
set basedir $::env(BASEDIR)
set scriptdir [file normalize [file dirname [info script]]]
source [file join $scriptdir board.tcl]
set srcfiles $::env(VSRCS)
set srcdir [file normalize [file join $basedir install rtl]]
set ipdir [file normalize [file join $origin_dir .ip_user_files]]
file mkdir obj
create_project -force $name $origin_dir/obj -part $part_fpga
set_property top system [current_fileset]
add_files -norecurse {*}$srcfiles
if {[info exists ::env(EXTRA_VSRCS)] && $::env(EXTRA_VSRCS) ne ""} {
  set extra_srcfiles $::env(EXTRA_VSRCS)
  add_files -norecurse {*}$extra_srcfiles
}
add_files -fileset constrs_1 [glob -nocomplain [file join $origin_dir constrs *.xdc]]
