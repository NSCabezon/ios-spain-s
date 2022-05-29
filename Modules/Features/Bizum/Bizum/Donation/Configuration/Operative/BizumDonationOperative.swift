import Operative
import CoreFoundationLib
import UI

final class BizumDonationOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: BizumDonationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()
    var steps: [OperativeStep] = []

    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

extension BizumDonationOperative: OperativePresetupCapable, BizumCommonSetupCapable {
    
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
    
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        let operativeData: BizumDonationOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: BizumCommonPreSetupUseCaseProtocol.self)
        let input = BizumCommonPreSetupUseCaseInput(bizumCheckPaymentEntity: operativeData.bizumCheckPaymentEntity,
                                                       operationEntity: nil)
        let scenario = Scenario(useCase: useCase, input: input)
        self.bizumSetupWithScenario(scenario) { [weak self] result in
            operativeData.accountEntity = result.account
            operativeData.document = result.document
            operativeData.accounts = result.accounts
            container.save(operativeData)
            self?.dependencies.register(for: BizumCheckPaymentConfiguration.self) { _ in
                return BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: operativeData.bizumCheckPaymentEntity)
            }
            success()
        }
    }
}

extension BizumDonationOperative: OperativeFinishingCoordinatorCapable {}

private extension BizumDonationOperative {
    func buildSteps() {
        self.steps.append(BizumDonationNGOSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(BizumDonationAmountStep(dependenciesResolver: dependencies))
        self.steps.append(BizumDonationConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }

    func setupDependencies() {
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { resolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumCommonPreSetupUseCaseProtocol.self) { resolver in
            BizumCommonPreSetupUseCase(dependenciesResolver: resolver)
        }
        self.setupBizumDonations()
    }

    func setupBizumDonations() {
        self.setupOrganizationSelector()
        self.setupAmount()
        self.setupMultimedia()
        self.setupConfirmation()
        self.setupSignature()
        self.setupOtp()
        self.setupSummary()
    }

    func setupOrganizationSelector() {
        self.dependencies.register(for: BizumDonationNGOSelectorViewProtocol.self) { resolver in
            resolver.resolve(for: BizumDonationNGOSelectorViewController.self)
        }
        self.dependencies.register(for: BizumDonationNGOSelectorPresenterProtocol.self) { resolver in
            BizumDonationNGOSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumDonationNGOSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumDonationNGOSelectorPresenterProtocol.self)
            let viewController = BizumDonationNGOSelectorViewController(
                nibName: "BizumDonationNGOSelectorViewController",
                presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: BizumGetOrganizationsUseCase.self) { dependenciesResolver in
            return BizumGetOrganizationsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumGetOrganizationsSuperUseCase.self) { resolver in
            return BizumGetOrganizationsSuperUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OrganizationSelectorCoordinator.self) { dependeciesResolver in
            return OrganizationSelectorCoordinator(dependeciesResolver: dependeciesResolver,
                                                   navigationController: self.container?.coordinator.navigationController ?? UINavigationController())
        }
    }

    func setupAmount() {
        self.dependencies.register(for: BizumValidateMoneyTransferUseCase.self) { resolver in
            return BizumValidateMoneyTransferUseCase(dependencies: resolver)
        }
        self.dependencies.register(for: BizumDonationAmountCoordinatorProtocol.self) { resolver in
            return BizumDonationAmountCoordinator(
                dependenciesResolver: resolver,
                navigationController: self.container?.coordinator.navigationController ?? UINavigationController())
        }
        self.dependencies.register(for: BizumDonationAmountViewProtocol.self) { resolver in
            resolver.resolve(for: BizumDonationAmountViewController.self)
        }
        self.dependencies.register(for: BizumDonationAmountPresenterProtocol.self) { resolver in
            BizumDonationAmountPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumDonationAmountViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumDonationAmountPresenterProtocol.self)
            let viewController = BizumDonationAmountViewController(
                nibName: "BizumDonationAmountViewController",
                presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupMultimedia() {
        self.dependencies.register(for: GetMultimediaUsersUseCase.self) { resolver in
            GetMultimediaUsersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaSimpleUseCase.self) { resolver in
            SendMultimediaSimpleUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaMultiUseCase.self) { resolver in
            SendMultimediaMultiUseCase(dependenciesResolver: resolver)
        }
    }

    func setupConfirmation() {
        self.dependencies.register(for: SignPosSendMoneyUseCase.self) { resolver in
            SignPosSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumDonationConfirmationPresenter.self) { resolver in
            BizumDonationConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumDonationConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumDonationConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumDonationConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumDonationConfirmationPresenter.self)
            let viewController = BizumDonationConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupSignature() {
        self.dependencies.register(for: BizumValidateMoneyTransferOTPUseCase.self) { resolver in
            BizumValidateMoneyTransferOTPUseCase(dependenciesResolver: resolver)
        }
    }

    func setupOtp() {
        self.dependencies.register(for: BizumMoneyTransferOTPUseCase.self) { resolver in
            BizumMoneyTransferOTPUseCase(dependenciesResolver: resolver)
        }
    }

    func setupSummary() {
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumSendMoneySummaryPresenterProtocol.self) { resolver in
            return BizumDonationSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSendMoneySummaryPresenterProtocol.self)
            let viewController = BizumSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
