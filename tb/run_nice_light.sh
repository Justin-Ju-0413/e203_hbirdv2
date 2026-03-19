#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_OUT="/tmp/tb_e203_nice_light.vvp"

iverilog -g2005-sv -DDISABLE_SV_ASSERTION=1 \
  -I "${ROOT_DIR}/rtl/e203/core" \
  -o "${BUILD_OUT}" \
  "${ROOT_DIR}/tb/tb_e203_nice_light.v" \
  "${ROOT_DIR}/rtl/e203/core/e203_exu_nice.v" \
  "${ROOT_DIR}/rtl/e203/subsys/e203_subsys_nice_core.v" \
  "${ROOT_DIR}/rtl/e203/subsys/cnn_nice_core.v" \
  "${ROOT_DIR}/rtl/e203/subsys/pe.v" \
  "${ROOT_DIR}/rtl/e203/subsys/pe_array.v" \
  "${ROOT_DIR}/rtl/e203/general/sirv_gnrl_bufs.v" \
  "${ROOT_DIR}/rtl/e203/general/sirv_gnrl_dffs.v"

(
  cd /tmp
  ./tb_e203_nice_light.vvp
)
