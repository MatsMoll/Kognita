#!/usr/bin/env bash

git clone https://github.com/namolnad/Finch.git
cd Finch
git checkout 0.2.0
echo "Installing Finch"
make install
echo "Installed Finch"
cd ..
rm -rf Finch
