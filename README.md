# Introduction

This repo is a fairly minimal reproducer, extracted from a much more complex
project, for a bug that I think may have something to do with `crane` overly
eagerly removing or not propagating a source file that is needed to build a
dependency.

# Steps to reproduce

```
nix develop
cargo build --release --target wasm32-unknown-unknown
```

succeeds, while

```
nix build -L
```

fails, reporting errors that look like:

```
   Compiling dioxus-core-macro v0.2.1 (https://github.com/DioxusLabs/dioxus#937eb1f0)
error: couldn't read /nix/store/v0ma6i0w9gw3yx0n6z61ccwxfbbwil5c-vendor-cargo-deps/12f4c2e376400bb0a06b69e4db142cda662d762af841434168c3d532a02f3d1f/dioxus-core-macro-0.2.1/>
  --> /nix/store/v0ma6i0w9gw3yx0n6z61ccwxfbbwil5c-vendor-cargo-deps/12f4c2e376400bb0a06b69e4db142cda662d762af841434168c3d532a02f3d1f/dioxus-core-macro-0.2.1/src/lib.rs:32:9
   |
32 | #[doc = include_str!("../../../examples/rsx_usage.rs")]
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: this error originates in the macro `include_str` (in Nightly builds, run with -Z macro-backtrace for more info)

error: couldn't read /nix/store/v0ma6i0w9gw3yx0n6z61ccwxfbbwil5c-vendor-cargo-deps/12f4c2e376400bb0a06b69e4db142cda662d762af841434168c3d532a02f3d1f/dioxus-core-macro-0.2.1/>
  --> /nix/store/v0ma6i0w9gw3yx0n6z61ccwxfbbwil5c-vendor-cargo-deps/12f4c2e376400bb0a06b69e4db142cda662d762af841434168c3d532a02f3d1f/dioxus-core-macro-0.2.1/src/lib.rs:48:9
   |
48 | #[doc = include_str!("../../../examples/rsx_usage.rs")]
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: this error originates in the macro `include_str` (in Nightly builds, run with -Z macro-backtrace for more info)

error: could not compile `dioxus-core-macro` due to 2 previous errors
warning: build failed, waiting for other jobs to finish...
```

# Expected behavior

```
nix build
```

should succeed.
