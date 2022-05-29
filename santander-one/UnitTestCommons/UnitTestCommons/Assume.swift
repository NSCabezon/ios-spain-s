//
//  Assume.swift
//  UnitTestCommons
//
//  Created by Boris Chirino Fernandez on 20/11/2020.
//

import XCTest

//MARK: - Assume
/**
    Create and return an expectation that is fulfilled when SpyableObject change and the expected value are equal to spying. Use this class when you need evaluate more than 1 expectation.
    
    Example:
    ~~~
        //create an expectation
        let expectation1 = Assume(spying: self.view.spy_askedForSettings, expectedValue: false)
        let expectation2 = Assume(spying: self.view.spy_askedForSettings, expectedValue: false)

        //modify inspected variables
        self.presenter.viewWillAppear()
 
        //set the wait for the desired time
        wait(for: [expectation1, expectation2], timeout: 2)
    ~~~
 
    Important: set the timeout to a number of seconds for the major of the asyncrounous task
 */
final public class Assume: XCTestExpectation {
    /**
     Create and return an expectation that is fulfilled when SpyableObject change and the expected value are equal to spying.
     - Parameter spying: the vobject to be observed
     - Parameter expectedValue: the value you´re expecting to be equal to spying
     */
    public init<Value: Equatable>(spying: SpyableObject<Value>, expectedValue: Value, file: StaticString = #file, line: Int = #line ) {
        super.init(description: Assume.description(forSpy: spying, file: file, line: line))
        self.assertForOverFulfill = true
        guard expectedValue != spying.value else {
               self.fulfill()
            return
        }
        spying.onChange  = { result in
            guard result == expectedValue else { return }
            self.fulfill()
        }
    }
}

//MARK: - XCTestCase
public extension XCTestCase {
    /**
     Creates an expectation that is fulfilled when SpyableObject change and the expected value are equal to spying
     - Parameter spying: the variable on yout mocked class that need to be verifyed
     - Parameter expectedValue: the value you´re expecting to be equal to spying
        ~~~
           // create the assumed hipothezis
           waitForAssume(spying: self.mockedInstance.mySpyVar, expectedValue: true)
           // change the value
           self.mockedInstance.mySpyVar = true
           // wait the time you want 
           waitForExpectations(timeout: 10)
        ~~~
     */

    func waitForAssume<Value: Equatable>(spying: SpyableObject<Value>, expectedValue: Value, timeout: TimeInterval = 1) {
        let wrapper = Assume(spying: spying, expectedValue: expectedValue)
        wrapper.assertForOverFulfill = true
        wait(for: [wrapper], timeout: timeout)
    }
}

private extension Assume {
    static func description<Value:Equatable>(forSpy spy:SpyableObject<Value>) -> String {
        return "– Assume expectation  – spiedValue: \(spy.value) \(Unmanaged.passUnretained(spy).toOpaque().debugDescription)"
    }
    
    static func description<Value:Equatable>(forSpy spy:SpyableObject<Value>, file: StaticString = #file, line: Int = #line ) -> String {
        return "– Assume expectation  - file: \(file), line: \(line)"
    }
}
