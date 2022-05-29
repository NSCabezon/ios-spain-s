//
//  OtpScaAccountNavigator.swift
//  RetailClean
//
//  Created by José Carlos Estela Anguita on 30/08/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation

protocol OtpScaAccountNavigatorProtocol {
    func dismiss()
}

class OtpScaAccountNavigator: OtpScaAccountNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func dismiss() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
