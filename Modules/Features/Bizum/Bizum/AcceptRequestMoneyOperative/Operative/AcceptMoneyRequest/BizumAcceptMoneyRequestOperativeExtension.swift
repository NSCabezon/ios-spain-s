//
//  BizumAcceptMoneyRequestOperativeExtension.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 01/12/2020.
//

import Foundation
import CoreFoundationLib
import Operative

extension BizumAcceptMoneyRequestOperative {
    func setupDependencies() {
        self.setupOperative()
        self.setupConfirmation()
        self.setupSignature()
        self.setupOtp()
        self.setSummary()
    }

    func buildSteps() {
        self.steps.append(BizumAcceptRequestMoneyConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(BizumAcceptRequestSumaryStep(dependenciesResolver: dependencies))
    }
    
    func setupSignature() {
        self.dependencies.register(for: BizumAcceptRequestMoneySignatureUseCase.self) { resolver in
            BizumAcceptRequestMoneySignatureUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupOtp() {
        self.dependencies.register(for: BizumAcceptRequestMoneyOTPUseCase.self) { resolver in
            BizumAcceptRequestMoneyOTPUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetMultimediaUsersUseCase.self) { resolver in
            GetMultimediaUsersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaSimpleUseCase.self) { resolver in
            SendMultimediaSimpleUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupOperative() {
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { resolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SetupBizumAcceptRequestMoneyUseCase.self) { resolver in
            SetupBizumAcceptRequestMoneyUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupConfirmation() {
        self.dependencies.register(for: SignPosSendMoneyUseCase.self) { resolver in
            SignPosSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumAcceptRequestMoneyConfirmationPresenterProtocol.self) { resolver in
            BizumAcceptRequestMoneyConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumAcceptRequestMoneyConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumAcceptRequestMoneyConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumAcceptRequestMoneyConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumAcceptRequestMoneyConfirmationPresenterProtocol.self)
            let viewController = BizumAcceptRequestMoneyConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setSummary() {
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: BizumAcceptRequestSummaryPresenterProtocol.self) { resolver in
            return BizumAcceptRequestSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumAcceptRequestSummaryPresenterProtocol.self)
            let viewController = BizumAcceptRequestViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeFinishingCoordinatorCapable {}

extension BizumAcceptMoneyRequestOperative: OperativeSetupCapable, BizumCommonSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        let useCase = SetupBizumAcceptRequestMoneyUseCase(dependenciesResolver: self.dependencies)
        let useCaseInput = SetupBizumAcceptRequestMoneyUseCaseOkInput(bizumCheckPaymentEntity: self.operativeData.bizumCheckPaymentEntity)
        let scenario = Scenario(useCase: useCase, input: useCaseInput)
        self.bizumSetupWithScenario(scenario) { [weak self] result in
            self?.operativeData.accountEntity = result.account
            self?.operativeData.document = result.document
            self?.container?.save(self?.operativeData)
            success()
        }
    }
    
    func signPositionsUseCaseSuccess(_ response: SignatureWithTokenEntity) {
        self.container?.save(self.operativeData)
        self.container?.save(response)
        self.container?.rebuildSteps()
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = self.container,
            let input = self.generateBizumAcceptRequestMoneySignatureUseCaseInput(for: presenter) else {
            completion(false, nil)
            return
        }
        let operativeData: BizumAcceptMoneyRequestOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: BizumAcceptRequestMoneySignatureUseCase.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { result in
                let validateMoneyTransferOTPEntity = result.validateMoneyTransferOTPEntity
                operativeData.validateMoneyTransferOTPEntity = validateMoneyTransferOTPEntity
                container.save(operativeData)
                container.save(validateMoneyTransferOTPEntity.otp)
                completion(true, nil)
            }.onError { [weak self] error in
                self?.performSignatureError(error, for: presenter, completion: completion)
            }
    }
    
    func generateBizumAcceptRequestMoneySignatureUseCaseInput(for presenter: SignaturePresentationDelegate) -> BizumAcceptRequestMoneySignatureUseCaseInput? {
        guard let container = self.container,
              let amount = self.operativeData.bizumSendMoney?.amount,
              let numberOfRecipients = self.operativeData.bizumContacts?.count else {
            return nil
        }
        let operativeData: BizumAcceptMoneyRequestOperativeData = container.get()
        let signature: SignatureWithTokenEntity = container.get()
        let input = BizumAcceptRequestMoneySignatureUseCaseInput(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            signatureWithToken: signature,
            amount: amount,
            numberOfRecipients: numberOfRecipients,
            account: operativeData.accountEntity
        )
        return input
    }
    
    func performSignatureError(_ error: UseCaseError<GenericErrorSignatureErrorOutput>, for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        switch error {
        case .error(let signatureError):
            self.trackErrorEvent(page: BizumAcceptRequestMoneySignaturePage().page, error: signatureError?.errorDescription, code: signatureError?.errorCode)
            completion(false, signatureError)
        case .generic, .intern, .networkUnavailable:
            self.trackErrorEvent(page: BizumAcceptRequestMoneySignaturePage().page, error: nil, code: nil)
            completion(false, nil)
        case .unauthorized:
            presenter.dismissLoading {
                self.dependencies.resolve(for: SessionResponseController.self).recivenUnauthorizedResponse()
            }
        }
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let input = self.generateBizumAcceptRequestMoneyOTPUseCaseInput(presenter: presenter) else {
            completion(false, nil)
            return
        }
        let useCase = self.dependencies.resolve(for: BizumAcceptRequestMoneyOTPUseCase.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] _ in
                self?.sendSimpleMultimediaWithoutChecking()
                completion(true, nil)
            }.onError { [weak self] error in
                self?.performOTPError(error, for: presenter, completion: completion)
            }
    }
    
    func generateBizumAcceptRequestMoneyOTPUseCaseInput(presenter: OTPPresentationDelegate) -> BizumAcceptRequestMoneyOTPUseCaseInput? {
        guard let container = self.container else {
            return nil
        }
        let operativeData: BizumAcceptMoneyRequestOperativeData = container.get()
        let otpValidation: OTPValidationEntity = container.get()
        guard let document = operativeData.document,
              let amount = operativeData.bizumSendMoney?.amount,
              let concept = operativeData.bizumSendMoney?.concept,
              let operationId = operativeData.operation?.operationId,
              let reciberId = operativeData.operation?.emitterId
              else {
            return nil
        }
        let input = BizumAcceptRequestMoneyOTPUseCaseInput(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            document: document,
            otpCode: presenter.code,
            operationId: operationId,
            dateTime: Date(),
            concept: concept,
            amount: amount,
            receiverUserId: reciberId
        )
        return input
    }
    
    func performOTPError(_ error: UseCaseError<GenericErrorOTPErrorOutput>, for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        switch error {
        case .error(error: let otpError):
            completion(false, GenericErrorOTPErrorOutput(
                otpError?.errorDescription ?? localized("otp_error_unsuccessful"),
                otpError?.otpResult ?? .serviceDefault,
                otpError?.errorCode))
        case .generic, .intern, .networkUnavailable:
            completion(false, GenericErrorOTPErrorOutput(
                localized("otp_error_unsuccessful"),
                .serviceDefault,
                nil))
        case .unauthorized:
            presenter.dismissLoading {
                self.dependencies.resolve(for: SessionResponseController.self).recivenUnauthorizedResponse()
            }
        }
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeGlobalPositionReloaderCapable {}

extension BizumAcceptMoneyRequestOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-acepta-recibida-exito")
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-acept-sol-recib-abandono")
    }
}

extension BizumAcceptMoneyRequestOperative: BizumOperativeSendSimpleMultimediaCapable {
    var receiverUserId: String {
        return self.operativeData.operation?.emitterId ?? ""
    }
    
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
    
    var checkPayment: BizumCheckPaymentEntity {
        return self.operativeData.bizumCheckPaymentEntity
    }
    
    var multimedia: BizumMultimediaData? {
        return self.operativeData.multimediaData
    }
    
    var operationId: String {
        return self.operativeData.operation?.operationId ?? ""
    }
    
    var operationType: BizumSendMultimediaOperationType {
        return .acceptMoneyRequest
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return self.dependencies.resolve()
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return BizumAcceptRequestMoneySignaturePage().page
    }
}

extension BizumAcceptMoneyRequestOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        return BizumAcceptRequestMoneyOTPPage().page
    }
}
