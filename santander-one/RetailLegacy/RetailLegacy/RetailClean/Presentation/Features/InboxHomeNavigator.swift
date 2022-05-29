//
//  InboxHomeNavigator.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 1/17/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import Inbox

final class InboxHomeNavigator {
    private let presenterProvider: PresenterProvider
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func gotoInboxHome() {
        let navigatorViewController = self.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
        
        let inboxModuleCoordinator = InboxModuleCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigatorViewController
        )
        
        self.presenterProvider.dependenciesEngine.register(for: InboxHomeModuleCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: InboxHomeCoordinatorNavigator.self)
        }
        
        inboxModuleCoordinator.start(.home)
    }
}
