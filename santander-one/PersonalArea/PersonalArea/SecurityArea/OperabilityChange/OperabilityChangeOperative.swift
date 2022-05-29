//
//  OperabilityChangeOperative.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import CoreFoundationLib
import Operative

final class OperabilityChangeOperative: Operative {
    
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: OperabilityChangeOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: OperabilityChangeFinishingCoordinatorProtocol.self)
    }()
    
    enum FinishingOption {
        case globalPosition
    }
    
    var steps: [OperativeStep] = []

    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

// MARK: - OperativeSetupCapable

extension OperabilityChangeOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        UseCaseWrapper(
            with: self.dependencies.resolve(for: SetupOperabilityUseCase.self),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                let operativeData: OperabilityChangeOperativeData = container.get()
                operativeData.operabilityInd = result.operabilityInd
                operativeData.isUnderage = result.isUnderage
                operativeData.isSignatureBlocked = result.isSignatureBlocked
                operativeData.isUserWithoutCMC = result.isUserWithoutCMC
                container.save(operativeData)
                success()
        },
            onError: { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
        }
        )
    }    
}

// MARK: - OperativeSignatureCapable

extension OperabilityChangeOperative: OperativeSignatureCapable {
    
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        signInOperabilityChange(completion: completion)
    }
}

// MARK: - OperativeOTPCapable

extension OperabilityChangeOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        confirmChangeOperability(code: presenter.code, completion: completion)
    }
}

// MARK: - OperativeGlobalPositionReloaderCapable

extension OperabilityChangeOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

// MARK: - OperativeFinishingCoordinatorCapable

extension OperabilityChangeOperative: OperativeFinishingCoordinatorCapable {}

// MARK: - Private methods

private extension OperabilityChangeOperative {
    
    // MARK: - Setup

    func setupDependencies() {
        setupOperabilityUseCase()
        setupSummary()
        setupOperabilitySelector()
    }
    
    func buildSteps() {
        setupSummaryPresenter()
        setupUseCases()
        
        self.steps.append(OperabilityChangeSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(OperabilityChangeSummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupOperabilitySelector() {
        self.dependencies.register(for: OperabilitySelectorPresenterProtocol.self) { resolver in
            return OperabilitySelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperabilitySelectorViewProtocol.self) { resolver in
            return resolver.resolve(for: OperabilitySelectorViewController.self)
        }
        self.dependencies.register(for: OperabilitySelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: OperabilitySelectorPresenterProtocol.self)
            let viewController = OperabilitySelectorViewController(nibName: "OperabilitySelectorViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupOperabilityUseCase() {
        self.dependencies.register(for: SetupOperabilityUseCase.self) { resolver in
            SetupOperabilityUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupValidateOTPOperabilityUseCase() {
        self.dependencies.register(for: ValidateOTPOperabilityUseCase.self) { resolver in
            ValidateOTPOperabilityUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupConfirmChangeOperabilityUseCase() {
        self.dependencies.register(for: ConfirmChangeOperabilityUseCase.self) { resolver in
            ConfirmChangeOperabilityUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupValidateChangeOperabilityUseCase() {
        self.dependencies.register(for: ValidateChangeOperabilityUseCase.self) { resolver in
            ValidateChangeOperabilityUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupSummary() {
        setupSummaryPresenter()
        self.dependencies.register(for: OperabilityChangeSummaryViewProtocol.self) { resolver in
            return resolver.resolve(for: OperabilityChangeSummaryViewController.self)
        }
        self.dependencies.register(for: OperabilityChangeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: OperabilityChangeSummaryPresenterProtocol.self)
            let viewController = OperabilityChangeSummaryViewController(nibName: "OperabilityChangeSummaryViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummaryPresenter() {
        self.dependencies.register(for: OperabilityChangeSummaryPresenterProtocol.self) { resolver in
            return OperabilityChangeSummaryPresenter(dependenciesResolver: resolver)
        }
    }
    
    func setupUseCases() {
        setupValidateChangeOperabilityUseCase()
        setupValidateOTPOperabilityUseCase()
        setupConfirmChangeOperabilityUseCase()
    }
    
    // MARK: - Capables

    func confirmChangeOperability(code: String, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let otpValidationEntity: OTPValidationEntity = self.container?.get(),
        let newOperabilityInd = operativeData.newOperabilityInd else {
            return completion(false, nil)
        }
        
        let input = ConfirmChangeOperabilityUseCaseInput(operabilityInd: newOperabilityInd,
                                                         otpValidationDTO: otpValidationEntity.dto,
                                                         otpCode: code)
        UseCaseWrapper(
            with: self.dependencies.resolve(for: ConfirmChangeOperabilityUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
        )
    }
    
    func signInOperabilityChange(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        
        guard let signatureWithToken: SignatureWithTokenEntity = self.container?.get(),
        let newOperabilityInd = operativeData.newOperabilityInd else {
            return completion(false, nil)
        }
        let input = ValidateOTPOperabilityUseCaseInput(operabilityInd: newOperabilityInd,
                                                       signatureWithTokenEntity: signatureWithToken)
        UseCaseWrapper(
            with: self.dependencies.resolve(for: ValidateOTPOperabilityUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                self.container?.save(result.otpValidationEntity)
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
        )
    }
}

// MARK: - Steps

// MARK: Operability Change Selector

private final class OperabilityChangeSelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperabilitySelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: Summary

private final class OperabilityChangeSummaryStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperabilityChangeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Opinator

extension OperabilityChangeOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-cambio-operatividad-exito")
    }
}

extension OperabilityChangeOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-cambio-operatividad-abandono")
    }
}

extension OperabilityChangeOperative: OperativeTrackerCapable, OperativeSignatureTrackerCapable, OperativeOTPTrackerCapable {
    var extraParametersForTracker: [String: String] {
        return [:]
    }
    
    var screenIdSignature: String {
        return OperabilitySignaturePage().page
    }
    
    var screenIdOtp: String {
        return OperabilityOTPPage().page
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
