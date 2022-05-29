//
//  AssertPublishers.swift
//  UnitTestCommons
//
//  Created by José Carlos Estela Anguita on 10/1/22.
//

import Foundation
import OpenCombine
import XCTest

extension XCTestCase {
    public func XCTAssertForPublisher<T: Publisher>(_ publisher: T, output: T.Output) where T.Output: Equatable {
        let expectation = XCTestExpectation(description: "Await for publisher to complete")
        expectation.assertForOverFulfill = true
        let operation = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { result in
                guard result == output else { return }
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 1.0)
        operation.cancel()
    }

    public func XCTAssertForPublisher<T: Publisher>(_ publisher: T, assert: @escaping (T.Output) -> Bool) {
        let expectation = XCTestExpectation(description: "Await for publisher to complete")
        expectation.assertForOverFulfill = true
        let operation = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { result in
                guard assert(result) else { return }
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 1.0)
        operation.cancel()
    }
    
    public func XCTAssertForPublisher<T: Publisher>(_ publisher: T, toEventuallyNot output: T.Output) where T.Output: Equatable {
        let expectation = XCTestExpectation(description: "Await for publisher to complete")
        expectation.assertForOverFulfill = true
        let operation = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { result in
                guard output == result else { return }
                expectation.fulfill()
            })
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssert(true)
        } else {
            XCTFail("Assertion fails because the publisher receives the value: \(output)")
        }
        operation.cancel()
    }
}


