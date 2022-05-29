import Operative
import CoreFoundationLib

final class BizumCancelOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    private lazy var operativeData: BizumCancelOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

extension BizumCancelOperative: OperativePresetupCapable, BizumCommonSetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        let operativeData: BizumCancelOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: BizumCommonPreSetupUseCaseProtocol.self)
        let scenario = Scenario(useCase: useCase, input: BizumCommonPreSetupUseCaseInput(bizumCheckPaymentEntity: operativeData.bizumCheckPaymentEntity, operationEntity: operativeData.operationEntity))
        self.bizumSetupWithScenario(scenario) { result in
            operativeData.accountEntity = result.account
            operativeData.document = result.document
            container.save(operativeData)
            success()
        }
    }
}

extension BizumCancelOperative: OperativeFinishingCoordinatorCapable {}

extension BizumCancelOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-cancel-envio-noregistrado-exit")
    }
}

extension BizumCancelOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-cancel-env-noreg-abandono")
    }
}

extension BizumCancelOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

private extension BizumCancelOperative {
    func setupDependencies() {
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { resolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumCommonPreSetupUseCaseProtocol.self) { resolver in
            BizumCommonPreSetupUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumCancelUseCase.self) { dependenciesResolver in
            return BizumCancelUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.setupConfirmation()
        self.setupSummary()
    }
    
    func buildSteps() {
        self.steps.append(BizumCancelConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(BizumCancelSummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupConfirmation() {
        self.dependencies.register(for: BizumCancelConfirmationPresenterProtocol.self) { resolver in
            BizumCancelConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumCancelConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumCancelConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumCancelConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumCancelConfirmationPresenterProtocol.self)
            let viewController = BizumCancelConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummary() {
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: BizumCancelSummaryPresenterProtocol.self) { resolver in
            return BizumCancelSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumCancelSummaryPresenterProtocol.self)
            let viewController = BizumCancelSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
