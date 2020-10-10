#!/bin/sh -x
set -e

win_openfpgatoolchain_url="https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-20201010/fpga-toolchain-windows_amd64-nightly-20201010.zip"
win_wishbone_tool_url="https://github.com/litex-hub/wishbone-utils/releases/download/v0.6.10/wishbone-tool-v0.6.10-x86_64-pc-windows-gnu.tar.gz"
win_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-w64-mingw32.zip"
win_make_url="https://sourceforge.net/projects/ezwinports/files/make-4.3-without-guile-w32-bin.zip/download"
win_teraterm_url="https://osdn.net/frs/redir.php?m=constant&f=ttssh2%2F71232%2Fteraterm-4.103.zip"

mac_openfpgatoolchain_url="https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-20201010/fpga-toolchain-darwin-nightly-20201010.tar.xz"
mac_wishbone_tool_url="https://github.com/litex-hub/wishbone-utils/releases/download/v0.6.10/wishbone-tool-v0.6.10-x86_64-apple-darwin.tar.gz"
mac_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-apple-darwin.tar.gz"

linux_openfpgatoolchain_url="https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-20201010/fpga-toolchain-linux_x86_64-nightly-20201010.tar.xz"
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
        # Open FPGA toolchain
        wget -O $input/openfpgatoolchain-${ARCH}.zip $win_openfpgatoolchain_url
        unzip $input/openfpgatoolchain-${ARCH}.zip
        mv fpga-toolchain/* $output/

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
        # Open FPGA toolchain
        curl -fsSL $mac_openfpgatoolchain_url | tar xvJf - -C $input
        mv $input/fpga-toolchain/* $output/

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
        # Open FPGA toolchain
        curl -fsSL $linux_openfpgatoolchain_url | tar xvJf - -C $input
        mv $input/fpga-toolchain/* $output/

        # Wishbone Tool
        curl -fsSL $linux_wishbone_tool_url | tar xvzf - -C $output/bin

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.tar.gz $linux_riscv_url
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
