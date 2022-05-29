//
//  BizumAcceptRequestMoneySignatureUseCaseTests.swift
//  Bizum_ExampleTests
//
//  Created by Carlos Monfort Gómez on 21/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import QuickSetupES
@testable import SANLibraryV3
@testable import SANLegacyLibrary
import CoreFoundationLib
@testable import Bizum

final class BizumAcceptRequestMoneySignatureUseCaseTests: XCTestCase {
    private let dependencies = DependenciesDefault()
    private let appConfig = AppConfigRepositoryMock()
    private var useCase: BizumAcceptRequestMoneySignatureUseCase {
        return BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: self.dependencies)
    }
    private var checkPayment: BizumCheckPaymentEntity!
    private var signatureWithToken: SignatureWithTokenEntity!
    private var amount: AmountEntity!
    private var numberOfRecipients: Int!
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        return QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.enviromentPreWas9, user: .demo)
    }
    
    override func setUp() {
        self.setupDependencies()
        self.setBizumCheckPaymentEntity()
        self.numberOfRecipients = 0
    }
    
    override func tearDown() {
        super.tearDown()
        self.quickSetup.setDemoAnswers([:])
    }
    
    func test_useCase_given_an_incorrect_amount_then_result_is_an_error() {
        // G
        self.setSignatureWithTokenError()
        self.amount = AmountEntity(AmountDTO())
        // W
        let input = BizumAcceptRequestMoneySignatureUseCaseInput(checkPayment: self.checkPayment,
                                                                 signatureWithToken: self.signatureWithToken,
                                                                 amount: self.amount,
                                                                 numberOfRecipients: self.numberOfRecipients,
                                                                 account: nil)
        let useCase = BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: self.dependencies)
        let response = try? useCase.executeUseCase(requestValues: input).getErrorResult()
        // T
        XCTAssertNotNil(response)
    }
    
    func test_useCase_given_an_correct_signature_then_result_is_OK() {
        // G
        self.setSignatureWithToken()
        self.amount = AmountEntity(value: 10.0)
        // W
        let input = BizumAcceptRequestMoneySignatureUseCaseInput(checkPayment: self.checkPayment,
                                                                 signatureWithToken: self.signatureWithToken,
                                                                 amount: self.amount,
                                                                 numberOfRecipients: self.numberOfRecipients,
                                                                 account: nil)
        let useCase = BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: self.dependencies)
        let response = try? useCase.executeUseCase(requestValues: input)
        // T
        XCTAssertNotNil(response?.isOkResult)
    }
    
    func test_useCase_given_a_service_unexpected_error_then_result_is_an_error() {
        // G
        self.setSignatureWithTokenError()
        self.amount = AmountEntity(value: 10.0)
        self.quickSetup.setDemoAnswers(["validate-money-transfer-otp": 1])
        // W
        let input = BizumAcceptRequestMoneySignatureUseCaseInput(checkPayment: self.checkPayment,
                                                                 signatureWithToken: self.signatureWithToken,
                                                                 amount: self.amount,
                                                                 numberOfRecipients: self.numberOfRecipients,
                                                                 account: nil)
        let useCase = BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: self.dependencies)
        let response = try? useCase.executeUseCase(requestValues: input).getErrorResult()
        // T
        XCTAssertNotNil(response)
    }
    
    func test_useCase_given_an_invalid_signature_then_result_is_an_error() {
        // G
        self.setSignatureWithTokenError()
        self.amount = AmountEntity(value: 10.0)
        self.quickSetup.setDemoAnswers(["validate-money-transfer-otp": 2])
        // W
        let input = BizumAcceptRequestMoneySignatureUseCaseInput(checkPayment: self.checkPayment,
                                                                 signatureWithToken: self.signatureWithToken,
                                                                 amount: self.amount,
                                                                 numberOfRecipients: self.numberOfRecipients,
                                                                 account: nil)
        let useCase = BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: self.dependencies)
        let response = try? useCase.executeUseCase(requestValues: input).getErrorResult()
        // T
        XCTAssertTrue(response?.getErrorDesc() == "La clave de firma introducida es errónea. Por favor, vuelva a introducir su firma.")
    }
}

private extension BizumAcceptRequestMoneySignatureUseCaseTests {
    func setupDependencies() {
        self.dependencies.register(for: AppRepositoryProtocol.self) { _  in
            return AppRepositoryMock()
        }
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _  in
            return self.appConfig
        }
        self.dependencies.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        self.dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return self.quickSetup.getGlobalPosition()!
        }
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver,
                                                         globalPosition: globalPosition,
                                                         saveUserPreferences: true)
            return merger
        }
        self.quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        self.quickSetup.doLogin(withUser: .demo)
    }
    
    func setBizumCheckPaymentEntity() {
        let centerDTO = CentroDTO(empresa: "", centro: "")
        let contractIdentifier = BizumCheckPaymentContractDTO(center: centerDTO, subGroup: "", contractNumber: "")
        let checkPaymentIbanDTO = BizumCheckPaymentIBANDTO(country: "", controlDigit: "", codbban: "")
        let checkPaymentDTO = BizumCheckPaymentDTO(
            phone: "",
            contractIdentifier: contractIdentifier,
            initialDate: Date(),
            endDate: Date(),
            back: nil,
            message: nil,
            ibanCode: checkPaymentIbanDTO,
            offset: nil,
            offsetState: nil,
            indMigrad: "",
            xpan: ""
        )
        self.checkPayment = BizumCheckPaymentEntity(checkPaymentDTO)
    }
    
    func setSignatureWithToken() {
        let signatureDTO = SignatureDTO(length: 8, positions: [1, 2, 3, 4])
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureDTO, magicPhrase: nil)
        self.signatureWithToken = SignatureWithTokenEntity(signatureWithTokenDTO)
    }
    
    func setSignatureWithTokenError() {
        let signatureDTO = SignatureDTO(length: 8, positions: [])
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureDTO, magicPhrase: nil)
        self.signatureWithToken = SignatureWithTokenEntity(signatureWithTokenDTO)
    }
}
