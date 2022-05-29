//
//  ContactDetailFooterView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol ContactDetailFooterDelegate: AnyObject {
    func didSelectDeleteContact()
    func didSelectEditContact()
}

class ContactDetailFooterView: XibView {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: ContactDetailFooterDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.delegate?.didSelectDeleteContact()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.delegate?.didSelectEditContact()
    }
}

private extension ContactDetailFooterView {
    func setupView() {
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    func setAppearance() {
        self.setButtonStyle(to: self.deleteButton,
                            textKey: "favoriteRecipients_button_deleteContact",
                            imageKey: "icnRemoveGreen")
        self.setButtonStyle(to: self.editButton,
                            textKey: "favoriteRecipients_button_editContact",
                            imageKey: "icnEdit")
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setButtonStyle(to button: UIButton, textKey: String, imageKey: String) {
        self.setButtonImage(to: button, with: imageKey)
        self.setButtonTextStyle(to: button, with: textKey)
        button.tintColor = .darkTorquoise
        self.setButtonWidth(to: button)
    }
    
    func setButtonImage(to button: UIButton, with imageKey: String) {
        let image = self.setImageSize(from: Assets.image(named: imageKey), newSize: 24)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
    }
    
    func setButtonTextStyle(to button: UIButton, with key: String) {
        button.titleLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        button.titleLabel?.textColor = .darkTorquoise
        button.setTitle(localized(key), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    
    func setButtonWidth(to button: UIButton) {
        let imageWidth: CGFloat = button.imageView?.frame.width ?? 0
        let textWidth: CGFloat = button.titleLabel?.intrinsicContentSize.width ?? 0
        let buttonWidth = textWidth + imageWidth + 5
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.layoutIfNeeded()
    }
    
    func setImageSize(from originalImage: UIImage?, newSize: CGFloat) -> UIImage? {
        guard let image = originalImage else { return originalImage }
        let canvasSize = CGSize(width: newSize, height: newSize)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func setAccessibilityIdentifiers() {
        self.deleteButton.titleLabel?.accessibilityIdentifier = AccessibilityContactDetail.contactDetailLabelDeleteContactTitle
        self.deleteButton.imageView?.accessibilityIdentifier = AccessibilityContactDetail.contactDetailViewDeleteContactImage
        self.deleteButton.accessibilityIdentifier = AccessibilityContactDetail.contactDetailBtnDeleteContact
        self.editButton.accessibilityIdentifier = AccessibilityContactDetail.contactDetailBtnEditContact
        self.editButton.titleLabel?.accessibilityIdentifier = AccessibilityContactDetail.contactDetailLabelEditContactTitle
        self.editButton.imageView?.accessibilityIdentifier = AccessibilityContactDetail.contactDetailViewEditContactImage
    }
}
