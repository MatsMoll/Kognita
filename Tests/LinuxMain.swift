#if os(Linux)

import XCTest
@testable import AppTests

XCTMain(
    AppTests.allTests()
)

#endif
