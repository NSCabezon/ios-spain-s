//
//  AmoutUICurrencyTest.swift
//  RetailLegacy_ExampleTests
//
//  Created by José María Jiménez Pérez on 21/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import RetailLegacy

class AmoutUICurrencyTest: XCTestCase {
    
    func test_thousands() {
        let amount = Amount.createWith(value: 1000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "1.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "1.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "1.000,00")
        XCTAssertTrue(amount.wholePart == "1,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "1.000,00")
    }
    
    func test_thousands_negative() {
        let amount = Amount.createWith(value: -1000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "\u{2212}1.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "\u{2212}1.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "1.000,00€")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "-1.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "-1.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "-1.000,00")
        XCTAssertTrue(amount.wholePart == "\u{2212}1,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "1.000,00")
    }
    
    func test_ten_thousands() {
        let amount = Amount.createWith(value: 10000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "10.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "10.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "10.000,00")
        XCTAssertTrue(amount.wholePart == "10,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "10.000,00")
    }
    
    func test_ten_thousands_negative() {
        let amount = Amount.createWith(value: -10000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "\u{2212}10.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "\u{2212}10.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "10.000,00€")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "-10.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "-10.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "-10.000,00")
        XCTAssertTrue(amount.wholePart == "\u{2212}10,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "10.000,00")
    }
    
    func test_one_million() {
        let amount = Amount.createWith(value: 1000000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "1.000.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "1.000.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "1,000M €")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "1,000M €")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "1.000.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "1.000.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "1.000.000,00")
        XCTAssertTrue(amount.wholePart == "1,000,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "1.000.000,00")
    }
    
    func test_one_million_negative() {
        let amount = Amount.createWith(value: -1000000)
        XCTAssertTrue(amount.getFormattedAmountUI() == "\u{2212}1.000.000,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "1.000.000,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "\u{2212}1,000M €")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "1,000M €")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "-1.000.000,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "-1.000.000,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "-1.000.000,00")
        XCTAssertTrue(amount.wholePart == "\u{2212}1,000,000")
        XCTAssertTrue(amount.getAbsFormattedValue() == "1.000.000,00")
    }
    
    func test_more_than_one_million() {
        let amount = Amount.createWith(value: 12345678)
        XCTAssertTrue(amount.getFormattedAmountUI() == "12.345.678,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "12.345.678,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "12,346M €")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "12,346M €")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "12.345.678,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "12.345.678,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "12.345.678,00")
        XCTAssertTrue(amount.wholePart == "12,345,678")
        XCTAssertTrue(amount.getAbsFormattedValue() == "12.345.678,00")
    }
    
    func test_more_than_one_million_negative() {
        let amount = Amount.createWith(value: -12345678)
        XCTAssertTrue(amount.getFormattedAmountUI() == "\u{2212}12.345.678,00€")
        XCTAssertTrue(amount.getAbsFormattedAmountUI() == "12.345.678,00€")
        XCTAssertTrue(amount.getFormattedAmountUIWith1M() == "\u{2212}12,346M €")
        XCTAssertTrue(amount.getAbsFormattedAmountUIWith1M() == "12,346M €")
        XCTAssertTrue(amount.getFormattedDescriptionAmount() == "-12.345.678,00€")
        XCTAssertTrue(amount.getFormattedPFMAmount() == "-12.345.678,00€")
        XCTAssertTrue(amount.getFormattedPFMDescriptionValue(2) == "-12.345.678,00")
        XCTAssertTrue(amount.wholePart == "\u{2212}12,345,678")
        XCTAssertTrue(amount.getAbsFormattedValue() == "12.345.678,00")
    }
}
