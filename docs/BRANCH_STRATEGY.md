# Branch Strategy

> Snapshot date: 2026-07-29 (Asia/Singapore)

This file mirrors the branch policy in the paired accelerator repository. The
default branches and validated engineering branches have diverged, so the
current maintenance work targets the engineering pair and does not merge or
force-update `main`.

## Current Branches

| Repository | Branch | Role | Use for new engineering work |
|------------|--------|------|------------------------------|
| `riscv_cnn_accelerator` | `main` | Default historical line | No |
| `riscv_cnn_accelerator` | `bringup_v1` | Retained stable milestone | Recovery/reporting only |
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | Validated FYP engineering baseline | Yes |
| `riscv_cnn_accelerator` | `codex/mphil-tensor-scan-20260729` | MPhil data-movement research | Yes, research only |
| `e203_hbirdv2` | `main` | Default/upstream-oriented line | No |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | Validated paired SoC baseline | Yes |
| `e203_hbirdv2` | `codex/mphil-tensor-scan-20260729-soc` | Paired MPhil SoC research | Yes, research only |

The former SoC branches `master` and `cnn_bringup_v1` no longer exist on
GitHub. Do not recreate them merely to satisfy old documentation.

## Active Pair

- Accelerator: `codex/a7-bringup-v2-main`
- SoC: `codex/a7-bringup-v2-soc`

The pair contains the A7-100T bring-up, CNN/NICE board evidence, and the NICE
`rs2` index-capture fix.

## 2026-07-27 Maintenance Branches

- Accelerator: `codex/env-baseline-20260727`
- SoC: `codex/env-baseline-20260727-soc`

Both branches are documentation/environment maintenance branches. Their Draft
PRs target the active engineering branches, not `main`.

## 2026-07-29 MPhil Research Branches

- Accelerator: `codex/mphil-tensor-scan-20260729`
- SoC: `codex/mphil-tensor-scan-20260729-soc`

These branches are based on the environment baselines. They introduce the first
compatible NICE v2 ICB-to-scratchpad proof of concept. Legacy funct7 `0–5`,
the E203 decoder fix, FPGA RTL, and board constraints remain unchanged.

Recorded compatibility result: original 19 RTL tests, `LIGHT_PASS`,
`PHASE4_PASS` with `RSTAT=19`, and `PREBOARD_PASS`. The new memory path has
standalone directed coverage; Full-SoC NICE v2 software, synthesis, Vivado, and
physical-board validation remain future gates.

## Rules

- Do not modify `rtl/e203/core/e203_exu_decode.v` in the environment-baseline
  PR.
- Do not change FPGA RTL, NICE command encoding, or software-visible behavior.
- Keep generated bitstreams, MCS files, simulator dumps, and transient memory
  initialization headers out of maintenance commits.
- Stage only explicit files.
- Keep the paired branch names in accelerator and SoC documentation aligned.
- Treat Vivado and a physical-board rerun as optional gates for the current
  Ubuntu 24.04 WSL2 reproducibility pass.

## Future Promotion

Promotion of the active pair to stable/default branches is a separate release
task. It requires full cross-repository review, complete regressions, and an
explicit resolution of the diverged `main` commits.
