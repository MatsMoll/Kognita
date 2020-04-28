#!/usr/bin/env bash

git clone https://github.com/realm/SwiftLint.git
cd SwiftLint
git checkout 0.39.2
swift build -c release --static-swift-stdlib --build-path /usr/local/bin/swiftlint
cd ..
rm -rf SwiftLint
