//
//  DeleteScheduledTransferOperative.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 20/7/21.
//

import Foundation
import Operative
import CoreFoundationLib
import UI
    
final class DeleteScheduledTransferOperative: Operative {
    enum DeleteOperationScope {
        case countrySpecific(DeleteStandingOrderUseCaseProtocol)
        case `default`
    }
    
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol?
    var steps: [OperativeStep] = []
    lazy var operativeData: DeleteScheduledTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: DeleteScheduledTransferFinishingCoordinatorProtocol.self)
    }()
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.getOptional()
        return entity
    }
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
    
    enum FinishingOption {
        case home
        case globalPosition
        case operativeFinished
    }
}

private extension DeleteScheduledTransferOperative {
    var useCaseHandler: UseCaseHandler {
        return self.dependencies.resolve(for: UseCaseHandler.self)
    }
    
    func setupDependencies() {
        self.setupPreSetupDependencies()
        self.setupSummaryDependencies()
    }
    
    func buildSteps() {
        self.addSteps()
    }
    
    func addSteps() {
        if let predefinedSCA = predefinedSCA, predefinedSCA == .signature {
            self.sca?.prepareForVisitor(self)
        }
        self.steps.append(DeleteScheduledTransferResumeStep(dependenciesResolver: dependencies))
    }
    
    func setupSummaryDependencies() {
        self.dependencies.register(for: DeleteScheduledTransferResumeStepPresenterProtocol.self) { resolver in
            DeleteScheduledTransferResumePresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeView.self) { resolver in
            resolver.resolve(for: DeleteScheduledTransferResumeViewcontroller.self)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            let presenter = resolver.resolve(for: DeleteScheduledTransferResumeStepPresenterProtocol.self)
            let viewController = DeleteScheduledTransferResumeViewcontroller(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { resolver in
            return GetGlobalPositionUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupPreSetupDependencies() {
        self.dependencies.register(for: SepaListUseCaseProtocol.self) { resolver in
            SepaListUseCase(dependencies: resolver)
        }
        self.dependencies.register(for: GetAccountUseCase.self) { dependenciesResolver in
            return GetAccountUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension DeleteScheduledTransferOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signature: SignatureWithTokenEntity = self.container?.get(),
              let accountEntity = operativeData.account,
              let transfer = operativeData.order as? ScheduledTransferEntity,
              let transferDetail = operativeData.detail
               else {
            return completion(false, nil)
        }
        let input = ConfirmCancelTransferSignUseCaseInput(account: accountEntity,
                                                          signatureWithToken: signature,
                                                          scheduledTransfer: transfer,
                                                          scheduledTransferDetail: transferDetail)
        let usecase = ConfirmCancelTransferSignUseCase(dependencies: self.dependencies)
        Scenario(useCase: usecase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { (_) in
                completion(true, nil)
            }
            .onError { (errorResult) in
                switch errorResult {
                case .error(error: let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
    }
}

extension DeleteScheduledTransferOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        if let countryUseCase = dependencies.resolve(forOptionalType: DeleteStandingOrderUseCaseProtocol.self) {
            self.performSetupForScope(.countrySpecific(countryUseCase), success: success, failed: failed)
        } else {
            self.performSetupForScope(.default, success: success, failed: failed)
        }
    }
}

extension DeleteScheduledTransferOperative: OperativePresetupCapable {
    func sepaListScenario() -> Scenario<Void, PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {
        let sepaListUseCase = self.dependencies.resolve(for: SepaListUseCaseProtocol.self)
        return Scenario(useCase: sepaListUseCase)
    }

    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let originIBANEntity = self.operativeData.account?.getIban() else {
            failed(OperativeSetupError(title: nil, message: nil))
            return
        }
        let getAccountsUseCase = self.dependencies.resolve(for: GetAccountUseCase.self)
        Scenario(useCase: getAccountsUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { (output) in
                let matchAccountEntity = output.accounts.first(where: {$0.getIban() == originIBANEntity})
                guard matchAccountEntity != nil else {
                    failed(OperativeSetupError(title: nil, message: nil))
                    return
                }
                self.operativeData.originAccountAlias = matchAccountEntity?.alias
                success()
            }
            .then(scenario: sepaListScenario)
            .onSuccess { (result) in
                self.operativeData.sepaInfoList = result.sepaList
            }
            .onError { useCaseError in
                failed(OperativeSetupError(title: nil, message: useCaseError.getErrorDesc()))
            }
    }
}

extension DeleteScheduledTransferOperative: ShareOperativeCapable {
    
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container else { return completion(.failure(.generalError)) }
        let operativeData: DeleteScheduledTransferOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { response in
                let name = response.globalPosition.fullName ?? ""
                let configuration = DeleteScheduledTransferShareConfiguration.defaultConfiguration(name: name,
                                                                                                   operativeData: operativeData,
                                                                                                   dependencyResolver: self.dependenciesResolver)
                let shareView = DeleteScheduledTransferShareViewController(configuration: configuration)
                completion(.success((shareView, shareView.view)))
            }
            .onError { _ in
                completion(.failure(.generalError))
            }
    }
}

extension DeleteScheduledTransferOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return dependencies
    }
}

extension DeleteScheduledTransferOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-baja-transf-prog-exito")
    }
}

extension DeleteScheduledTransferOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-baja-transf-prog-abandono")
    }
}

extension DeleteScheduledTransferOperative: OperativeDialogFinishCapable {}

extension DeleteScheduledTransferOperative: SCACapable {}

extension DeleteScheduledTransferOperative: SCASignatureWithTokenCapable {
    func prepareForSignatureWithToken(_ signature: SignatureWithTokenEntity) {
        self.container?.save(signature)
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
    }
}

extension DeleteScheduledTransferOperative: OperativeFinishingCoordinatorCapable {}

extension DeleteScheduledTransferOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        DeleteScheduledTransferSignaturePage().pageAssociated
    }
}

extension DeleteScheduledTransferOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        let parameterKey = TrackerDimension.progTransferType.key
        var parameter = [parameterKey: ""]
        if let isTransferPeriodic = self.operativeData.order?.isPeriodic {
            let transferType = isTransferPeriodic ? "periodica" : "diferida"
            parameter.updateValue(transferType, forKey: parameterKey)
        }
        return parameter
    }
}

private extension DeleteScheduledTransferOperative {
    func performSetupForScope(
        _ operationScope: DeleteOperationScope,
        success: @escaping () -> Void,
        failed: @escaping (OperativeSetupError) -> Void
    ) {
        switch operationScope {
        case .countrySpecific(let countryUseCase):
            if let orderEntity = self.operativeData.order as? StandingOrderEntity {
             let input = DeleteStandingOrderUseCaseUseCaseInput(order: orderEntity)
             buildSteps()
             Scenario(useCase: countryUseCase, input: input)
                 .execute(on: dependencies.resolve())
                 .onSuccess { _ in
                     success()
                 }
                 .onError { error in
                     failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
                 }
            }
        case .default:
            let useCase = SetUpCancelTransferUseCase(dependencies: self.dependencies)
            Scenario(useCase: useCase)
                .execute(on: dependencies.resolve())
                .onSuccess { [weak self] result in
                    self?.container?.save(result.signatureWithToken)
                    self?.container?.save(result.predefinedSCA)
                    if let scaRepresentable = result.signatureWithToken?.signatureWithTokenDTO {
                        self?.container?.save(SCAEntity(scaRepresentable))
                    }
                    self?.buildSteps()
                    success()
                }
                .onError { error in
                    failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
                }
        }
    }
}
