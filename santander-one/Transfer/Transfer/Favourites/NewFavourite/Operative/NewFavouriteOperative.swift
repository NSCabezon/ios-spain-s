import Operative
import CoreFoundationLib

final class NewFavouriteOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    private lazy var operativeData: NewFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: NewFavouriteFinishingCoordinatorProtocol.self)
    }()
    enum FinishingOption {
        case home
        case globalPosition
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension NewFavouriteOperative {
    func buildSteps() {
        self.steps.append(NewFavouriteCountryAndCurrencySelectorStep(dependenciesResolver: dependencies))
        self.steps.append(NewFavouriteAliasStep(dependenciesResolver: dependencies))
        self.steps.append(NewFavouriteConfirmationStep(dependenciesResolver: self.dependencies))
        self.steps.append(NewFavouriteSummaryStep(dependenciesResolver: self.dependencies))
    }
    
    func setupDependencies() {
        self.setupCountryAndCurrencySelectorDependencies()
        self.setupAliasDependecies()
        self.setupConfirmationDependecies()
        self.setupSummaryDependencies()
    }
    
    func setupCountryAndCurrencySelectorDependencies() {
        self.dependencies.register(for: NewFavouriteCountryAndCurrencySelectorPresenterProtocol.self) { resolver in
            return NewFavouriteCountryAndCurrencySelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: NewFavouriteCountryAndCurrencySelectorViewProtocol.self) { resolver in
            return resolver.resolve(for: NewFavouriteCountryAndCurrencySelectorViewController.self)
        }
        self.dependencies.register(for: NewFavouriteCountryAndCurrencySelectorViewController.self) { resolver in
            let presenter: NewFavouriteCountryAndCurrencySelectorPresenterProtocol = resolver.resolve()
            let viewController = NewFavouriteCountryAndCurrencySelectorViewController(nibName: "NewFavouriteCountryAndCurrencySelectorViewController",
                                                                                      bundle: .module,
                                                                                      presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: NewFavouritePreSetupUseCaseProtocol.self) { resolver in
            return NewFavouritePreSetupUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupAliasDependecies() {
        self.dependencies.register(for: NewFavouriteAliasPresenterProtocol.self) { resolver in
            return NewFavouriteAliasPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: NewFavouriteAliasViewProtocol.self) { resolver in
            return resolver.resolve(for: NewFavouriteAliasViewController.self)
        }
        self.dependencies.register(for: NewFavouriteAliasViewController.self) { resolver in
            let presenter = resolver.resolve(for: NewFavouriteAliasPresenterProtocol.self)
            let viewController = NewFavouriteAliasViewController(nibName: "NewFavouriteAliasViewController", presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupConfirmationDependecies() {
        self.dependencies.register(for: NewFavouriteConfirmationPresenterProtocol.self) { resolver in
            NewFavouriteConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: NewFavouriteConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: NewFavouriteConfirmationViewController.self)
        }
        self.dependencies.register(for: NewFavouriteConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: NewFavouriteConfirmationPresenterProtocol.self)
            let viewController = NewFavouriteConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummaryDependencies() {
        self.dependencies.register(for: NewFavouriteSummaryPresenterProtocol.self) { resolver in
            NewFavouriteSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: NewFavouriteSummaryPresenterProtocol.self)
            let viewController = NewFavouriteSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension NewFavouriteOperative: OperativePresetupCapable {
    
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        let useCase: NewFavouritePreSetupUseCaseProtocol = self.dependenciesResolver.resolve()
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                self?.operativeData.sepaList = output.sepaList
                success()
            }
    }
}

extension NewFavouriteOperative: OperativeFinishingCoordinatorCapable { }

extension NewFavouriteOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        self.operativeData.isNoSepa ? RegularOpinatorInfoEntity(path: "app-alta-fav-NOSEPA-exito") : RegularOpinatorInfoEntity(path: "app-alta-fav-sepa-exito")
    }
}

extension NewFavouriteOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        self.operativeData.isNoSepa ? GiveUpOpinatorInfoEntity(path: "app-alta-fav-NOSEPA-abandono") : GiveUpOpinatorInfoEntity(path: "app-alta-fav-sepa-abandono")
    }
}
        
final class NewFavouriteCountryAndCurrencySelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: NewFavouriteCountryAndCurrencySelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NewFavouriteOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension NewFavouriteOperative: OperativeDialogFinishCapable {}
