//
//  CardFinanceableTransactionsView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 29/06/2020.
//

import Foundation
import UI
import CoreFoundationLib

enum CardsCarouselViewState {
    case emptyCards
    case emptyTransactions
    case filled(viewModels: [CardFinanceableTransactionViewModel])
    case loading
}

protocol CardFinanceableTransactionsViewDelegate: AnyObject {
    func didSelectSeeAllFinanceableTransactions(_ card: CardFinanceableViewModel)
    func didSelectCardBankableTransaction(_ cardBankableTransaction: CardFinanceableTransactionViewModel)
    func didSelectCard(_ viewModel: CardFinanceableViewModel)
    func didSelectHireCard(_ location: PullOfferLocation?)
    func selectorDetailDisplayed(_ isDisplayed: Bool)
}

final class CardFinanceableTransactionsView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var transactionsCollectionView: CardFinanceableTransactionsCollectionView!
    @IBOutlet weak var separatorView: UIView!
    private let header = CardFinanceableTransactionsHeaderView()
    private let cardsSelector = FinanceableProductSelectorView<CardFinanceableViewModel>()
    private let loadingView = FinanceableLoadingView()
    private let emptyCardsView = EmptyCardsFinanceableView()
    private let emptyTransactionsView = FinanceableEmptyView()
    private var viewModel: CardsCarouselViewModel?
    private var selectedCard: CardFinanceableViewModel?
    private var transactions: [CardFinanceableTransactionViewModel] = []
    weak var delegate: CardFinanceableTransactionsViewDelegate?
    private var state: CardsCarouselViewState = .loading
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: CardsCarouselViewModel) {
        self.viewModel = viewModel
        self.selectedCard = viewModel.selectedCard
        self.setCardsSelector(with: viewModel.cards)
    }
    
    func setViewState(_ state: CardsCarouselViewState) {
        switch state {
        case .emptyCards:
            self.setEmptyCardsState()
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

private extension CardFinanceableTransactionsView {
    
    func setAppearance() {
        self.setStackView()
        self.setCollectionView()
        self.separatorView.backgroundColor = .mediumSkyGray
        self.header.delegate = self
        self.emptyCardsView.delegate = self
        self.cardsSelector.delegate = self
        self.setDefaultState()
    }
    
    func setStackView() {
        self.stackView.addArrangedSubview(self.header)
        self.stackView.addArrangedSubview(self.cardsSelector)
        self.stackView.addArrangedSubview(self.loadingView)
        self.stackView.addArrangedSubview(self.emptyCardsView)
        self.stackView.addArrangedSubview(self.transactionsCollectionView)
        self.stackView.addArrangedSubview(self.emptyTransactionsView)
    }
    
    func setCardsSelector(with cardsList: [CardFinanceableViewModel]) {
        self.cardsSelector.configureWithProducts(cardsList, title: localized("financing_hint_chooseCard")) { selected in
            self.selectedCard = selected
            self.delegate?.didSelectCard(selected)
        }
        self.cardsSelector.setDropdownAccessibilityIdentifier(AccessibilityFinancingCardCarousel.cardSelector)
    }
    
    func setCollectionView() {
        self.transactionsCollectionView.setDelegate(delegate: self)
        self.transactionsCollectionView.heightAnchor.constraint(equalToConstant: 137).isActive = true
        self.transactionsCollectionView.accessibilityIdentifier = AccessibilityFinancingCardCarousel.financingCarouselCard
    }
    
    func setEmptyCardsState() {
        guard let viewModel = self.viewModel else { return }
        self.emptyCardsView.setViewModel(EmptyCardsFinanceableViewModel(viewModel))
        self.emptyCardsView.isHidden = false
        self.header.setSeeAllButtonHidden(true)
        self.cardsSelector.isHidden = true
        self.emptyTransactionsView.isHidden = true
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = true
    }
    
    func setEmptyTransactionsState() {
        guard let viewModel = self.viewModel else { return }
        self.emptyTransactionsView.isHidden = false
        self.header.setSeeAllButtonHidden(false)
        self.cardsSelector.isHidden = viewModel.isCardSelectorHidden
        self.emptyCardsView.isHidden = true
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = true
    }
    
    func setLoadingState() {
        guard let viewModel = self.viewModel else { return }
        self.emptyTransactionsView.isHidden = true
        self.header.setSeeAllButtonHidden(true)
        self.cardsSelector.isHidden = viewModel.isCardSelectorHidden
        self.emptyCardsView.isHidden = true
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = false
    }
    
    func setFilledState(_ viewModels: [CardFinanceableTransactionViewModel]) {
        guard let viewModel = self.viewModel else { return }
        self.emptyCardsView.isHidden = true
        self.header.setSeeAllButtonHidden(false)
        self.cardsSelector.isHidden = viewModel.isCardSelectorHidden
        self.emptyTransactionsView.isHidden = true
        self.transactionsCollectionView.isHidden = false
        self.transactionsCollectionView.setCollectionViewData(viewModels)
        self.transactionsCollectionView.reloadData()
        self.loadingView.isHidden = true
    }
    
    func setDefaultState() {
        self.emptyTransactionsView.isHidden = true
        self.header.setSeeAllButtonHidden(true)
        self.cardsSelector.isHidden = true
        self.emptyCardsView.isHidden = true
        self.transactionsCollectionView.isHidden = true
        self.loadingView.isHidden = false
        self.layoutIfNeeded()
    }
}

extension CardFinanceableTransactionsView: CardFinanceableTransactionsCollectionDataSourceDelegate {
    func didSelectCardFinanceableTransaction(_ transaction: CardFinanceableTransactionViewModel) {
        self.delegate?.didSelectCardBankableTransaction(transaction)
    }
}

extension CardFinanceableTransactionsView: EmptyCardsFinanceableViewDelegate {
    func didSelectHireCard(_ location: PullOfferLocation?) {
        self.delegate?.didSelectHireCard(location)
    }
}

extension CardFinanceableTransactionsView: CardFinanceableTransactionsHeaderViewDelegate {
    func didSelectSeeAllFinanceableTransactions() {
        guard let selectedCard = self.selectedCard else { return }
        self.delegate?.didSelectSeeAllFinanceableTransactions(selectedCard)
    }
}

extension CardFinanceableTransactionsView: FinanceableProductSelectorDetailDelegate {
    func selectorDisplaysDetailView(_ isDisplayed: Bool) {
        self.delegate?.selectorDetailDisplayed(isDisplayed)
    }
}
