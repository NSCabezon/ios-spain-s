import CoreFoundationLib
import Operative

final class ChangePasswordOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }

    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: ChangePasswordFinishingCoordinatorProtocol.self)
    }()

    enum FinishingOption {
        case security
    }

    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension ChangePasswordOperative {
    func buildSteps() {
        self.steps.append(ChangePasswordStep(dependenciesResolver: self.dependencies, withButtons: !self.isForcedPasswordChange()))
    }

    func setupDependencies() {
        self.dependencies.register(for: ChangePasswordPresenterProtocol.self) { resolver in
            ChangePasswordPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ChangePasswordViewProtocol.self) { resolver in
            resolver.resolve(for: ChangePasswordViewController.self)
        }
        self.dependencies.register(for: ChangePasswordViewController.self) { resolver in
            let presenter = resolver.resolve(for: ChangePasswordPresenterProtocol.self)
            presenter.isForcedFromLogin = self.isForcedPasswordChange()
            let viewController = ChangePasswordViewController(nibName: "ChangePasswordViewController", presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: PrevalidateChangePasswordUseCaseProtocol.self) { resolver in
            PrevalidateChangePasswordUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ValidateChangePasswordUseCaseProtocol.self) { resolver in
            ValidateChangePasswordUseCase(dependenciesResolver: resolver)
        }
    }

    func isForcedPasswordChange() -> Bool {
        guard self.operative.container?.handler?.operativeNavigationController?.viewControllers.count ?? 0 == 1 else {
            // Change interface only coming from login
            return false
        }
        let forcedPasswordChangeConfiguration = self.dependencies.resolve(forOptionalType: ForcedPasswordChangeAdapterProtocol.self)
        return (forcedPasswordChangeConfiguration?.isForcedPasswordChange ?? false)
    }
}

final class ChangePasswordStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var withButtons: Bool = true
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: withButtons, showsCancel: withButtons)
    }

    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: ChangePasswordViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver, withButtons: Bool) {
        self.dependenciesResolver = dependenciesResolver
        self.withButtons = withButtons
    }
}

extension ChangePasswordOperative: OperativeFinishingCoordinatorCapable {}

extension ChangePasswordOperative: OperativeDialogFinishCapable {}
