#!/bin/sh -x
set -e

win_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.46-fomu/nextpnr-ice40-windows_amd64-v1.46-fomu.zip"
win_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.43-fomu/toolchain-icestorm-windows_amd64-v1.43-fomu.zip"
win_wishbone_tool_url="https://github.com/litex-hub/wishbone-utils/releases/download/v0.6.10/wishbone-tool-v0.6.10-x86_64-pc-windows-gnu.tar.gz"
win_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-w64-mingw32.zip"
win_python_url="https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-amd64.zip"
win_make_url="https://sourceforge.net/projects/ezwinports/files/make-4.3-without-guile-w32-bin.zip/download"
win_teraterm_url="https://osdn.net/frs/redir.php?m=constant&f=ttssh2%2F71232%2Fteraterm-4.103.zip"

mac_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.46-fomu/nextpnr-ice40-darwin-v1.46-fomu.tar.gz"
mac_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.43-fomu/toolchain-icestorm-darwin-v1.43-fomu.tar.gz"
mac_wishbone_tool_url="https://github.com/litex-hub/wishbone-utils/releases/download/v0.6.10/wishbone-tool-v0.6.10-x86_64-apple-darwin.tar.gz"
mac_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-apple-darwin.tar.gz"

linux_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ice40/releases/download/v1.46-fomu/nextpnr-ice40-linux_x86_64-v1.46-fomu.tar.gz"
linux_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.43-fomu/toolchain-icestorm-linux_x86_64-v1.43-fomu.tar.gz"
linux_wishbone_tool_url="https://github.com/litex-hub/wishbone-utils/releases/download/v0.6.10/wishbone-tool-v0.6.10-x86_64-unknown-linux-gnu.tar.gz"
linux_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-centos6.tar.gz"

base="$(pwd)"
output_name="fomu-toolchain-${ARCH}"
output="${base}/output/${output_name}"
input="${base}/input"

mkdir -p $output
mkdir -p $input
mkdir -p $output/bin

checksum_output() {
    set +x
    hashes="sha1 sha256 sha512"
    local outfile hashfile
    cd "$(dirname $output)"
    outfile=$(basename "$output$1")

    for hash in $hashes ; do
	hashfile=$outfile.$hash
        ${hash}sum $outfile > $hashfile
	echo -n "$hash: " ; cat $hashfile
    done
    set -x
}

extract_zip() {
    wget -O "$2" "$1"
    cd $output"$3"
    unzip -o "$2"
}

case "${ARCH}" in
    "Windows")
        # Python 3.7.3 (which matches the version in nextpnr)
        extract_zip $win_python_url $input/python-${ARCH}.zip  "/bin"
        rm python37.zip # we already have this unzipped from nextpnr-ice40
        rm -f python37._pth # If this file is present, PYTHONPATH is very broken

        # Nextpnr
        extract_zip $win_nextpnr_url $input/nextpnr-${ARCH}.zip "/bin"

        # Yosys, icestorm, and dfu_util
        extract_zip $win_yosys_url $input/yosys-${ARCH}.zip

        # Teraterm Terminal
        extract_zip $win_teraterm_url $input/teraterm-${ARCH}.zip "/bin"

        # Wishbone Tool
        curl -fsSL $win_wishbone_tool_url | tar xvzf - -C $output/bin

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
        zip -r -X $output_name.zip $output_name
        checksum_output .zip
        ;;

    "macOS")
        # Nextpnr
        curl -fsSL $mac_nextpnr_url | tar xvzf - -C $output

        # Yosys, icestorm, and dfu_util
        curl -fsSL $mac_yosys_url | tar xvzf - -C $output

        # Wishbone Tool
        curl -fsSL $mac_wishbone_tool_url | tar xvzf - -C $output/bin

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
        zip -r -X $output_name.zip $output_name
        checksum_output .zip
        ;;

    "Linux")
        # Nextpnr
        curl -fsSL $linux_nextpnr_url | tar xvzf - -C $output

        # Yosys, icestorm, and dfu_util
        curl -fsSL $linux_yosys_url | tar xvzf - -C $output

        # Wishbone Tool
        curl -fsSL $linux_wishbone_tool_url | tar xvzf - -C $output/bin

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

        cd $base/output/
        tar cvzf $output_name.tar.gz $output_name
        checksum_output .tar.gz
        ;;
    *)
        echo "Unrecognized platform: ${ARCH}"
        echo "Supported platforms: MacOS, Windows, Linux"
        exit 1
        ;;
esac

echo "${GITHUB_SHA}" > $output/VERSION

exit 0
