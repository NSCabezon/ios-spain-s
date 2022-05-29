//
//  TransferHomeNavigator.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 12/27/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import CoreFoundationLib
import Transfer

final class TransferHomeNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    let dependenciesEngine: DependenciesInjector & DependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesResolver: DependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.drawer = drawer
    }
    
    public func gotoTransferHome(for account: AccountEntity?) {
        launchTransferSection(.home, selectedAccount: account)
    }
}
