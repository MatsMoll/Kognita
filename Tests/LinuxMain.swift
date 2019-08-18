#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(SubjectTests.allTests),
    testCase(UserTests.allTests),
])

#endif
