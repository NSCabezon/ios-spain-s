//
//  CoreFoundationLibTests.swift
//  CoreFoundationLibTests
//
//  Created by Johann Casique on 20/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import XCTest
@testable import CoreFoundationLib

final class CoreFoundationLibTests: XCTestCase {

    var xmlString: String?

    override func setUp() {
        super.setUp()
        let t = type(of: self)
        let bundle = Bundle(for: t.self)
        guard let url = bundle.url(forResource: "accountsInfo", withExtension: "xml") else {
            XCTFail("error serializing")
            return
        }
        do {
            let d = try Data.init(contentsOf: url)
            xmlString = String(data: d, encoding: .utf8)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testFileIsRead() {
        XCTAssertNotNil(xmlString, "The file couldn't be read.")
    }
    
    func testFileIsParsed() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        let dto = AccountDescriptorParser().serialize(fileContents)
        XCTAssertNotNil(dto, "File parser failed.")
    }

    func testCardsColor() {
        // This is an example of a functional test case.
        let accountdp = AccountDescriptorParser()
        guard let xmlString = self.xmlString else {
            XCTFail("error serializing")
            return
        }
        let descriptorDTO = accountdp.serialize(xmlString)
        XCTAssertNotNil(descriptorDTO, "AccountDescriptorParser failed ... ")
        XCTAssertNotNil(descriptorDTO?.cardsTextColor, "Failed rerializing colors")
        guard let colorsArray = descriptorDTO?.cardsTextColor else {
            XCTFail("colors array nil")
            return
        }
        XCTAssertTrue(colorsArray.count > 0, "Theres no colors on the node or wrong key")
    }
    
    func testAllianzPlans() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssert(!dto.plansArray.isEmpty, "The plans array shouldn't be empty.")
    }
    
    func testChatOneProducts() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssertFalse(dto.chatProducts.isEmpty, "The chat products array shouldn't be empty.")
    }
    
    func testSecurityOneProducts() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssertFalse(dto.securityOneProducts.isEmpty, "The security products array shouldn't be empty.")
    }
    
    func testVIPOneProducts() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssertFalse(dto.vipOneProducts.isEmpty, "The VIP products array shouldn't be empty.")
    }

    func testPaymentOneProducts() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssertFalse(dto.paymentOneProducts.isEmpty, "The payment products array shouldn't be empty.")
    }

    func testAppIcons() {
        guard let fileContents = xmlString else { XCTFail("The file content is nil."); return }
        guard let dto = AccountDescriptorParser().serialize(fileContents) else { XCTFail("File parser failed."); return }
        XCTAssertFalse(dto.appIcons.isEmpty, "The security products array shouldn't be empty.")
    }
}
