#!/bin/bash

# From the old ethos toolchain

set -e

NCORES=$(nproc)

patch_binutils() {
    # Extract the clean sources
    echo "Extracting binutils..."
    cd clean/
    tar -xzvf binutils-2.45.gz
    cd ../

    # Patch binutils
    echo "Patching binutils..."
    mkdir -p dirty/
    cp -r clean/clean/* dirty/
    patch -s -p0 < patches/binutils-2.45.patch
    rm -rf clean/clean/
}

patch_gcc() {
    rm -rf dirty/
    echo "Extracting gcc..."
    cd clean/
    tar -xvf gcc-13.4.0.tar.xz
    cd ../

    # Patch it
    echo "Patching gcc..."
    mkdir -p dirty/
    cp -r clean/gcc-13.4.0/ dirty/
    patch -s -p0 < patches/gcc-13.4.0.patch

    rm -rf dirty/gcc-13.4.0/ dirty/
    mv clean/gcc-13.4.0 gcc-patched
}

build_binutils() {
    mkdir -p build-binutils/
    cd build-binutils
    ../dirty/binutils-2.45/configure --target=x86_64-pc-lunota --prefix=$(pwd);
    make -j$(NCORES)
    make install

    cd ../
    echo "[?] binutils is in build-binutils/"
}

# Clean everything up
echo "Cleaning up..."
rm -rf clean/clean build/ dirty/

patch_binutils

# Build binutils
echo "Building binutils"
build_binutils

patch_gcc
echo "gcc requires manual build in gcc-patched/"
