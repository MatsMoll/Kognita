#!/usr/bin/env bash

git clone https://github.com/MatsMoll/Finch.git
cd Finch
git checkout bugfix/empty-commit-on-branch-change
make install
cd ..
rm -rf Finch
