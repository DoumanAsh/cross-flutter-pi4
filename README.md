# cross-flutter-pi4

[![Docker](https://github.com/DoumanAsh/cross-flutter-pi4/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/DoumanAsh/cross-flutter-pi4/actions/workflows/docker-image.yml)

Cross compilation image to build [flutter-pi](https://github.com/ardera/flutter-pi) for pi4

## Usage

- Pull [cross-flutter-pi4](https://hub.docker.com/repository/docker/douman/cross-flutter-pi4)
- Configure cmake using `cmake <cmake file folder> -DCMAKE_TOOLCHAIN_FILE=/opt/arm64.toolchain`
- Build `cmake --build <cmake build folder>`
