#!/usr/bin/env bash

set -e -x

packages=(
    qt5-default

    qtscript5-dev
    qttools5-dev
    qttools5-dev-tools

    libqt5x11extras5-dev

    libqt5svg5-dev
    libqt5svg5

    # web plugin
    libqt5webkit5-dev

    # fixes some issues on X11
    libxfixes-dev
    libxtst-dev

    # KDE Frameworks
    libkf5notifications-dev
    extra-cmake-modules

    # encryption plugin
    gnupg2

    # tests
    xvfb
    openbox
)

sudo apt-get install "${packages[@]}"

# Coveralls
pip install --user 'urllib3[secure]' cpp-coveralls
