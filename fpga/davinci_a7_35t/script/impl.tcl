launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
file mkdir [file join $origin_dir obj]
file copy -force [get_property BITSTREAM.FILE [get_runs impl_1]] [file join $origin_dir obj system.bit]
