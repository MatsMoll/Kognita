//
//  KognitaTests.swift
//  AppTests
//
//  Created by Mats Mollestad on 8/31/19.
//
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MultipleChoiseTaskTests.allTests),
        testCase(PracticeSessionTests.allTests),
        testCase(SubjectTests.allTests),
        testCase(TopicTests.allTests),
        testCase(UserTests.allTests)
    ]
}
#endif
