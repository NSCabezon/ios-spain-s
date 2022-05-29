//
//  BizumDocumentUseCaseTests.swift
//  Bizum_ExampleTests
//
//  Created by José Carlos Estela Anguita on 18/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import CoreFoundationLib
import QuickSetup
import QuickSetupES
@testable import SANLibraryV3
@testable import Bizum
@testable import SANLegacyLibrary
@testable import Bizum_Example

struct BizumDocumentUseCaseMock: BizumGetDocumentUseCaseProtocol {
    let dependenciesResolver: DependenciesResolver
}

final class BizumDocumentUseCaseTests: XCTestCase {
    
    var dependencies: DependenciesDefault!
    var useCase: BizumDocumentUseCaseMock!
    var appConfig = BizumAppConfigRepositoryMock()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    
    override func setUp() {
        super.setUp()
        self.dependencies = DependenciesDefault()
        self.setupDependencies()
        self.useCase = BizumDocumentUseCaseMock(dependenciesResolver: self.dependencies)
        self.quickSetup.doLogin(withUser: .demo)
    }
    
    override func tearDown() {
        super.tearDown()
        self.dependencies = nil
        self.useCase = nil
        self.quickSetup.setDemoAnswers([:])
    }
    
    func test_bizumGetDocument_shouldReturnRedsysDocument_whenAppConfigIsEnabled_andRedsysReponseIsCorrect() throws {
        // G
        self.appConfig.setConfiguration(["enableBizumRedsysDocumentID": true])
        self.quickSetup.setDemoAnswers(
            [
            "customer-inquiry": 0,
            "consultarDBasicos": 0
            ]
        )
        // W
        let document = try self.useCase.getDocumentWithCheckPayment(getBizumCheckPayment())
        // T
        XCTAssertTrue(document?.code == "25998260A", document?.code ?? "")
        XCTAssertTrue(document?.type == "N", document?.type ?? "")
    }
    
    func test_bizumGetDocument_shouldReturnPersonalDataDocument_whenAppConfigIsEnabled_andRedsysReponseIsNotCorrect() throws {
        // G
        self.appConfig.setConfiguration(["enableBizumRedsysDocumentID": true])
        self.quickSetup.setDemoAnswers(
            [
            "customer-inquiry": 1,
            "consultarDBasicos": 0
            ]
        )
        // W
        let document = try self.useCase.getDocumentWithCheckPayment(getBizumCheckPayment())
        // T
        XCTAssertTrue(document?.code == "41853185Q", document?.code ?? "No code")
        XCTAssertTrue(document?.type == "N", document?.type ?? "No type")
    }
    
    func test_bizumGetDocument_shouldReturnPersonalDataDocument_whenAppConfigIsDisabled() throws {
        // G
        self.appConfig.setConfiguration(["enableBizumRedsysDocumentID": false])
        self.quickSetup.setDemoAnswers(
            [
            "consultarDBasicos": 0
            ]
        )
        // W
        let document = try self.useCase.getDocumentWithCheckPayment(getBizumCheckPayment())
        // T
        XCTAssertTrue(document?.code == "41853185Q", document?.code ?? "")
        XCTAssertTrue(document?.type == "N", document?.type ?? "")
    }
    
    func test_bizumGetDocument_shouldReturnNil_whenAppConfigIsDisabled_andPersonalDataResponseIsNotCorrect() throws {
        // G
        self.appConfig.setConfiguration(["enableBizumRedsysDocumentID": false])
        self.quickSetup.setDemoAnswers(
            [
            "consultarDBasicos": 1
            ]
        )
        // W
        let document = try self.useCase.getDocumentWithCheckPayment(getBizumCheckPayment())
        // T
        XCTAssertTrue(document?.code == nil, document?.code ?? "")
        XCTAssertTrue(document?.type == nil, document?.type ?? "")
    }
}

private extension BizumDocumentUseCaseTests {
    func setupDependencies() {
        self.dependencies.register(for: BSANManagersProvider.self) { _ in
            return self.quickSetup.managersProvider
        }
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return self.appConfig
        }
    }
    
    func getBizumCheckPayment() -> BizumCheckPaymentEntity {
        let centerDTO = CentroDTO(empresa: "",
                                  centro: "")
        let bizumCheckPaymentContractDTO = BizumCheckPaymentContractDTO(center: centerDTO,
                                                                        subGroup: "",
                                                                        contractNumber: "")
        let ibanDTO = BizumCheckPaymentIBANDTO(country: "",
                                               controlDigit: "",
                                               codbban: "")
        let bizumCheckPaymentDTO = BizumCheckPaymentDTO(phone: "",
                                                        contractIdentifier: bizumCheckPaymentContractDTO,
                                                        initialDate: Date(),
                                                        endDate: Date(),
                                                        back: nil,
                                                        message: nil, ibanCode: ibanDTO,
                                                        offset: nil,
                                                        offsetState: nil,
                                                        indMigrad: "",
                                                        xpan: "")
        return BizumCheckPaymentEntity(bizumCheckPaymentDTO)
    }
}
