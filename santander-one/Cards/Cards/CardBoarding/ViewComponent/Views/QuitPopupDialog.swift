//
//  QuitPopupDialog.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol QuitPopupDialogDelegate: AnyObject {
    func didSelectQuit()
    func didSelectResume()
}

final class QuitPopupDialog: XibView {
    private weak var delegate: QuitPopupDialogDelegate?
    @IBOutlet private weak var closeImage: UIImageView!
    @IBOutlet private weak var popupView: UIView!
    @IBOutlet private weak var sanImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var exitButton: RedLisboaButton!
    @IBOutlet private weak var resumeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setDelegate(_ delegate: QuitPopupDialogDelegate?) {
        self.delegate = delegate
    }
    
    @IBAction func didSelectQuit(_ sender: Any) {
        self.resume()
    }
    
    @IBAction func didSelectResume(_ sender: Any) {
        self.resume()
    }
    
    func show(over parentView: UIView) {
        parentView.addSubview(self)
        self.fullFit()
        self.displayAnimation()
    }
    
    func resume(completion: (() -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 25) { [weak self] in
                self?.popupView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) { [weak self] in
                self?.alpha = 0
                self?.popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }}) { [weak self] completed in
                guard completed else { return }
                self?.removeFromSuperview()
                completion?()
            }
    }
}

private extension QuitPopupDialog {
    private func setup() {
        self.alpha = 0
        self.closeImage.image = Assets.image(named: "icnClose")
        self.sanImageView.image = Assets.image(named: "icnSanRedBigAlert")
        self.view?.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.7)
        self.popupView.drawBorder(cornerRadius: 5, color: .mediumSky, width: 1)
        self.resumeButton.setTitleColor(.darkTorquoise, for: .normal)
        self.exitButton.addSelectorAction(target: self, #selector(didSelectExit))
        self.exitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setAccessibilityIdentifiers()
        self.setTexts()
    }
    
    @objc
    private func didSelectExit() {
        self.resume { [weak self] in
            self?.delegate?.didSelectQuit()
        }
    }
    
    func displayAnimation() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) { [weak self] in
                self?.alpha = 1
                self?.popupView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) { [weak self] in
                self?.popupView.transform = .identity
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
            }
        })
    }
    
    func setTexts() {
        self.titleLabel.configureText(withKey: "onboarding_alert_title_completeActivation")
        self.descriptionLabel.configureText(withKey: "cardBoarding_alert_text_remember")
        self.exitButton.set(localizedStylableText: localized("generic_button_exitProcess"), state: .normal)
        self.resumeButton.set(localizedStylableText: localized("cardBoarding_button_customizeCard"), state: .normal)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.descriptionLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setAccessibilityIdentifiers() {
        self.closeImage.accessibilityIdentifier = AccessibilityCardBoarding.Popup.closeImage
        self.popupView.accessibilityIdentifier = AccessibilityCardBoarding.Popup.popupViuew
        self.sanImageView.accessibilityIdentifier = AccessibilityCardBoarding.Popup.sanImage
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Popup.title
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.Popup.descriptionText
        self.exitButton.accessibilityIdentifier = AccessibilityCardBoarding.Popup.exitButton
        self.resumeButton.accessibilityIdentifier = AccessibilityCardBoarding.Popup.resumeButton
    }
}
