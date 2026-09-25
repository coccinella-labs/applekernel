<p align="center">
  <img src="https://raw.githubusercontent.com/Coccinella-Labs/applekernel/main/.github/assets/thumbnail.png" alt="applekernel" width="100%">
</p>

# applekernel

SAXPY (`Y = aX + Y`) compute example for Apple Silicon GPUs using Metal: a Swift host program (`main.swift`) compiles a Metal compute shader (`kernel.metal`) from source and dispatches it across a million elements.

## Requirements

- macOS with an Apple Silicon (or Metal-capable) GPU
- Swift toolchain (`swiftc`)
- Xcode command line tools for the Metal framework

## Build and Run

```bash
# Compile the host program against the Metal framework
swiftc main.swift -framework Metal -o vector_add

# Run it (reads kernel.metal from the current directory)
./vector_add
```

The program:

1. Creates a default Metal device and a library from `kernel.metal`.
2. Builds the `saxpy` compute pipeline.
3. Fills buffers `X[i] = i` and `Y[i] = i * 2` with scalar `a = 2.0` (shared storage).
4. Dispatches `count` threads in groups of 256, with a bounds check inside the kernel.
5. Reads back and prints sample results plus elapsed time.

Expected output for the sample values: `Y[i] = 2 * i + 2 * i = 4 * i`.

## Files

| File             | Purpose                                              |
|------------------|------------------------------------------------------|
| `main.swift`     | Swift host code: device, buffers, dispatch, readback |
| `kernel.metal`   | Metal compute kernel implementing SAXPY              |
| `install.sh`     | Installs local CI tooling (actionlint, act, gitlab-ci-local, circleci) |
| `post-setup.sh`  | Post-provisioning environment verification           |
| `PROJECT-META.md`| Single source of truth for licensing and SPDX info   |
| `bot/README.md`  | Notes on the automation bot for this repo            |

## CI

The repository exercises three CI systems in parallel:

- **GitHub Actions** (`.github/workflows/ci.yml`): actionlint lint + build and run on `macos-26`.
- **GitLab CI** (`.gitlab-ci.yml`): GitLab Pipeline equivalent.
- **CircleCI** (`.circleci/config.yml`): Circle workflow.

SPDX verification and auto-fix are enforced via `.github/workflows/spdx-check.yml`, `spdx-bot.yml`, and `spdx-autofix.yml`.

## License

MIT — see [LICENSE](LICENSE) and [PROJECT-META.md](PROJECT-META.md) for details and SPDX headers.