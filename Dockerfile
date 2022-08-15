FROM ubuntu:20.04 
#pkg-config-aarch64-linux-gnu is not available on 22.04

USER root

ARG ARM="arm64"
ARG GCC_VER="10.3.0"
ARG OS_TYPE="bullseye"

ENV FLUTTER_ENGINE_SHA="37f9852034729e0ab0f52bf913294e833ff1ec55" \
    FLUTTER_EMBEDDER_HEADER="/usr/include/flutter_embedder.h" \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    TZ=UTC \
    GCC_VER=$GCC_VER

COPY arm64.toolchain /opt/arm64.toolchain


RUN set -eux; \
    echo ">>>Prepare time zone settings" ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone ;\
    echo ">>>Prepare to sources list" ;\
    sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list > /etc/apt/sources.list.d/ports.list ;\
    sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list ;\
    dpkg --add-architecture arm64 ;\
    apt-get update; \
    apt-get install -y apt-utils ;\
    apt-get install -y ca-certificates gcc make pkg-config-aarch64-linux-gnu gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu cmake wget xz-utils git clang ;\
    apt-get install -y ttf-mscorefonts-installer libc6:arm64 libgl1-mesa-dev:arm64 libgles2-mesa-dev:arm64 libegl1-mesa-dev:arm64 libdrm-dev:arm64 libgbm-dev:arm64 fontconfig libsystemd-dev:arm64 libinput-dev:arm64 libudev-dev:arm64 libxkbcommon-dev:arm64; \
    apt-get install -y --fix-missing libgstreamer1.0-dev:arm64 libgstreamer-plugins-base1.0-dev:arm64 gstreamer1.0-plugins-base:arm64 gstreamer1.0-plugins-good:arm64 gstreamer1.0-plugins-ugly:arm64 gstreamer1.0-libav:arm64 ;\
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* ;\
    echo ">>Download flutter engine" ;\
    git clone https://github.com/ardera/flutter-engine-binaries-for-arm.git ;\
    cd flutter-engine-binaries-for-arm ;\
    git checkout $FLUTTER_ENGINE_SHA ;\
    cp flutter_embedder.h $FLUTTER_EMBEDDER_HEADER ;\
    cp ./$ARM/libflutter_engine.so.* ./$ARM/icudtl.dat /usr/lib ;\
    cd - ;\
    rm -rf flutter-engine-binaries-for-arm ;\
    echo ">>>Install raspberry toolchain" ;\
    cd $HOME ;\
    wget -q "https://sourceforge.net/projects/raspberry-pi-cross-compilers/files/Bonus%20Raspberry%20Pi%20GCC%2064-Bit%20Toolchains/Raspberry%20Pi%20GCC%2064-Bit%20Cross-Compiler%20Toolchains/Bullseye/GCC%20$GCC_VER/cross-gcc-$GCC_VER-pi_64.tar.gz/download" -O cross-gcc-$GCC_VER-pi_64.tar.gz ;\ 
    tar xf cross-gcc-$GCC_VER-pi_64.tar.gz ;\
    mv cross-pi-gcc-$GCC_VER-64 /opt ;\
    rm -rf *.tar.* /tmp/*
