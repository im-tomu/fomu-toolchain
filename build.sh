#!/bin/sh -x

win_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.34-fomu/nextpnr-ice40-windows_amd64-v1.34-fomu.zip"
win_icestorm_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.26-fomu/toolchain-icestorm-windows_amd64-v1.26-fomu.zip"
win_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.2.10/wishbone-tool-v0.2.10-x86_64-pc-windows-gnu.tar.gz"
win_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-w64-mingw32.zip"
win_python_url="https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-amd64.zip"
win_make_url="https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip/download"
win_teraterm_url="https://osdn.net/frs/redir.php?m=constant&f=ttssh2%2F71232%2Fteraterm-4.103.zip"

mac_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.34-fomu/nextpnr-ice40-darwin-v1.34-fomu.tar.gz"
mac_icestorm_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.26-fomu/toolchain-icestorm-darwin-v1.26-fomu.tar.gz"
mac_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.2.10/wishbone-tool-v0.2.10-x86_64-apple-darwin.tar.gz"
mac_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-apple-darwin.tar.gz"

linux_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.34-fomu/nextpnr-ice40-linux_x86_64-v1.34-fomu.tar.gz"
linux_icestorm_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.26-fomu/toolchain-icestorm-linux_x86_64-v1.26-fomu.tar.gz"
linux_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.2.10/wishbone-tool-v0.2.10-x86_64-unknown-linux-gnu.tar.gz"
linux_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-centos6.tar.gz"

base="$(pwd)"
output_name="fomu-toolchain-${ARCH}-${TRAVIS_TAG}"
output="${base}/output/${output_name}"
input="${base}/input"
mkdir -p $output
mkdir -p $input
mkdir -p $output/bin

echo "${TRAVIS_TAG}" > $output/VERSION

case "${ARCH}" in
    "windows")
        # Python 3.7.3 (which matches the version in nextpnr)
        wget -O $input/python-${ARCH}.zip $win_python_url
        cd $output/bin
        unzip -o $input/python-${ARCH}.zip
        rm python37.zip # we already have this unzipped from nextpnr-ice40

        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.zip $win_nextpnr_url
        cd $output/bin
        unzip -o $input/nextpnr-${ARCH}.zip

        # Yosys, icestorm, and dfu_util
        wget -O $input/icestorm-${ARCH}.zip $win_icestorm_url
        cd $output
        unzip -o $input/icestorm-${ARCH}.zip

        # Teraterm Terminal
        wget -O $input/teraterm-${ARCH}.zip $win_teraterm_url
        cd $output/bin
        unzip -o $input/teraterm-${ARCH}.zip

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz $win_wishbone_tool_url
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.zip  $win_riscv_url
        cd $input
        mkdir re
        cd re
        unzip -o $input/riscv-${ARCH}.zip
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        # Make.exe
        wget -O $input/make-${ARCH}.zip $win_make_url
        cd $output
        unzip -o $input/make-${ARCH}.zip

        cd $base/output
        zip -r $output_name.zip $output_name
        ;;

    "macos")
        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.tar.gz $mac_nextpnr_url
        cd $output
        tar xvzf $input/nextpnr-${ARCH}.tar.gz

        # Yosys, icestorm, and dfu_util
        wget -O $input/icestorm-${ARCH}.tar.gz $mac_icestorm_url
        cd $output
        tar xvzf $input/icestorm-${ARCH}.tar.gz

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz $mac_wishbone_tool_url
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.tar.gz  $mac_riscv_url
        cd $input
        mkdir re
        cd re
        tar xvzf $input/riscv-${ARCH}.tar.gz
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        cd $base/output
        zip -r $output_name.zip $output_name
        ;;

    "linux_x86_64")
        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.tar.gz $linux_nextpnr_url
        cd $output
        tar xvzf $input/nextpnr-${ARCH}.tar.gz

        # Yosys, icestorm, and dfu_util
        wget -O $input/icestorm-${ARCH}.tar.gz $linux_icestorm_url
        cd $output
        tar xvzf $input/icestorm-${ARCH}.tar.gz

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz $linux_wishbone_tool_url
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.tar.gz  $linux_riscv_url
        cd $input
        mkdir re
        cd re
        tar xvzf $input/riscv-${ARCH}.tar.gz
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        cd $base/output
        tar cvzf $output_name.tar.gz $output_name
        ;;
    *)
        echo "Unrecognized architecture: ${ARCH}"
        echo "Supported architectures: macos, windows, linux_x86_64"
        exit 1
        ;;
esac