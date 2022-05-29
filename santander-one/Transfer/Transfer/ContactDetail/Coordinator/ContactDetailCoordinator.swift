//
//  ContactDetailCoordinator.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import CoreFoundationLib
import CoreDomain
import Operative
import UI

public protocol ContactDetailCoordinatorDelegate: AnyObject {
    func didSelectUpdateFavorite(favoriteType: FavoriteType)
    func didSelectUpdateNoSepaFavorite(favorite: PayeeRepresentable, noSepaPayeeDetailEntity: NoSepaPayeeDetailEntity)
    func didDeleteFavourite(favoriteType: FavoriteType)
    func didSelectNewShipment(favorite: PayeeRepresentable, accountEntity: AccountEntity?)
    func didSelectNoSepaNewShipment(_ favorite: PayeeRepresentable, accountEntity: AccountEntity?, noSepaPayeeDetailEntity: NoSepaPayeeDetailEntity)
    func didSelectTransferForFavorite(_ favorite: PayeeRepresentable, accountEntity: AccountEntity?, enabledFavouritesCarrusel: Bool)
}

protocol ContactDetailCoordinatorProtocol {
    func dismiss()
    func didSelectShare(_ shareable: Shareable)
}

public final class ContactDetailCoordinator: LauncherModuleCoordinator {
    weak public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start(withLauncher launcher: ModuleLauncher, handleBy delegate: ModuleLauncherDelegate) {
        let selectedContact = self.dependenciesEngine.resolve(for: ContactDetailConfiguration.self).contact
        let useCase = self.dependenciesEngine.resolve(firstTypeOf: GetContactDetailUseCaseProtocol.self).setRequestValues(requestValues: GetContactDetailUseCaseInput(contact: selectedContact))
        launcher
            .enableLoading(
                enable: true,
                handledBy: delegate)
            .does(
                useCase: useCase,
                handledBy: delegate
            ) { output in
                self.dependenciesEngine.register(for: ContactDetailExtendedConfiguration.self) { _ in
                    return ContactDetailExtendedConfiguration(favorite: output.detail, sepaList: output.sepaList)
                }
                let controller = self.dependenciesEngine.resolve(for: ContactDetailViewController.self)
                self.navigationController?.blockingPushViewController(controller, animated: true)
            }
    }
}

private extension ContactDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: GetContactDetailUseCaseProtocol.self) { dependenciesResolver in
            return GetContactDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ContactDetailCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: ContactDetailPresenter.self) { dependenciesResolver in
            return ContactDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        self.dependenciesEngine.register(for: ContactDetailViewController.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: ContactDetailPresenter.self)
            let view = ContactDetailViewController(nibName: "ContactDetailViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
    
    func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandle = self.dependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandle.doShare(for: shareable, in: controller)
    }
}

extension ContactDetailCoordinator: ContactDetailCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectShare(_ shareable: Shareable) {
        self.doShare(for: shareable)
    }
}
