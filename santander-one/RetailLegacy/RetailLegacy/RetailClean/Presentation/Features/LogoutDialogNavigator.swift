//
//  LogoutDialogNavigator.swift
//  RetailClean
//
//  Created by José Carlos Estela Anguita on 20/03/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation

protocol LogoutDialogNavigator: PullOffersActionsNavigatorProtocol {
    func dismiss()
}

class LogoutDialogNavigatorImp: AppStoreNavigator, LogoutDialogNavigator {
    
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func dismiss() {
        drawer.currentRootViewController?.dismiss(animated: true)
    }
}
