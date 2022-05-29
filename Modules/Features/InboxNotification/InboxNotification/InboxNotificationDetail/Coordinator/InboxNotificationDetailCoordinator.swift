//
//  InboxNotificationDetailCoordinator.swift
//  Pods
//
//  Created by José María Jiménez Pérez on 18/5/21.
//  

import UI
import CoreFoundationLib
import Inbox

/**
    #Add method that must be handle by the InboxNotificationDetailCoordinator like 
    navigation between the module scene and so on.
*/
protocol InboxNotificationDetailCoordinatorProtocol {
    func dismissViewController()
    func openMenu()
    func goBack()
}

final class InboxNotificationDetailCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let coordinatorDelegate: InboxHomeModuleCoordinatorDelegate
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        coordinatorDelegate = dependenciesEngine.resolve(for: InboxHomeModuleCoordinatorDelegate.self)
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: InboxNotificationDetailViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension InboxNotificationDetailCoordinator: InboxNotificationDetailCoordinatorProtocol {
    func dismissViewController() {
        self.goBack()
    }
    
    func openMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

/**
 #Register Scene depencencies.
*/

private extension InboxNotificationDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: InboxNotificationDetailCoordinatorProtocol.self) { _ in
            return self
        }
         
        self.dependenciesEngine.register(for: InboxNotificationDetailPresenterProtocol.self) { resolver in
            return InboxNotificationDetailPresenter(dependenciesResolver: resolver)
        }
         
        self.dependenciesEngine.register(for: InboxNotificationDetailViewController.self) { resolver in
            var presenter = resolver.resolve(for: InboxNotificationDetailPresenterProtocol.self)
            let viewController = InboxNotificationDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension InboxNotificationDetailCoordinator {
    func navigateToPushNotification(_ notification: PushNotificationConformable) {
        guard let notification = notification as? PushNotification else { return }
        self.dependenciesEngine.register(for: InboxNotificationDetailConfiguration.self) { _ in
            return InboxNotificationDetailConfiguration(pushNotification: notification)
        }
        self.start()
    }
}
