//
//  DefaultGetPersonalAreaHomeFieldsUseCaseTests.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 21/4/22.
//

import XCTest
import CoreTestData
import CoreFoundationLib
import OpenCombine
import UnitTestCommons
@testable import PersonalArea

class DefaultGetPersonalAreaHomeFieldsUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_given_completeConfiguration_when_fetchFields_then_returnAllDefaultFields() throws {
        let sut = DefaultGetPersonalAreaHomeFieldsUseCase()
        let completeConfig = PersonalAreaHomeMock()
        
        let fields = try sut
            .fetchPersonalAreaHomeFields(completeConfig)
            .sinkAwait()
        
        XCTAssert(fields.count == 5)
    }

    func test_given_digitalProfileDisabled_when_fetchFields_then_responseDoesntContainsDigitalProfileField() throws {
        let sut = DefaultGetPersonalAreaHomeFieldsUseCase()
        let config = PersonalAreaHomeMock(isEnabledDigitalProfileView: false)
        
        let fields = try sut
            .fetchPersonalAreaHomeFields(config)
            .sinkAwait()
        XCTAssert(!fields.contains(where: { $0.goToSection == PersonalAreaSection.digitalProfile }))
    }
    
    func test_given_securityDisabled_when_fetchFields_then_responseDoesntContainsSecurityField() throws {
        let sut = DefaultGetPersonalAreaHomeFieldsUseCase()
        let config = PersonalAreaHomeMock(isPersonalAreaSecuritySettingEnabled: false)
        
        let fields = try sut
            .fetchPersonalAreaHomeFields(config)
            .sinkAwait()
        XCTAssert(!fields.contains(where: { $0.goToSection == PersonalAreaSection.security }))
    }
    
    func test_given_documentationDisabled_when_fetchFields_then_responseDoesntContainsDocumentationField() throws {
        let sut = DefaultGetPersonalAreaHomeFieldsUseCase()
        let config = PersonalAreaHomeMock(isPersonalDocOfferEnabled: false)
        
        let fields = try sut
            .fetchPersonalAreaHomeFields(config)
            .sinkAwait()
        XCTAssert(!fields.contains(where: { $0.goToSection == PersonalAreaSection.documentation }))
    }
    
    func test_given_recoveryDisabled_when_fetchFields_then_responseDoesntContainsRecoveryField() throws {
        let sut = DefaultGetPersonalAreaHomeFieldsUseCase()
        let config = PersonalAreaHomeMock(isRecoveryOfferEnabled: false)
        
        let fields = try sut
            .fetchPersonalAreaHomeFields(config)
            .sinkAwait()
        XCTAssert(!fields.contains(where: { $0.goToSection == PersonalAreaSection.recovery }))
    }
}
