//
//  LogOutCoordinator.swift
//  RetailLegacy
//
//  Created by Daniel Gómez Barroso on 16/2/22.
//
import UI
import CoreFoundationLib
import Foundation
import CoreDomain

final class LogOutCoordinator: BindableCoordinator {
    var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var sessionManager: CoreSessionManager {
        legacyDependencies.resolve()
    }
    private let dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()
    var navigator: NavigatorProvider {
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
    }
    
    init(dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        navigator
            .privateHomeNavigator
            .showLogoutDialog(
                acceptAction: { [weak self] in
                    self?.updateCurrentRootViewWillAppearAction(nil)
                    self?.sessionManager.finishWithReason(.logOut)
                    let trackerManager = self?.legacyDependencies.resolve(for: TrackerManager.self)
                    trackerManager?.trackEvent(
                        screenId: TrackerPagePrivate.LogoutConfirm().page,
                        eventId: TrackerPagePrivate.LogoutConfirm.Action.ok.rawValue, extraParameters: [:]
                    )
                },
                offerDidOpenAction: { [weak self] in
                    // In order to open the logout dialog again once the user go back to the current view (but we have to hide the offer)
                    self?.updateCurrentRootViewWillAppearAction { [weak self] in
                        self?.start()
                    }
                }
            )
    }
    
    private func updateCurrentRootViewWillAppearAction(_ willAppearAction: (() -> Void)?) {
        var willAppearActionable = navigator.privateHomeNavigator.drawerRoot(as: WillAppearActionable.self)
        willAppearActionable?.willAppearAction = willAppearAction
    }
}
