//
//  HandleScaOtpCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import LoginCommon

protocol HandleScaOtpCapable: class {
    var loginView: LoginViewCapable? { get }
    var coordinatorDelegate: LoginCoordinatorDelegate { get }
}

extension HandleScaOtpCapable {
    func handleScaOtp(username: String, isFirstTime: Bool) {
        self.loginView?.dismissLoading(completion: { [weak self] in
            self?.coordinatorDelegate.goToOtpSca(username: username, isFirstTime: isFirstTime)
        })
    }
}
