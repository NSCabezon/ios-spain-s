//
//  Observable.swift
//  UnitTestCommons
//
//  Created by José Carlos Estela Anguita on 20/1/22.
//

import Foundation
import XCTest

public extension XCTestCase {
    
    func XCTAssertForObservation<Object: NSObject, Value: Equatable>(object: Object, keyPath: KeyPath<Object, Value>, expectedValue: Value) {
        let expectation = XCTestExpectation(description: "Await for observation to complete")
        expectation.assertForOverFulfill = true
        let observable = Observable(object: object, keyPath: keyPath, expectedValue: expectedValue)
        observable.observe {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

private extension XCTestCase {
    
    final class Observable<Object: NSObject, Value: Equatable> {
        
        let object: Object
        let keyPath: KeyPath<Object, Value>
        let expectedValue: Value
        var observation: NSKeyValueObservation?
        
        internal init(object: Object, keyPath: KeyPath<Object, Value>, expectedValue: Value, observation: NSKeyValueObservation? = nil) {
            self.object = object
            self.keyPath = keyPath
            self.expectedValue = expectedValue
            self.observation = observation
        }
            
        func observe(_ completion: @escaping () -> Void) {
            guard object[keyPath: keyPath] != expectedValue else { return completion() }
            observation = object.observe(keyPath, options: .new) { object, change in
                guard object[keyPath: self.keyPath] == self.expectedValue else { return }
                completion()
            }
        }
    }

}
