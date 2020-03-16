export BUILD_TYPE=LOCAL
swift package generate-xcodeproj
python set-xcodeproj-env.py
sleep 1
open Kognita.xcodeproj/
