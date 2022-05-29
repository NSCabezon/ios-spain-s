//
//  KVOPublisher+test.swift
//  OpenKitTests
//
//  Created by Juan Carlos López Robles on 3/21/22.
//

import XCTest
import UIKit
import OpenCombine
import UI

class KVOPublisherTest: XCTestCase {
    var subscription = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        subscription.removeAll()
    }

    func test_Given_UILabel_When_textValueChange_Then_getTheDefaultValue() throws {
        let expected: String? = nil
        var value: String? = ""
        let label = UILabel()
        label.publisher(keyPath: \.text)
            .sink { value = $0 }
            .store(in: &subscription)
        XCTAssertEqual(expected, value)
    }
    
    func test_Given_UILabel_When_textValueChange_Then_getTheNewValue() throws {
        let expected = "Expected text"
        var value: String? = ""
        let label = UILabel()
        label.publisher(keyPath: \.text, options: [.new])
            .sink { value = $0 }
            .store(in: &subscription)
        label.text = "Expected text"
        XCTAssertEqual(expected, value)
    }
}
