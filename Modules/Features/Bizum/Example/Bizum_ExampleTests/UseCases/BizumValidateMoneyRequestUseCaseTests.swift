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

class BizumValidateMoneyRequestUseCaseTests: XCTestCase {
    private let dependenciesResolver =  DependenciesDefault()
    private var globalPosition: GlobalPositionRepresentable?
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    
    override func setUp() {
        self.setupDependencies()
        self.quickSetup.doLogin(withUser: .demo)
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }
    
    override func tearDown() {
        self.globalPosition = nil
    }
    
    // MARK: - Common
    func setupDependencies() {
        dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            guard let globalPosition = self.globalPosition else {
                self.globalPosition = self.quickSetup.getGlobalPosition()
                return self.globalPosition!
            }
            return globalPosition
        }
        self.dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
        self.dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            return self.quickSetup.managersProvider
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
    
    func bizumUseCase(answers: [String: Int]) throws -> UseCaseResponse<BizumValidateRequestMoneyUseCaseOkOutput, StringErrorOutput> {
        self.quickSetup.setDemoAnswers(answers)
        let useCase = BizumValidateRequestMoneyUseCase(dependenciesResolver: self.dependenciesResolver)
        let input = BizumValidateRequestMoneyUseCaseInput(checkPayment: getBizumCheckPayment(),
                                                          document: BizumDocumentEntity(personBasicData: getBizumPersonalInformation().dto),
                                                          dateTime: Date(),
                                                          concept: "Concept",
                                                          amount: "24.56",
                                                          receiverUserId: "+34675847323")
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func testBizumValidateMoneyRequestUseCaseUserIsRegistered() {
        do {
            let response = try self.bizumUseCase(answers: ["validate-money-request": 0])
            guard response.isOkResult else {
                XCTFail("BizumValidateMoneyRequestUseCase: Response is not ok")
                return
            }
            _ = try response.getOkResult()
            XCTAssert(true)
        } catch {
            XCTFail("BizumValidateMoneyRequestUseCase: throw")
        }
    }
    
    func testBizumValidateMoneyRequestUseCaseUserIsNotRegistered() {
        do {
            let response = try self.bizumUseCase(answers: ["validate-money-request": 1])
            guard response.isOkResult else {
                XCTFail("BizumValidateMoneyRequestUseCase: Response is not ok")
                return
            }
            _ = try response.getOkResult()
            XCTAssert(true)
        } catch {
            XCTFail("BizumValidateMoneyRequestUseCase: throw")
        }
    }
    
    func testFailResponse() {
        do {
            let response = try self.bizumUseCase(answers: ["validate-money-request": 2])
            guard response.isOkResult == false else {
                XCTFail("BizumOperationUseCase: Response is ok")
                return
            }
            let data = try response.getErrorResult()
            XCTAssert(data.getErrorDesc() == "Se ha producido un error", "BizumOperationUseCase: Incorrect error description")
        } catch {
            XCTFail("BizumOperationUseCase: throw")
        }
    }
}
