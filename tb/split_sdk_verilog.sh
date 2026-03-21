#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <input.verilog>" >&2
  exit 2
fi

input="$1"
base="${input%.verilog}"
itcm_out="${base}.itcm.verilog"
dtcm_out="${base}.dtcm.verilog"

: > "${itcm_out}"
: > "${dtcm_out}"

awk -v itcm_out="${itcm_out}" -v dtcm_out="${dtcm_out}" '
  BEGIN {
    mode = ""
  }
  /^@/ {
    if ($0 ~ /^@800/) {
      mode = "itcm"
      line = $0
      sub(/^@800/, "@000", line)
      print line >> itcm_out
    } else if ($0 ~ /^@900/) {
      mode = "dtcm"
      line = $0
      sub(/^@900/, "@000", line)
      print line >> dtcm_out
    } else {
      mode = ""
    }
    next
  }
  {
    if (mode == "itcm") {
      print $0 >> itcm_out
    } else if (mode == "dtcm") {
      print $0 >> dtcm_out
    }
  }
' "${input}"

if [[ ! -s "${itcm_out}" ]]; then
  echo "No ITCM records found in ${input}" >&2
  exit 1
fi

echo "Generated:"
echo "  ${itcm_out}"
echo "  ${dtcm_out}"
