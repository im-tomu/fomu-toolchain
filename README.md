# Fomu Toolchain

[Fomu](https://github.com/im-tomu/fomu-hardware) ([fomu.im](https://fomu.im)) is an FPGA in your USB port.  This repository gathers all the tools you will need to develop for Fomu, and provides them as prebuilt packages for GNU/Linux, Windows or macOS.

## Usage

Download the [latest release](https://github.com/im-tomu/fomu-toolchain/releases/latest) for your platform and extract it somewhere on your disk.  Then set your PATH:

* Shell (GNU/Linux, Cygwin/MSYS2/MINGW, MacOS...): `export PATH=[path-to-bin]:$PATH`
* Powershell (Windows): `$ENV:PATH = "[path-to-bin];" + $ENV:PATH`
* cmd.exe (Windows): `PATH=[path-to-bin];%PATH%`

To confirm installation, run a command such as `nextpnr-ice40` or `yosys`.

## What's included

Prebuilt packages contain _almost_ everything you'll need for developing software and/or hardware on Fomu:

* [open-tool-forge/fpga-toolchain](https://github.com/open-tool-forge/fpga-toolchain):
  * **yosys** -- synthesis
  * **ghdl-yosys-plugin** -- VHDL frontend for *Yosys*
  * **nextpnr** -- place-and-route
  * **dfu-util** -- upload bitstream to the FPGA
  * Find the list of all tools at [open-tool-forge/fpga-toolchain: Introduction](https://github.com/open-tool-forge/fpga-toolchain#introduction).
* Extras, specific for Fomu:
  * **riscv-gcc** -- compile code for RISC-V CPUs, such as the Fomu softcore
  * **wishbone-tool** -- access the debug bus on Fomu
  * The Windows version includes `make` and `teraterm`.

NOTE: *fpga-toolchain* includes an internal *lib/python3.8* interpreter to be used by *nextpnr*. However, users should install a Python interpreter on their system for using *LiteX* or other Python based hardware description/design tools.

It is strongly recommended that you install `git` for managing repositories and checking out code, though it is not strictly necessary.
