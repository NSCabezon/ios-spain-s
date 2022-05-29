//
//  RetailLegacy_ExampleTests.swift
//  RetailLegacy_ExampleTests
//
//  Created by José María Jiménez Pérez on 21/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import RetailLegacy
import CoreFoundationLib

class NumberFormatterPlusFormatsTests: XCTestCase {
    
    let input: [Decimal] = [0, 1.23432, 19.98, 1000, 1000.456, 10000, 10000.456, 1000000, 1000000.442, 12345678, 12345678.657, -1.23432, -19.98, -1000, -1000.456, -10000, -10000.456, -1000000, -1000000.442, -12345678, -12345678.657]
    
    func test_formatWith1M() {
        let expectedOutput = ["0,000", "1,234", "19,980", "1.000,000", "1.000,456", "10.000,000", "10.000,456", "1.000.000,000", "1.000.000,442", "12.345.678,000", "12.345.678,657", "−1,234", "−19,980", "−1.000,000", "−1.000,456", "−10.000,000", "−10.000,456", "−1.000.000,000", "−1.000.000,442", "−12.345.678,000", "−12.345.678,657"
        ]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.with1M).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_descriptionPFMFormat() {
        let expectedOutput = ["0,00", "1,23", "19,98", "1.000,00", "1.000,46", "10.000,00", "10.000,46", "1.000.000,00", "1.000.000,44", "12.345.678,00", "12.345.678,66", "-1,23", "-19,98", "-1.000,00", "-1.000,46", "-10.000,00", "-10.000,46", "-1.000.000,00", "-1.000.000,44", "-12.345.678,00", "-12.345.678,66"
        ]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.descriptionPFM()).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_descriptionPFMFormatNoDecimals() {
        let expectedOutput = ["0", "1", "20", "1.000", "1.000", "10.000", "10.000", "1.000.000", "1.000.000",
                              "12.345.678", "12.345.679", "-1", "-20", "-1.000", "-1.000", "-10.000", "-10.000",
                              "-1.000.000", "-1.000.000", "-12.345.678", "-12.345.679"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.descriptionPFM(decimals: 0)).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_descriptionFormat() {
        let expectedOutput = ["0,00", "1,23", "19,98", "1.000,00", "1.000,46", "10.000,00",
                               "10.000,46", "1.000.000,00", "1.000.000,44", "12.345.678,00", "12.345.678,66",
                               "-1,23", "-19,98", "-1.000,00", "-1.000,46", "-10.000,00", "-10.000,46",
                               "-1.000.000,00", "-1.000.000,44", "-12.345.678,00", "-12.345.678,66"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.description()).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_descriptionFormatNoDecimals() {
        let expectedOutput = ["0", "1", "20", "1.000", "1.000", "10.000", "10.000", "1.000.000",
                               "1.000.000", "12.345.678", "12.345.679", "-1", "-20", "-1.000", "-1.000", "-10.000",
                               "-10.000", "-1.000.000", "-1.000.000", "-12.345.678", "-12.345.679"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.description(decimals: 0)).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_decimalFormat() {
        let expectedOutput = ["0,00", "1,23", "19,98", "1.000,00", "1.000,46", "10.000,00",
                              "10.000,46", "1.000.000,00", "1.000.000,44", "12.345.678,00", "12.345.678,66",
                              "−1,23", "−19,98", "−1.000,00", "−1.000,46", "−10.000,00", "−10.000,46", "−1.000.000,00",
                              "−1.000.000,44", "−12.345.678,00", "−12.345.678,66"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.decimal()).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_decimalFormatNoDecimals() {
        for (index, decimal) in input.enumerated() {
            let expectedOutput = ["0", "1", "20", "1.000", "1.000", "10.000", "10.000", "1.000.000",
                                  "1.000.000", "12.345.678", "12.345.679", "−1", "−20", "−1.000", "−1.000",
                                  "−10.000", "−10.000", "−1.000.000", "−1.000.000", "−12.345.678", "−12.345.679"]
            XCTAssertTrue(formatterForRepresentation(.decimal(decimals: 0)).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_wholePart() {
        let expectedOutput = ["0.0000000000", "1.2343200000", "19.9800000000", "1,000.0000000000", "1,000.4560000000",
                              "10,000.0000000000", "10,000.4560000000", "1,000,000.0000000000", "1,000,000.4420000000",
                              "12,345,678.0000000000", "12,345,678.6569999974", "−1.2343200000", "−19.9800000000",
                              "−1,000.0000000000", "−1,000.4560000000", "−10,000.0000000000", "−10,000.4560000000",
                              "−1,000,000.0000000000", "−1,000,000.4420000000", "−12,345,678.0000000000", "−12,345,678.6569999974"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.wholePart).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_decimalSmartFormat() {
        let expectedOutput = ["0", "1,23", "19,98", "1.000", "1.000,46", "10.000", "10.000,46",
                              "1.000.000", "1.000.000,44", "12.345.678", "12.345.678,66", "−1,23",
                              "−19,98", "−1.000", "−1.000,46", "−10.000", "−10.000,46", "−1.000.000",
                              "−1.000.000,44", "−12.345.678", "−12.345.678,66"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.decimalSmart()).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
    
    func test_decimalTrackerFormat() {
        let expectedOutput = ["0.00", "1.23", "19.98", "1000.00", "1000.46", "10000.00", "10000.46", "1000000.00",
                              "1000000.44", "12345678.00", "12345678.66", "-1.23", "-19.98", "-1000.00",
                              "-1000.46", "-10000.00", "-10000.46", "-1000000.00", "-1000000.44",
                              "-12345678.00", "-12345678.66"]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(formatterForRepresentation(.decimalTracker()).string(from: NSDecimalNumber(decimal: decimal)) ?? "0" == expectedOutput[index])
        }
    }
}

class DecimalPlusFormatTests: XCTestCase {
    let input: [Decimal] = [0, 1.23432, 19.98, 1000, 1000.456, 10000, 10000.456, 1000000, 1000000.442, 12345678, 12345678.657, -1.23432, -19.98, -1000, -1000.456, -10000, -10000.456, -1000000, -1000000.442, -12345678, -12345678.657]
    func test_getFormattedAmountUIWith1M() {
        let expectedOutput = ["0,00€", "1,23€", "19,98€", "1.000,00€", "1.000,46€", "10.000,00€", "10.000,46€", "1,000M €", "1,000M €", "12,346M €", "12,346M €", "−1,23€", "−19,98€", "−1.000,00€", "−1.000,46€", "−10.000,00€", "−10.000,46€", "−1.000.000,00€", "−1.000.000,44€", "−12.345.678,00€", "−12.345.678,66€"
        ]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(decimal.getFormattedAmountUIWith1M(currencySymbol: "€") == expectedOutput[index])
        }
    }
    
    func test_getFormattedAmountUI() {
        let expectedOutput = ["0,00€", "1,23€", "19,98€", "1.000,00€", "1.000,46€", "10.000,00€", "10.000,46€", "1,000M €", "1,000M €", "12,346M €", "12,346M €", "−1,23€", "−19,98€", "−1.000,00€", "−1.000,46€", "−10.000,00€", "−10.000,46€", "−1.000.000,00€", "−1.000.000,44€", "−12.345.678,00€", "−12.345.678,66€"
            ]
        for (index, decimal) in input.enumerated() {
            XCTAssertTrue(decimal.getFormattedAmountUIWith1M(currencySymbol: "€") == expectedOutput[index])
        }
    }
}
