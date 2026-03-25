set out_mcs [lindex $argv 0]
set in_bit [lindex $argv 1]
set flashed_program [lindex $argv 2]
write_cfgmem -force -format mcs -size 16 -interface SPIx4 \
  -loadbit "up 0x00000000 $in_bit" \
  $out_mcs
