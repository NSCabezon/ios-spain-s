//
//  ContactsView.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 04/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol ContactsViewDelegate: AnyObject {
    func didTapOnSeeContact()
    func didTapOnNewShipment()
    func didTapOnNewContact()
    func didTapOnContact(_ viewModel: ContactViewModel)
    func didSwipeContacts()
}

final class ContactsView: XibView {
    @IBOutlet weak var collectionView: ContactsCollectionView!
    @IBOutlet weak var sendTitleLabel: UILabel!
    @IBOutlet weak var contactsButton: UIButton!
    weak var delegate: ContactsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func showLoading() {
        self.collectionView.showLoading()
    }
    
    func set(_ viewModels: [ContactViewModel]) {
        self.collectionView.set(viewModels)
    }
    
    private func setupView() {
        self.view?.heightAnchor.constraint(equalToConstant: 237).isActive = true
        self.collectionView.contactsCollectionViewDelegate = self
        self.collectionView.setup()
        self.configureHeader()
        self.contactsButton.addTarget(self, action: #selector(contactsButtonSelected), for: .touchUpInside)
        self.setupAccessibilityId()
    }
    
    private func configureHeader() {
        self.sendTitleLabel.text = localized("transfer_title_sendTo")
        self.sendTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        self.sendTitleLabel.textColor = UIColor.lisboaGray
        self.contactsButton.setTitle(localized("transfer_label_seeContacts"), for: .normal)
        self.contactsButton.tintColor = UIColor.darkTorquoise
        self.contactsButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14)
    }
    
    @objc private func contactsButtonSelected() {
        self.delegate?.didTapOnSeeContact()
    }
}

extension ContactsView: ContactsCollectionViewDelegate {
    func didSelectNewShipment() {
        self.delegate?.didTapOnNewShipment()
    }
    
    func didSelectNewContact() {
        self.delegate?.didTapOnNewContact()
    }
    
    func didSelectContact(_ viewModel: ContactViewModel) {
        self.delegate?.didTapOnContact(viewModel)
    }
    
    func didSwipe() {
        self.delegate?.didSwipeContacts()
    }
}

private extension ContactsView {
    func setupAccessibilityId() {
        self.contactsButton.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnSeeContacts
        self.sendTitleLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelTitle
    }
}
