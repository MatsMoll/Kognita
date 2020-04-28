#!/usr/bin/env bash

git clone https://github.com/realm/SwiftLint.git
cd SwiftLint
git checkout 0.39.2
swift build -c release --static-swift-stdlib
mv .build/x86_64-unknown-linux/release/swiftlint /usr/local/bin/
cd ..
rm -rf SwiftLint
