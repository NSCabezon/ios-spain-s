//
//  AccountFinanceableTransactionsView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation
import CoreFoundationLib
import UI

enum AccountCarouselViewState {
    case emptyTransactions
    case filled(viewModels: [AccountFinanceableTransactionViewModel])
    case loading
}

protocol AccountFinanceableViewDelegate: AnyObject {
    func didSelectSeeAllFinanceableTransactions(from account: AccountFinanceableViewModel)
    func didSelectAccountTransaction(_ accountTransaction: AccountFinanceableTransactionViewModel)
    func didSelectAccount(_ viewModel: AccountFinanceableViewModel)
    func selectorDetailDisplayed(_ isDisplayed: Bool)
}

final class AccountFinanceableTransactionsView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var transactionsCollectionView: AccountFinanceableTransactionsCollectionView!
    @IBOutlet weak var separatorView: UIView!
    
    private let header = AccountFinanceableTransactionsHeaderView()
    private let accountsSelector = FinanceableProductSelectorView<AccountFinanceableViewModel>()
    private let loadingView = FinanceableLoadingView()
    private let emptyView = FinanceableEmptyView()
    private var viewModel: AccountsCarouselViewModel?
    private var selectedAccount: AccountFinanceableViewModel?
    private var transactions: [AccountFinanceableTransactionViewModel] = []
    weak var delegate: AccountFinanceableViewDelegate?
    private var state: AccountCarouselViewState = .loading
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: AccountsCarouselViewModel) {
        self.viewModel = viewModel
        self.selectedAccount = viewModel.selectedAccount
        self.setSelector(with: viewModel.accounts)
    }
    
    func setViewState(_ state: AccountCarouselViewState) {
        switch state {
        case .emptyTransactions:
            self.setEmptyTransactionsState()
        case .loading:
            self.setLoadingState()
        case .filled(let viewModels):
            self.setFilledState(viewModels)
        }
        self.layoutIfNeeded()
    }
}

private extension AccountFinanceableTransactionsView {
    
    func setAppearance() {
        self.setStackView()
        self.setCollectionView()
        self.separatorView.backgroundColor = .mediumSkyGray
        self.header.delegate = self
        self.accountsSelector.delegate = self
        self.setDefaultState()
    }
    
    func setStackView() {
        self.stackView.addArrangedSubview(self.header)
        self.stackView.addArrangedSubview(self.accountsSelector)
        self.stackView.addArrangedSubview(self.loadingView)
        self.stackView.addArrangedSubview(self.transactionsCollectionView)
        self.stackView.addArrangedSubview(self.emptyView)
    }
    
    func setSelector(with accountsList: [AccountFinanceableViewModel]) {
        self.accountsSelector.configureWithProducts(accountsList, title: localized("financing_hint_chooseAccount")) { selected in
            self.selectedAccount = selected
            self.delegate?.didSelectAccount(selected)
        }
        self.accountsSelector.setDropdownAccessibilityIdentifier(AccessibilityFinancingAccountCarousel.accountSelector)
    }
    
    func setCollectionView() {
        self.transactionsCollectionView.setDelegate(delegate: self)
        self.transactionsCollectionView.heightAnchor.constraint(equalToConstant: 137).isActive = true
        self.transactionsCollectionView.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.financingCarouselAccount
    }
    
    func setEmptyTransactionsState() {
        guard let viewModel = self.viewModel else { return }
        self.emptyView.isHidden = false
        self.emptyView.setDescriptionLabelHidden()
        self.header.setSeeAllButtonHidden(false)
        self.accountsSelector.isHidden = viewModel.isSelectorHidden
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = true
    }
    
    func setLoadingState() {
        guard let viewModel = self.viewModel else { return }
        self.emptyView.isHidden = true
        self.header.setSeeAllButtonHidden(true)
        self.accountsSelector.isHidden = viewModel.isSelectorHidden
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = false
    }
    
    func setFilledState(_ viewModels: [AccountFinanceableTransactionViewModel]) {
        guard let viewModel = self.viewModel else { return }
        self.header.setSeeAllButtonHidden(false)
        self.accountsSelector.isHidden = viewModel.isSelectorHidden
        self.emptyView.isHidden = true
        self.transactionsCollectionView.isHidden = false
        self.transactionsCollectionView.setCollectionViewData(viewModels)
        self.transactionsCollectionView.reloadData()
        self.loadingView.isHidden = true
    }
    
    func setDefaultState() {
        self.emptyView.isHidden = true
        self.header.setSeeAllButtonHidden(true)
        self.accountsSelector.isHidden = true
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = false
        self.layoutIfNeeded()
    }
}

extension AccountFinanceableTransactionsView: AccountFinanceableTransactionsCollectionDataSourceDelegate {
    func didSelectAccountFinanceableTransaction(_ transaction: AccountFinanceableTransactionViewModel) {
        self.delegate?.didSelectAccountTransaction(transaction)
    }
}

extension AccountFinanceableTransactionsView: AccountFinanceableTransactionsHeaderViewDelegate {
    func didSelectSeeAllFinanceableTransactions() {
        guard let selectedAccount = self.selectedAccount else { return }
        self.delegate?.didSelectSeeAllFinanceableTransactions(from: selectedAccount)
    }
}

extension AccountFinanceableTransactionsView: FinanceableProductSelectorDetailDelegate {
    func selectorDisplaysDetailView(_ isDisplayed: Bool) {
        self.delegate?.selectorDetailDisplayed(isDisplayed)
    }
}
