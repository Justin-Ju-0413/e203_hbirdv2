# Branch and Release Strategy

> Snapshot date: 2026-08-12 (Asia/Shanghai)

The FYP is complete. `main` is the maintained landing branch in both public
repositories. Reproducibility is expressed through immutable, same-name Release
tags; older engineering branches remain available as historical snapshots.

## Maintained Entry

| Repository | Branch | Role | Daily development |
|---|---|---|---|
| `e203_hbirdv2` | `main` | Documentation, CI, and release navigation | Maintenance only |
| `riscv_cnn_accelerator` | `main` | Documentation, CI, and release navigation | Maintenance only |

## Reproducible Paired Releases

| Milestone | SoC tag | Accelerator tag | Claim boundary |
|---|---|---|---|
| Recovered FYP environment | `env-baseline-2026-07-27` | `env-baseline-2026-07-27` | Minimal CNN v1 and recorded pre-board gates |
| MPhil NICE v2 PoC | `mphil-nice-v2-poc-v0.1.0` | `mphil-nice-v2-poc-v0.1.0` | Bounded `CAP`/`MLOAD`/`MSTAT` experiment |

CI compares and tests matching tags. It never validates a Release tag against
a mutable branch. Historical failed Release workflow runs from 2026-08-01 used
the older branch-selection pattern; direct comparison confirms that each
same-name tag pair contains matching `cnn_nice_core.v` files.

## Retained Branches

- `codex/a7-bringup-v2-soc` ↔ `codex/a7-bringup-v2-main`: retained A7-100T
  engineering snapshot.
- `codex/env-baseline-20260727-soc` ↔ `codex/env-baseline-20260727`: retained
  environment-recovery work branches.
- `codex/mphil-tensor-scan-20260729-soc` ↔
  `codex/mphil-tensor-scan-20260729`: retained MPhil PoC work branches.
- Other `codex/*` branches remain for traceability until a separately approved
  cleanup.

No retained branch or immutable tag is deleted, rewritten, or promoted by this
policy. Before new engineering work, create a new branch from the intended
milestone and document its exact paired ref.

## Claim Boundaries

- `5.282x` refers only to the recorded 3x3 convolution-kernel cycle test.
- `10/10` refers only to the recorded FPGA sample demonstration.
- The MPhil PoC does not claim tiled GEMM, DMA, `MEXEC`, `MSTORE`, complete
  Vision Mamba, or full MNIST acceleration.
- Vivado, UART, JTAG, ILA, and physical-board results are not current unless a
  new evidence package explicitly revalidates them.
