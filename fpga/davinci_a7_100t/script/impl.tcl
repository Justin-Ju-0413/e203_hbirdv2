launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
file mkdir [file join $origin_dir obj]
set bitfile [get_property BITSTREAM.FILE [get_runs impl_1]]
if {$bitfile eq "" || ![file exists $bitfile]} {
  set bitfile [file join $origin_dir obj ${name}.runs impl_1 system.bit]
}
if {![file exists $bitfile]} {
  set bit_candidates [glob -nocomplain -directory [file join $origin_dir obj ${name}.runs impl_1] *.bit]
  if {[llength $bit_candidates] > 0} {
    set bitfile [lindex $bit_candidates 0]
  }
}
if {![file exists $bitfile]} {
  error "bitstream file not found after write_bitstream"
}
file copy -force $bitfile [file join $origin_dir obj system.bit]
