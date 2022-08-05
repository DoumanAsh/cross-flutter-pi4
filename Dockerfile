FROM ubuntu:20.04 
#pkg-config-aarch64-linux-gnu is not available on 22.04

ARG GCC_VER="11.3.0"
ARG PI_VER="4"
ARG OS_TYPE="bullseye"
ARG ARM="arm64"

ENV FLUTTER_ENGINE_SHA="37f9852034729e0ab0f52bf913294e833ff1ec55" \
    FLUTTER_EMBEDDER_HEADER="/usr/include/flutter_embedder.h" \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    TZ=UTC 

RUN set -eux; \
    echo ">>>Prepare time zone settings" ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone ;\
    echo ">>>Prepare to sources list" ;\
    sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list > /etc/apt/sources.list.d/ports.list ;\
    sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list ;\
    dpkg --add-architecture arm64 ;\
    apt-get update; \
    apt-get install -y apt-utils ;\
    apt-get install -y ca-certificates gcc make pkg-config-aarch64-linux-gnu gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu cmake clang; \
    apt-get install -y ttf-mscorefonts-installer libc6:arm64 libgl1-mesa-dev:arm64 libgles2-mesa-dev:arm64 libegl1-mesa-dev:arm64 libdrm-dev:arm64 libgbm-dev:arm64 fontconfig:arm64 libsystemd-dev:arm64 libinput-dev:arm64 libudev-dev:arm64 libxkbcommon-dev:arm64; \
    apt-get install -y --fix-missing libgstreamer1.0-dev:arm64 libgstreamer-plugins-base1.0-dev:arm64 gstreamer1.0-plugins-base:arm64 gstreamer1.0-plugins-good:arm64 gstreamer1.0-plugins-ugly:arm64 gstreamer1.0-libav:arm64 ;\
    apt-get install -y gcc g++ gperf flex texinfo gawk gfortran texinfo bison build-essential openssl unzip wget git pigz libncurses-dev autoconf automake tar figlet rsync ;\
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo ">>Download flutter engine" ;\
    git clone https://github.com/ardera/flutter-engine-binaries-for-arm.git ;\
    cd flutter-engine-binaries-for-arm ;\
    git checkout $FLUTTER_ENGINE_SHA ;\
    cp flutter_embedder.h $FLUTTER_EMBEDDER_HEADER ;\
    cp ./$ARM/libflutter_engine.so.* ./$ARM/icudtl.dat /usr/lib ;\
    cd - ;\
    rm -rf flutter-engine-binaries-for-arm ;\
    echo ">>>Install raspberry toolchain" ;\
    git clone https://github.com/DoumanAsh/raspberry-pi-cross-compilers.git --depth 1 --single-branch -b glib_rm_fix ;\
    cd raspberry-pi-cross-compilers/build-scripts ;\
    chmod 777 RTBuilder_64b ;\
    bash RTBuilder_64b -g $GCC_VER -o $OS_TYPE ;\
    cd - ;\
    rm -rf raspberry-pi-cross-compilers ;\
    cd $HOME ;\
    tar xf cross-gcc-$GCC_VER-pi_64 ;\
    mv cross-gcc-$GCC_VER-pi_64 /opt ;\
    ln -s /usr/lib/aarch64-linux-gnu /opt/cross-pi-gcc-$GCC_VER-64/aarch64-linux-gnu/usr/lib/aarch64-linux-gnu ;\
    mv /opt/cross-gcc-$GCC_VER-pi_64/aarch64-linux-gnu/libc/lib /opt/cross-gcc-$GCC_VER-pi_64/ ;\
    mv /opt/cross-gcc-$GCC_VER-pi_64/aarch64-linux-gnu/libc/lib64 /opt/cross-gcc-$GCC_VER-pi_64/ ;\
    mv /opt/cross-gcc-$GCC_VER-pi_64/aarch64-linux-gnu/libc/* /opt/cross-gcc-$GCC_VER-pi_64/ ;\
    rm -rf *.tar.gz /tmp/*

COPY arm64.toolchain /opt
