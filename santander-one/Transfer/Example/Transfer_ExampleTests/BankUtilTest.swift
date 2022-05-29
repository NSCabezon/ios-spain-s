//
//  BankUtilTest.swift
//  Transfer_ExampleTests
//
//  Created by Boris Chirino Fernandez on 19/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
import CoreTestData

class BankUtilTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var ibansSepa: [String]?
    private var ibansNoSepa: [String]?
    private lazy var bankingUtils: BankingUtilsProtocol = {
        dependenciesResolver.resolve()
    }()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.defaultRegistration()
        self.setupDependencies()
    }

    func test_check_digit_from_BBAN_SEPA() {
        self.ibansSepa?.forEach({ (fullIBAN) in
            let cCode = fullIBAN.prefix(2).description
            bankingUtils.setCountryCode(cCode)

            let checkDigit = fullIBAN.substring(2, 4)
            let bban = fullIBAN.suffix(fullIBAN.count-4).description
                        
            let calculatedCheckDigit = bankingUtils.calculateCheckDigit(bban: bban)
            XCTAssertTrue(checkDigit == calculatedCheckDigit, fullIBAN)
        })
    }
    
    func test_check_digit_from_BBAN_NO_SEPA() {
        self.ibansNoSepa?.forEach({ (fullIBAN) in
            let countryCode = fullIBAN.prefix(2).description
            bankingUtils.setCountryCode(countryCode)

            let checkDigit = fullIBAN.substring(2, 4)
            let bban = fullIBAN.suffix(fullIBAN.count-4).description
            let calculatedCheckDigit = bankingUtils.calculateCheckDigit(bban: bban)
            XCTAssertTrue(checkDigit == calculatedCheckDigit, fullIBAN)
        })
    }

    func test_check_digit_from_full_IBAN_SEPA() {
        self.ibansSepa?.forEach({ (fullIBAN) in
            let checkDigit = fullIBAN.substring(2, 4)
            let calculatedCheckDigit = bankingUtils.calculateCheckDigit(originalIBAN: fullIBAN)
            XCTAssertTrue(checkDigit == calculatedCheckDigit, fullIBAN)
        })
    }
    
    func test_check_digit_from_full_IBAN_NO_SEPA() {
        self.ibansNoSepa?.forEach({ (fullIBAN) in
            let checkDigit = fullIBAN.substring(2, 4)
            let calculatedCheckDigit = bankingUtils.calculateCheckDigit(originalIBAN: fullIBAN)
            XCTAssertTrue(checkDigit == calculatedCheckDigit, fullIBAN)
        })
    }

    func test_Norway_account_Lengh() {
        bankingUtils.setCountryCode("NO")
        let bbaLengh = bankingUtils.textInputAttributes.bbaLenght
        XCTAssertEqual(bbaLengh, 11)
    }
    
    func test_Portugal_account_Lengh() {
        bankingUtils.setCountryCode("PT")
        let bbaLengh = bankingUtils.textInputAttributes.bbaLenght
        XCTAssertEqual(bbaLengh, 21)
    }
    
    func test_isValid_account_function_SEPA_NOSEPA() {
        guard let ibansSepa = self.ibansSepa,
              let ibansNoSepa = self.ibansNoSepa else { return }
        let allAccounts: [String] = ibansSepa + ibansNoSepa
        allAccounts.forEach { (account) in
            XCTAssertTrue(bankingUtils.isValidIban(ibanString: account), account)
        }
    }
}

private extension BankUtilTest {
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.transferData.ibansSepa,
            filename: "ibansSepa"
        )
        self.mockDataInjector.register(
            for: \.transferData.ibansNoSepa,
            filename: "ibansNoSepa"
        )
        ibansSepa = self.mockDataInjector.mockDataProvider.transferData.ibansSepa
        ibansNoSepa = self.mockDataInjector.mockDataProvider.transferData.ibansNoSepa
    }
    
    func setupDependencies() {
        self.dependenciesResolver.register(for: BankingUtilsProtocol.self) { dependencies in
            return BankingUtils(dependencies: dependencies)
        }
        self.dependenciesResolver.register(for: LocalAppConfig.self) { _ in
            let localAppConfigMock = LocalAppConfigMock()
            localAppConfigMock.countryCode = "PT"
            return localAppConfigMock
        }
    }
}
