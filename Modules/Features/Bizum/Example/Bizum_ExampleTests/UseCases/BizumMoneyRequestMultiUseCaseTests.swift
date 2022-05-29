//
//  BizumValidateMoneyRequestUseCaseTests.swift
//  Bizum_ExampleTests
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import QuickSetupES
import UnitTestCommons
import CoreFoundationLib
@testable import Bizum
@testable import SANLibraryV3
@testable import SANLegacyLibrary

class BizumMoneyRequestMultiUseCaseTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }

    override func setUp() {
        self.dependencies.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
        _ = quickSetup.getGlobalPosition()
    }
    
    override func tearDown() {
        quickSetup.setDemoAnswers([:])
    }

    // MARK: - Common
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
    
    func getBizumPersonalInformation() -> PersonalInformationEntity {
        let personBasicDataDto = PersonBasicDataDTO(mainAddress: "",
                                                    addressNodes: [],
                                                    documentType: .NIF,
                                                    documentNumber: "22563321A",
                                                    birthDate: Date(),
                                                    phoneNumber: "+34765123456",
                                                    contactHourFrom: Date(),
                                                    contactHourTo: Date(),
                                                    email: "")
        return PersonalInformationEntity(personBasicDataDto)
    }
    
    func bizumUseCase(answers: [String: Int]) throws -> UseCaseResponse<BizumRequestMoneyMultiUseCaseOkOutput, StringErrorOutput> {
        quickSetup.setDemoAnswers(answers)
        let useCase = BizumRequestMoneyMultiUseCase(dependenciesResolver: self.dependencies)
        let action1 = BizumMoneyRequestMultiActionInputParam(operationId: "41234124",
                                                            receiverUserId: "+34678574637",
                                                            action: "SOLICITAR")
        let action2 = BizumMoneyRequestMultiActionInputParam(operationId: "234213441234124",
                                                            receiverUserId: "+34777888999",
                                                            action: "SOLICITAR")
        let input = BizumRequestMoneyMultiUseCaseInput(checkPayment: getBizumCheckPayment(),
                                                       document: BizumDocumentEntity(personBasicData: getBizumPersonalInformation().dto),
                                                       dateTime: Date(),
                                                       concept: "concept",
                                                       amount: "4.56",
                                                       operationId: "24351245234523452345",
                                                       actions: [action1, action2])
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    // MARK: - Tests
    func testMoneyRequestMultiUseCaseOKResponse() throws {
        let response = try self.bizumUseCase(answers: ["money-request-multi": 0])
        guard response.isOkResult else {
            XCTFail("BizumValidateMoneyRequestUseCase: Response is not ok")
            return
        }
    }
    
    func testMoneyRequestMultiUseCaseError() throws {
        let response = try self.bizumUseCase(answers: ["money-request-multi": 1])
        guard response.isOkResult == false else {
            XCTFail("BizumOperationUseCase: Response is ok")
            return
        }
    }
}
