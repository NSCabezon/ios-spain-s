//
//  ContactDetailView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 30/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol ContactDetailViewDelegate: AnyObject {
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel)
    func didSelectNewTransfer()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

final class ContactDetailView: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var topShadow: UIView!
    
    private let scrollableStackView = ScrollableStackView()
    weak var delegate: ContactDetailViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: ContactDetailViewModel) {
        self.addHeaderView(viewModel)
        self.setViewModelItems(viewModel)
        self.topShadow.backgroundColor = .mediumSkyGray
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
}

private extension ContactDetailView {
    func setAppearance() {
        self.scrollableStackView.setup(with: self.contentView)
        self.scrollableStackView.setScrollDelegate(self)
        self.scrollableStackView.setBounce(enabled: false)
    }
    
    func setViewModelItems(_ viewModel: ContactDetailViewModel) {
        let viewModels = ContactDetailItemsFactory.getContactsDetailViewModels(contactDetailViewModel: viewModel)
        viewModels.forEach { viewModel in
            self.setViewModelToContactsDetailView(viewModel)
        }
    }
    
    func setViewModelToContactsDetailView(_ viewModel: ContactDetailItemViewModel) {
        switch viewModel.type {
        case .account:
            self.addAccountView(viewModel)
        case .detail:
            self.addDetailItemView(viewModel)
        }
    }
    
    func addHeaderView(_ viewModel: ContactDetailViewModel) {
        let contactDetailHeader = ContactDetailHeaderView()
        contactDetailHeader.setViewModel(viewModel)
        self.scrollableStackView.addArrangedSubview(contactDetailHeader)
    }
    
    func addAccountView(_ viewModel: ContactDetailItemViewModel) {
        let accountDetailView = ContactDetailAccountView()
        accountDetailView.setViewModel(viewModel)
        accountDetailView.delegate = self
        self.scrollableStackView.addArrangedSubview(accountDetailView)
    }
    
    func addDetailItemView(_ viewModel: ContactDetailItemViewModel) {
        let detailView = ContactDetailItemView()
        detailView.setViewModel(viewModel)
        self.scrollableStackView.addArrangedSubview(detailView)
    }
}

extension ContactDetailView: ContactsDetailAccountDelegate {
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel) {
        self.delegate?.didSelectShareAccount(viewModel)
    }
    
    func didSelectNewTransfer() {
        self.delegate?.didSelectNewTransfer()
    }
}

extension ContactDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
        self.delegate?.scrollViewDidScroll(scrollView)
    }
}

private extension ContactDetailView {
    func setAccessibilityIdentifiers() {
        self.scrollableStackView.accessibilityIdentifier = AccessibilityTransferFavorites.sendMoneyListFavouriteRecipients.rawValue
    }
}
