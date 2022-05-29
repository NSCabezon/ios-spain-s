//
//  HandleNetworkingErrorCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/9/20.
//

import Foundation
import CoreFoundationLib

protocol HandleNetworkingErrorCapable: class {
    var loginView: LoginViewCapable? { get }
}

extension HandleScaBloquedCapable {
    func handleNetworUnavailable() {
        self.loginView?.dismissLoading(completion: {
            self.loginView?.showLoginError(localized("generic_error_withoutConnection"))
        })
    }
}
