//
//  ResumePopupView.swift
//  toTest
//
//  Created by alvola on 02/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

public final class ResumePopupView: UIView, TopWindowViewProtocol {

    @IBOutlet weak var popupFrameView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: RedLisboaButton!
    @IBOutlet weak var cancelButton: WhiteLisboaButton!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    private var onAction: ((_ exitConfirmed: Bool, _ checkButtonSelected: Bool) -> Void)?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    public static func presentPopup(title: LocalizedStylableText,
                                    description: LocalizedStylableText,
                                    confirmTitle: LocalizedStylableText,
                                    cancelTitle: LocalizedStylableText,
                                    font: UIFont?,
                                    hideCheckView: Bool,
                                    in superview: UIView? = nil,
                                    response: @escaping (Bool, Bool) -> Void) {
        guard let view = superview ?? UIApplication.shared.windows.first else { return }
        guard let popupView = Bundle.module?.loadNibNamed("ResumePopupView",
                                                          owner: self,
                                                          options: nil)?.first as? ResumePopupView
        else { return }
        
        popupView.titleLabel.set(localizedStylableText: title)
        popupView.descriptionLabel.set(localizedStylableText: description)
        popupView.confirmButton.setTitle(confirmTitle.text, for: UIControl.State.normal)
        popupView.cancelButton.setTitle(cancelTitle.text, for: UIControl.State.normal)
        popupView.confirmButton.accessibilityIdentifier = "btnYes"
        popupView.cancelButton.accessibilityIdentifier = "btnCancel"
        if let titleFont = font {
            popupView.confirmButton.titleLabel?.font = titleFont
            popupView.cancelButton.titleLabel?.font = titleFont
        }
        if hideCheckView {
            popupView.configureCheckView(true)
        }
        popupView.onAction = response
        
        popupView.add(to: view)
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureFrame()
        configureLabels()
        configureButtons()
    }
    
    private func configureFrame() {
        backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.7)
        popupFrameView.backgroundColor = UIColor.white
        popupFrameView.layer.cornerRadius = 5.0
        separator.backgroundColor = .mediumSkyGray
    }
    
    private func configureLabels() {
        checkLabel.text = localized("onboarding_label_notShow")
        
        checkLabel.applyStyle(LabelStylist(textColor: UIColor.mediumSanGray,
                                           font: UIFont.santander(family: .text, type: .regular, size: 14),
                                           textAlignment: .left))
        checkLabel.isUserInteractionEnabled = true
        checkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkButtonAction)))
        titleLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                           font: UIFont.santander(family: .headline, type: .regular, size: 27),
                                           textAlignment: .center))
        descriptionLabel.applyStyle(LabelStylist(textColor: UIColor.lisboaGray,
                                                 font: UIFont.santander(family: .text, type: .light, size: 20),
                                                 textAlignment: .center))
        descriptionLabel.set(lineHeightMultiple: 0.85)
        logoImage.image = Assets.image(named: "icnSanRedBigAlert")
    }
    
    private func configureButtons() {
        closeButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        cancelButton.addSelectorAction(target: self, #selector(cancelButtonPressed))
        confirmButton.addSelectorAction(target: self, #selector(confirmButtonPressed))
        checkButton.isSelected = false
        checkButton.tintColor = UIColor.lightSanGray
        checkButton.setImage(Assets.image(named: "icnCheckWhite")?.withRenderingMode(.alwaysTemplate),
                             for: .selected)
        checkButton.setImage(Assets.image(named: "icnCheckbox")?.withRenderingMode(.alwaysTemplate),
                             for: .normal)
        closeButton.setImage(Assets.image(named: "icnCloseRed"), for: .normal)
    }
    
    private func configureCheckView(_ hide: Bool) {
        separator.isHidden = hide
        checkButton.isHidden = hide
        checkLabel.isHidden = hide
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        checkButton.tintColor = checkButton.isSelected ? .lightSanGray : .darkTorquoise
        checkButton.isSelected.toggle()
    }
    
    private func add(to view: UIView) {
        view.addSubview(self)
        
        let centerX = NSLayoutConstraint(item: self as Any, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerY = NSLayoutConstraint(item: self as Any, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let width = NSLayoutConstraint(item: self as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: self as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
        
        view.addConstraints([centerX, centerY, width, height])
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        view.layoutSubviews()
        
        showPopup()
    }
    
    private func showPopup() {
        self.alpha = 0.0
        popupFrameView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            self.popupFrameView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                strongSelf.popupFrameView.transform = CGAffineTransform.identity
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
            })
        })
    }
    
    private func hidePopup() {
        UIView.animate(withDuration: 0.15, animations: {
            self.popupFrameView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                strongSelf.popupFrameView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                strongSelf.alpha = 0.0
            }, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.removeFromSuperview()
            })
        })
    }
    
    @objc private func cancelButtonPressed() {
        hidePopup()
        onAction?(false, false)
    }
    
    @objc private func confirmButtonPressed() {
        hidePopup()
        onAction?(true, checkButton.isSelected)
    }
}
