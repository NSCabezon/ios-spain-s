//
//  HandleScaBloquedCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import CoreFoundationLib
import LoginCommon

protocol HandleScaBloquedCapable: class {
    var loginView: LoginViewCapable? { get }
    var coordinatorDelegate: LoginCoordinatorDelegate { get }
}

extension HandleScaBloquedCapable {
    func handleScaBloqued() {
        self.loginView?.dismissLoading(completion: { [weak self] in
            self?.coordinatorDelegate.backToLogin()
            self?.loginView?.showLoginError(localized("otpSCA_alert_text_blocked"))
        })
    }
}
