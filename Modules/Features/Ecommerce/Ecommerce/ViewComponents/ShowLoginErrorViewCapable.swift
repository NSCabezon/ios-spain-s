//
//  HandleErrorLoginViewCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/27/20.
//

import Foundation
import CoreFoundationLib
import UI

public protocol ShowLoginErrorViewCapable {
    var associatedErrorView: UIViewController { get }
}

public extension ShowLoginErrorViewCapable where Self: UIViewController {
    var associatedErrorView: UIViewController {
        return self
    }
}

public extension ShowLoginErrorViewCapable {
    func showLoginError(_ error: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(error, alertType: .failure)
        associatedErrorView.view.isUserInteractionEnabled = true
    }
    
    func showLoginErrorInfinite(_ error: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(error, alertType: .failure, presentationType: .infinite)
        associatedErrorView.view.isUserInteractionEnabled = true
    }
    
    func showToast(description: String) {
        Toast.show(description)
    }
}
