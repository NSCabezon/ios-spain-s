//
//  TopErrorAlertCapable.swift
//  Operative
//
//  Created by Ignacio González Miró on 28/5/21.
//

import UI
import CoreFoundationLib

public protocol TopErrorAlertCapable {
    func showTopAlertError(_ message: LocalizedStylableText)
}

extension TopErrorAlertCapable {
    
    public func showTopAlertError(_ message: LocalizedStylableText) {
        TopAlertController
            .setup(TopAlertView.self)
            .showAlert(message, alertType: .failure, duration: 4, position: .top)
    }
}
