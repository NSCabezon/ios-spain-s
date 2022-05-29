//
//  UpdateLoadingMessageCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import CoreFoundationLib
import LoginCommon

protocol UpdateLoadingMessageCapable {
    var loginView: LoginViewCapable? { get }
    var coordinatorDelegate: LoginCoordinatorDelegate { get }
}

extension UpdateLoadingMessageCapable {
    func updateLoadingMessage(isPb: Bool, name: String) {
        self.loginView?.showLoadingText(title: localized("login_popup_loadingData"),
                                   subtitle: localized("loading_label_moment"))
        self.coordinatorDelegate.goToFakePrivate(isPb: isPb, name: name)
    }
}
