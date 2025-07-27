<div align="center">

# ![LOGO](raw/logo.svg) FreeEta

[![Crates.io](https://img.shields.io/crates/v/FreeEta.svg)](https://crates.io/crates/FreeEta)
![GitHub License](https://img.shields.io/github/license/Administroot/FreeEta)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/Administroot/FreeEta-gd/freeeta-ci.yml)
![Static Badge](https://img.shields.io/badge/Powered_By-Godot-blue)

A fast, elegant & free `Event Tree Analysis`(ETA) utility powered by 🤖 Godot and 🦀 Rust.

<img alt="FreeEta" src="raw/showcase.gif" width="70%">

</div>

## Overview

FreeEta project include three sub-projects.

- [ETACTL](rust/etactl/README.md): A terminal utility to perform Event Tree Analysis without GUI interface, much suitable for large event tree analysis.
- [ETALIB](rust/etalib/README.md): The support library of `ETADOT`, written in `Rust`.
- [ETADOT](EtaDot/README.md): The GUI analysis tool to perform Event Tree Analysis.

If you don't know which one to use, I suggest execute `EtaDot.console` in artifacts, which will perform verbose hints.

## Installation

> [!danger]
> FreeEta is on flight🛫

FreeEta is in development. You could download artifacts from [github workflow](https://github.com/Administroot/FreeEta-gd/actions).

Or, you could build it yourself! Follow these steps below.

> [!IMPORTANT]
> [Godot](https://godotengine.org/) and [Rust](https://www.rust-lang.org/) are required.

```shell
git clone https://github.com/Administroot/FreeEta-gd.git
cd FreeEta-gd/

# Build `ETACTL` and `ETALIB`
cd rust/
cargo build && cargo build --release

# Build `ETADOT`
cd ../EtaDot/
godot --headless --import
godot --headless --export-release "EtaDot-{{YOUR-PLATFORM-ARCH}}" "EtaDot" --verbose
```

<a href="https://github.com/Administroot/FreeEta-gd/releases">
  <img src="raw/get_it_on_github.svg" alt="Get it on Github" width="200"/>
</a>

Support ALL Platforms!

## Version

0.1.0-dev
