//
//  EditFavouriteOperative.swift
//  Account
//
//  Created by Jose Enrique Montero Prieto on 19/07/2021.
//

import Operative
import CoreFoundationLib
import SANLegacyLibrary

final class EditFavouriteOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    var steps: [OperativeStep] = []
    lazy var operativeData: EditFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: EditFavouriteFinishingCoordinatorProtocol.self)
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

private extension EditFavouriteOperative {
    func buildSteps() {
        self.steps.append(EditFavouriteHolderAndAccountStep(dependenciesResolver: dependencies))
        self.steps.append(EditFavouriteConfirmationStep(dependenciesResolver: self.dependencies))
        self.steps.append(EditFavouriteSummaryStep(dependenciesResolver: self.dependencies))
    }
    
    func setupDependencies() {
        self.setupConfirmationDependecies()
        self.setupHolderAndAccountDependencies()
        self.setupSummaryDependencies()
    }
    
    func setupHolderAndAccountDependencies() {
        self.dependencies.register(for: EditFavouriteHolderAndAccountPresenterProtocol.self) { resolver in
            return EditFavouriteHolderAndAccountPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: EditFavouriteHolderAndAccountViewProtocol.self) { resolver in
            return resolver.resolve(for: EditFavouriteHolderAndAccountViewController.self)
        }
        self.dependencies.register(for: EditFavouriteHolderAndAccountViewController.self) { resolver in
            let presenter = resolver.resolve(for: EditFavouriteHolderAndAccountPresenterProtocol.self)
            let viewController = EditFavouriteHolderAndAccountViewController(nibName: "EditFavouriteHolderAndAccountViewController", presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: NewFavouritePreSetupUseCaseProtocol.self) { resolver in
            return NewFavouritePreSetupUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: PreValidateEditFavouriteUseCaseProtocol.self) { resolver in
            return PreValidateEditFavouriteUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupConfirmationDependecies() {
        self.dependencies.register(for: EditFavouriteConfirmationPresenterProtocol.self) { resolver in
            EditFavouriteConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: EditFavouriteConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: EditFavouriteConfirmationViewController.self)
        }
        self.dependencies.register(for: EditFavouriteConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: EditFavouriteConfirmationPresenterProtocol.self)
            let viewController = EditFavouriteConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: ValidateEditFavouriteUseCaseProtocol.self) { resolver in
            return ValidateEditFavouriteUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupSummaryDependencies() {
        self.dependencies.register(for: EditFavouriteSummaryPresenterProtocol.self) { resolver in
            EditFavouriteSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: EditFavouriteSummaryPresenterProtocol.self)
            let viewController = EditFavouriteSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension EditFavouriteOperative: OperativeFinishingCoordinatorCapable {}

extension EditFavouriteOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension EditFavouriteOperative: OperativeDialogFinishCapable {}

extension EditFavouriteOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
            return RegularOpinatorInfoEntity(path: "app-modificar-fav-SEPA-exito")
    }
}

extension EditFavouriteOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
            return GiveUpOpinatorInfoEntity(path: "app-modificar-fav-SEPA-abandono")
      }
}
