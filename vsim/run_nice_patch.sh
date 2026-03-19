#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSIM_DIR="${ROOT_DIR}/vsim"
ASCII_GUARD="${ROOT_DIR}"
TESTCASE="${TESTCASE:-${ROOT_DIR}/riscv-tools/riscv-tests/isa/generated/rv32ui-p-simple}"
PATCHCASE="${PATCHCASE:-${ROOT_DIR}/tb/nice_dot320_patch}"
SIM_TOOL="${SIM_TOOL:-iverilog}"
DUMPWAVE="${DUMPWAVE:-0}"
RST_RELEASE="${RST_RELEASE:-120}"
RUN_TIMEOUT="${RUN_TIMEOUT:-30}"
EXTRA_PLUSARGS="${EXTRA_PLUSARGS:-}"

if printf '%s' "${ASCII_GUARD}" | LC_ALL=C grep -q '[^ -~]'; then
  echo "[FULLSOC_ERROR] workspace path must be ASCII: ${ASCII_GUARD}" >&2
  exit 2
fi

cd "${VSIM_DIR}"
make clean
make install
make compile SIM="${SIM_TOOL}"

set +e
timeout "${RUN_TIMEOUT}" make run_test \
  SIM="${SIM_TOOL}" \
  DUMPWAVE="${DUMPWAVE}" \
  TESTCASE="${TESTCASE}" \
  PATCHCASE="${PATCHCASE}" \
  RUN_PLUSARGS_EXTRA="+RST_RELEASE=${RST_RELEASE} ${EXTRA_PLUSARGS}"
run_rc=$?
set -e

latest_log="$(find "${VSIM_DIR}/run" -maxdepth 2 -name 'rv32ui-p-add.log' | head -n 1 || true)"
if [[ -n "${latest_log}" ]]; then
  echo "[FULLSOC_LOG] ${latest_log}"
  if ! grep -E '\[PC\]|\[NICE_REQ\]|\[NICE_RSP\]|\[NICE_SUMMARY\]|TEST_PASS|TEST_FAIL' "${latest_log}"; then
    echo "[FULLSOC_TAIL]"
    tail -n 20 "${latest_log}" || true
  fi
fi

if [[ ${run_rc} -eq 124 ]]; then
  echo "[FULLSOC_TIMEOUT] run exceeded ${RUN_TIMEOUT}s before closure"
  exit 124
fi

exit "${run_rc}"
