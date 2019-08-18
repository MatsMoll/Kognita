commit: 
	xcodebuild -scheme Run test | xcpretty
	git add .
	git commit -m"$(msg)"
	git push

test: 
	xcodebuild \
	-scheme Run \
	-derivedDataPath DerivedData \
	-destination "platform=OS X" \
	-enableCodeCoverage YES \
	test | xcpretty

	sleep 1

	xcrun llvm-cov show \
	-format=html \
	-instr-profile DerivedData/Build/ProfileData/$(shell ls DerivedData/Build/ProfileData)/Coverage.profdata \
	DerivedData/Build/Products/Debug/App.framework/Versions/A/App Sources/App > coverage.html
	open coverage.html