//
//  ContactSelectorCoordinator.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 04/02/2020.
//

import CoreDomain
import Foundation
import CoreFoundationLib
import UI

public protocol ContactSelectorDelegate: AnyObject {
    func didSortedContacts()
}

protocol ContactSelectorCoordinatorProtocol {
    func dismiss()
    func goToNewContact()
    func goToContactDetail(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate)
    func share(for shareable: Shareable)
    func goToPrivateMenu()
}

final class ContactSelectorCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let contactsDetailCoordinator: ContactDetailCoordinator
    
    private var transferDelegate: TransferHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.contactsDetailCoordinator = ContactDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigationController)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: ContactSelectorViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: ContactSelectorCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetContactSelectorConfigurationUseCaseProtocol.self) { dependenciesResolver in
            return GetContactSelectorConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SetFavoriteContactsUseCase.self) { dependenciesResolver in
            return SetFavoriteContactsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ContactSelectorPresenterProtocol.self) { dependenciesResolver in
            return ContactSelectorPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ContactSelectorViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: ContactSelectorViewController.self)
        }
        self.dependenciesEngine.register(for: ContactDetailCoordinator.self) { _ in
            return self.contactsDetailCoordinator
        }
        self.dependenciesEngine.register(for: ContactSelectorViewController.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: ContactSelectorPresenterProtocol.self)
            let viewController = ContactSelectorViewController(nibName: "ContactSelectorViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension ContactSelectorCoordinator: ContactSelectorCoordinatorProtocol {
    
    func share(for shareable: Shareable) {
        guard let topController = self.navigationController?.topViewController else { return }
        let sharedHandle = self.dependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandle.doShare(for: shareable, in: topController)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToNewContact() {
        self.transferDelegate.didSelectNewContact()
    }
    
    func goToContactDetail(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        let transferConfiguration = dependenciesEngine.resolve(for: TransfersHomeConfiguration.self)
        self.dependenciesEngine.register(for: ContactDetailConfiguration.self) { _ in
            return ContactDetailConfiguration(contact: contact, account: transferConfiguration.selectedAccount)
        }
        self.contactsDetailCoordinator.start(withLauncher: launcher, handleBy: delegate)
    }
    
    func goToPrivateMenu() {
        self.transferDelegate.didSelectMenu()
    }
}
