//
//  ContactDetailAccountView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol ContactsDetailAccountDelegate: AnyObject {
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel)
    func didSelectNewTransfer()
}

final class ContactDetailAccountView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var bankLogoImageView: UIImageView!
    @IBOutlet private weak var newTransferView: UIView!
    @IBOutlet private weak var newTransferIconImageView: UIImageView!
    @IBOutlet private weak var newTransferLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var bankImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bankImageWidthConstraint: NSLayoutConstraint!
    weak var delegate: ContactsDetailAccountDelegate?
    private var viewModel: ContactDetailItemViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: ContactDetailItemViewModel) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withKey: viewModel.itemTitleKey)
        self.accountNumberLabel.text = viewModel.itemValue
        self.setBankImage(viewModel.baseURL)
        self.setAccessibilityIdentifiers()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectShareAccount(viewModel)
    }
}

private extension ContactDetailAccountView {
    func setAppearance() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 16.0)
        self.accountNumberLabel.textColor = .lisboaGray
        self.accountNumberLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.shareImageView.image = Assets.image(named: "icnShareSlimGreen")
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setNewTransfer()
    }
    
    func setNewTransfer() {
        self.newTransferIconImageView.image = Assets.image(named: "icnEuroDestinationAccount")
        self.newTransferLabel.textColor = .santanderRed
        self.newTransferLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.newTransferLabel.text = localized("generic_buttom_newSend")
        self.setNewTransferView()
    }
    
    func setBankImage(_ baseURL: String?) {
        guard let imageUrl = baseURL else {
            self.bankLogoImageView.image = nil
            return
        }
        self.bankLogoImageView.loadImage(urlString: imageUrl) {
            Async.main { [weak self] in
                self?.setBankImageWidth()
            }
        }
    }
    
    func setBankImageWidth() {
        if let iconUrlSize = self.bankLogoImageView?.image?.size {
            let height = self.bankImageHeightConstraint.constant
            let newWidth = (iconUrlSize.width * height) / iconUrlSize.height
            if let viewWidth = self.view?.frame.width {
                let maxWidth = viewWidth * 0.2
                self.bankImageWidthConstraint.constant = newWidth > maxWidth ? maxWidth : newWidth
            } else {
                self.bankImageWidthConstraint.constant = newWidth
            }
        } else {
            self.bankLogoImageView.image = nil
            self.bankImageWidthConstraint.constant = 0
        }
    }
    
    func setNewTransferView() {
        self.newTransferView.layer.cornerRadius = self.newTransferView.bounds.size.height / 2
        self.newTransferView.layer.borderColor = UIColor.santanderRed.cgColor
        self.newTransferView.layer.borderWidth = 1.0
        self.newTransferView.backgroundColor = .white
        self.setNewTransferGesture()
    }
    
    func setNewTransferGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(newTransferButtonPressed))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.allowableMovement = 0.0
        self.newTransferView.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    func newTransferButtonPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.newTransferView.backgroundColor = .skyGray
        } else if gestureRecognizer.state == .ended {
            self.newTransferView.backgroundColor = .white
            self.delegate?.didSelectNewTransfer()
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityContactDetail.accountContainer
        self.titleLabel.accessibilityIdentifier = viewModel?.itemTitleKey
        self.accountNumberLabel.accessibilityIdentifier = AccessibilityContactDetail.accountValue
        self.bankLogoImageView.accessibilityIdentifier = AccessibilityContactDetail.accountImageBank
        self.shareImageView.accessibilityIdentifier = AccessibilityContactDetail.accountShareImageView
        self.shareButton.accessibilityIdentifier = AccessibilityContactDetail.accountBtnShare
        self.newTransferView.accessibilityIdentifier = AccessibilityContactDetail.accountBtnNewTransfer
        self.newTransferIconImageView.accessibilityIdentifier = AccessibilityContactDetail.accountNewTransferImage
        self.newTransferLabel.accessibilityIdentifier = AccessibilityContactDetail.accountNewTransferTitle
    }
}
