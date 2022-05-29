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

class BizumMoneyRequestUseCaseTests: XCTestCase {
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
    
    func bizumUseCase(answers: [String: Int]) throws -> UseCaseResponse<BizumRequestMoneyUseCaseOkOutput, StringErrorOutput> {
        quickSetup.setDemoAnswers(answers)
        let useCase = BizumRequestMoneyUseCase(dependenciesResolver: self.dependencies)
        let input = BizumRequestMoneyUseCaseInput(checkPayment: getBizumCheckPayment(),
                                                  document: BizumDocumentEntity(personBasicData: getBizumPersonalInformation().dto),
                                                  operationId: "132134123421432341",
                                                  dateTime: Date(),
                                                  concept: "concept",
                                                  amount: "4.56",
                                                  receiverUserId: "+34666777888")
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    // MARK: - Tests
    func testMoneyRequestUseCaseOKResponse() throws {
        let response = try self.bizumUseCase(answers: ["money-request": 0])
        guard response.isOkResult else {
            XCTFail("BizumValidateMoneyRequestUseCase: Response is not ok")
            return
        }
    }
    
    func testMoneyRequestUseCaseErrorParsing() throws {
        let response = try self.bizumUseCase(answers: ["money-request": 1])
        guard response.isOkResult == false else {
            XCTFail("BizumOperationUseCase: Response is ok")
            return
        }
    }
    
    func testMoneyRequestUseCaseErrorCode() throws {
        let response = try self.bizumUseCase(answers: ["money-request": 2])
        guard response.isOkResult == false else {
            XCTFail("BizumOperationUseCase: Response is ok")
            return
        }
    }
}
