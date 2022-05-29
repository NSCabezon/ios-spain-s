//
//  TopAlertController.swift
//  toTest
//
//  Created by alvola on 01/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import Foundation
import CoreFoundationLib
import UIKit

public final class TopAlertController {
    public static let shared = TopAlertController()
    private typealias MessagesTuple = (title: LocalizedStylableText?, message: LocalizedStylableText)
    private var messages: [MessagesTuple] = [] {
        didSet {
            present(messages.removeFirst())
        }
    }
    private var alertType: TopAlertType?
    private var alertPresentationType: TopAlertPresentationType?
    private var alertClass: TopAlertViewProtocol.Type?
    private var alertPosition: TopAlertPresentationPosition?
    private var alertTapGesture: UITapGestureRecognizer?
    
    public var currentAlert: TopAlertViewProtocol?
    public var currentTimer: Timer?
    private let defaultDuration: Double = 3.0
    
    public class func setup(_ alertClass: TopAlertViewProtocol.Type?) -> TopAlertController {
        TopAlertController.shared.alertClass = alertClass
        return TopAlertController.shared
    }
    
    public func showAlert(
        title: LocalizedStylableText? = nil,
        _ alert: LocalizedStylableText,
        alertType: TopAlertType,
        duration: Double? = nil,
        position: TopAlertPresentationPosition = .top) {
        self.alertType = alertType
        self.alertPresentationType = duration.map(TopAlertPresentationType.duration) ?? .duration(self.defaultDuration)
        self.alertPosition = position
        self.messages.append(MessagesTuple(title: title, message: alert))
    }
    
    public func showAlert(
        title: LocalizedStylableText? = nil,
        _ alert: LocalizedStylableText,
        alertType: TopAlertType,
        presentationType: TopAlertPresentationType,
        position: TopAlertPresentationPosition = .top) {
        self.alertType = alertType
        self.alertPresentationType = presentationType
        self.alertPosition = position
        self.messages.append(MessagesTuple(title: title, message: alert))
    }
    
    public func showAlertWithTap(
        title: LocalizedStylableText? = nil,
        _ alert: LocalizedStylableText,
        alertType: TopAlertType,
        presentationType: TopAlertPresentationType,
        position: TopAlertPresentationPosition = .top,
        tapGesture: UITapGestureRecognizer?) {
        self.alertType = alertType
        self.alertPresentationType = presentationType
        self.alertPosition = position
        self.alertTapGesture = tapGesture
        self.messages.append(MessagesTuple(title: title, message: alert))
    }
    
    public func removeAlert(_ completion: (() -> Void)? = nil) { dismissCurrent(animated: true, completion) }
    
    // MARK: - privateMethods
    
    private func present(_ message: MessagesTuple) {
        guard currentAlert != nil else { return continuePresenting(position: self.alertPosition ?? .top, title: message.title, message: message.message, alertType: self.alertType ?? .failure) }
        dismissCurrent(animated: true) { [weak self] in
            self?.continuePresenting(position: self?.alertPosition ?? .top, title: message.title, message: message.message, alertType: self?.alertType ?? .failure)
        }
    }
    
    private func continuePresenting(
        position: TopAlertPresentationPosition,
        title: LocalizedStylableText?,
        message: LocalizedStylableText,
        alertType: TopAlertType
    ) {
        currentAlert = alertClass?.presentAlert(title: title, message: message, superview: nil, type: alertType, presentationType: self.alertPresentationType ?? .duration(self.defaultDuration), position: position, tapGesture: alertTapGesture) { [weak self] in
            guard let self = self, case .duration(let time) = self.alertPresentationType else { return }
            self.currentTimer = Timer.scheduledTimer(withTimeInterval: time,
                                                     repeats: false) { [weak self] in
                                                        $0.invalidate()
                                                        self?.currentTimer = nil
                                                        self?.dismissCurrent(animated: true)
            }
        }
    }
    
    private func dismissCurrent(animated: Bool, _ extraAction: (() -> Void)? = nil) {
        guard let currentAlert = self.currentAlert else { extraAction?(); return }
        currentAlert.dismiss(true) { [weak self] in
            self?.resetCurrent()
            self?.forceDismiss()
            extraAction?()
        }
    }
    
    private func resetCurrent() {
        currentAlert = nil
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    private func forceDismiss() {
        guard let alertClass = self.alertClass else { return }
        guard var alerts = UIApplication.shared.windows.first?.subviews.filter({ $0.isKind(of: alertClass) }),
            !alerts.isEmpty else { return }
        let first = alerts.removeFirst()
        (first as? TopAlertViewProtocol)?.dismiss(true, completion: nil)
        alerts.forEach({ $0.removeFromSuperview() })
    }
}
