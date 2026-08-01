# Paired release record

The tags `env-baseline-2026-07-27` and `mphil-nice-v2-poc-v0.1.0` are meaningful only as cross-repository pairs. Each GitHub Release must state:

- this repository's branch and immutable commit SHA;
- the paired `riscv_cnn_accelerator` branch and immutable commit SHA;
- CI run links and whether RTL equality was checked;
- Full-SoC, Vivado, UART, JTAG, ILA, and board status;
- that funct7 `0-5` remains compatible and CAP/MLOAD/MSTAT is experimental;
- that tiled GEMM, DMA, MEXEC, MSTORE, complete Vision Mamba, and complete MNIST acceleration are not completed claims.

Fill final SHAs only after the stacked PRs merge. Existing tags are immutable; publish a new patch version rather than moving a tag.
