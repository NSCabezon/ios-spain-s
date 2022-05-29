//
//  TopAlertView.swift
//  toTest
//
//  Created by alvola on 30/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol TopAlertViewProtocol: AnyObject {
    static func presentAlert(title: LocalizedStylableText?, message: LocalizedStylableText, superview: UIView?, type: TopAlertType, presentationType: TopAlertPresentationType, position: TopAlertPresentationPosition, tapGesture: UITapGestureRecognizer?, action: @escaping () -> Void) -> TopAlertViewProtocol?
    func dismiss(_ animated: Bool, completion: (() -> Void)?)
}

public final class TopAlertView: UIView, TopAlertViewProtocol {
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var titleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapGestureView: UIView!
    private var invisibleBackgroundView: UIView?
    var bottomConstraint: NSLayoutConstraint?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    public static func presentAlert(
        title: LocalizedStylableText?,
        message: LocalizedStylableText,
        superview: UIView?,
        type: TopAlertType,
        presentationType: TopAlertPresentationType,
        position: TopAlertPresentationPosition,
        tapGesture: UITapGestureRecognizer?,
        action: @escaping () -> Void) -> TopAlertViewProtocol? {
        guard let view = superview ?? UIApplication.shared.windows.first else { return nil }
        guard let bundle = Bundle.module else { return nil }
        guard let alertView = bundle.loadNibNamed("TopAlertView",
                                                  owner: self,
                                                  options: nil)?.first as? TopAlertView else { return nil }
        switch type {
        case .info:
            alertView.setOkAppearance()
        case .failure:
            alertView.setErrorAppearance()
        case .message:
            alertView.setMessageAppearance()
        }
        alertView.titleLabelConstraint.constant = 0
        alertView.textView?.configureText(withLocalizedString: message)
        if let title = title {
            alertView.titleLabel.configureText(withLocalizedString: title)
            alertView.titleLabelConstraint.constant = 26
        }
        if let hasGesture = tapGesture {
            alertView.tapGestureView.addGestureRecognizer(hasGesture)
        }
        switch presentationType {
        case .infinite:
            alertView.textView?.delegate = alertView
            alertView.addBackgroundInvisibleView(to: view)
            alertView.invisibleBackgroundView?.isAccessibilityElement = true
        case .duration:
            alertView.accessibilityViewIsModal = true
        }
        alertView.add(position: position, view: view, completion: action)
        alertView.textView?.sizeToFit()
        return alertView
    }
    
    public func dismiss(_ animated: Bool, completion: (() -> Void)? = nil) {
        guard !animated else { return hideAlert(completion: completion) }
        removeFromSuperview()
        completion?()
    }
    
    private func commonInit() {
        self.textView?.font = .santander(size: 14.0)
        self.textView?.textColor = .bostonRed
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        self.titleLabel.textColor = .lisboaGray
        setAccesibilityIdentifiers()
    }
    
    private func setErrorAppearance() {
        textView?.font = UIFont.santander(size: 14.0)
        textView?.textColor = UIColor.bostonRed
        icon?.image = Assets.image(named: "icnDanger")
        self.layoutIfNeeded()
    }
    
    private func setMessageAppearance() {
        textView?.font = UIFont.santander(size: 16.0)
        textView?.textColor = UIColor.lisboaGray
        icon?.image = Assets.image(named: "icnInfoLayer")
        self.layoutIfNeeded()
    }
    
    private func setOkAppearance() {
        textView?.font = UIFont.santander(size: 14.0)
        textView?.textColor = UIColor.lisboaGray
        icon?.image = Assets.image(named: "icnOk")
        self.layoutIfNeeded()
    }
    
    private func setAccesibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityTopAlert.alertLogin.rawValue
        self.textView?.accessibilityIdentifier = AccessibilityTopAlert.alertView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityTopAlert.alertTitleLabel.rawValue
        self.icon?.accessibilityIdentifier = AccessibilityTopAlert.icnAlertView.rawValue
    }
    
    private func addBackgroundInvisibleView(to view: UIView) {
        let invisibleView = UIView()
        invisibleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(invisibleViewSelected)))
        view.addSubview(invisibleView)
        invisibleView.fullFit()
        self.invisibleBackgroundView = invisibleView
    }

    private func add(position: TopAlertPresentationPosition, view: UIView, completion: @escaping () -> Void) {
        view.addSubview(self)
        let center = NSLayoutConstraint(item: self as Any,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: 0)
        let width = NSLayoutConstraint(item: self as Any,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self as Any,
                                              attribute: position == .top ? .bottom : .top,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: position == .top ? .top : .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0)
        self.bottomConstraint = bottomConstraint
        view.addConstraints([center, bottomConstraint, width])
        if Screen.hasTopNotch && position == .top {
            self.titleLabelTopConstraint.constant = 40
        }
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        view.layoutSubviews()
        addShadow(offset: CGSize(width: 0.0,
                                 height: 2.0),
                  color: .black,
                  opacity: 0.5,
                  radius: 4.0)
        showAlert(position: position, completion: completion)
    }
    
    @objc private func invisibleViewSelected() {
        self.dismiss(true) {
            self.invisibleBackgroundView?.removeFromSuperview()
        }
    }
    
    private func showAlert(position: TopAlertPresentationPosition, completion: (() -> Void)? = nil) {
        self.superview?.layoutIfNeeded()
        bottomConstraint?.constant = position == .top ? frame.height : -frame.height
        setNeedsLayout()
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.superview?.layoutIfNeeded()
            },
                       completion: { _ in
                        completion?()
        })
    }
    
    private func hideAlert(completion: (() -> Void)? = nil) {
        bottomConstraint?.constant = 0.0
        setNeedsLayout()
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.superview?.layoutIfNeeded()
            },
                       completion: { [weak self] _ in
                        self?.invisibleBackgroundView?.removeFromSuperview()
                        self?.removeFromSuperview()
                        completion?()
        })
    }
    public override func accessibilityPerformEscape() -> Bool {
        self.invisibleViewSelected()
        return true
    }
    
}

extension TopAlertView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.dismiss(true) {
            self.invisibleBackgroundView?.removeFromSuperview()
        }
        return true
    }
}

public enum TopAlertType {
    case info
    case failure
    case message
}

public enum TopAlertPresentationType {
    case infinite
    case duration(TimeInterval)
}

public enum TopAlertPresentationPosition {
    case top
    case bottom
}
