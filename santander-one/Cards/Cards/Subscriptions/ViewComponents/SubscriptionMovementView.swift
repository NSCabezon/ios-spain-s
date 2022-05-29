//
//  SubscriptionMovementView.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 26/02/2021.
//

import UI
import CoreFoundationLib

protocol SubscriptionMovementViewDelegate: AnyObject {
    func didTapInDetail(_ viewModel: CardSubscriptionViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel)
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel)
}

final class SubscriptionMovementView: UIDesignableView {
    @IBOutlet private weak var subscriptionMovementStack: UIStackView!

    private var viewModel: CardSubscriptionViewModel?
    private var transactionViewModel: CardListFinanceableTransactionViewModel?
    weak var delegate: SubscriptionMovementViewDelegate?

    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupUI()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel,
                    type: CardSubscriptionSeeMoreType,
                    fromViewType: ShowCardSubscriprionFromView) {
        updateViewModels(viewModel, type: type)
        removeArrangedSubviewsIfNeeded()
        addPurchaseDetailView(viewModel)
        addSeeFractionableOptionsViewIfNeeded(viewModel)
        addCardDetailIfNeeded(viewModel, fromViewType: fromViewType)
        addBigSeparatorView()
        addSeeMoreView(type)
    }
}

private extension SubscriptionMovementView {
    func setupUI() {
        drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        drawShadow(offset: 1, opaticity: 0.8, color: .lightSanGray, radius: 3)
        backgroundColor = .white
    }
    
    func addPurchaseDetailView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionPurchaseView()
        view.delegate = self
        view.configView(viewModel)
        subscriptionMovementStack.addArrangedSubview(view)
    }
    
    func addCardDetailIfNeeded(_ viewModel: CardSubscriptionViewModel, fromViewType: ShowCardSubscriprionFromView) {
        switch fromViewType {
        case .general:
            addSmallSeparatorView()
            addCardDetailView(viewModel)
        case .card:
            break
        }
    }
    
    func addCardDetailView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionCardDetailView()
        view.delegate = self
        view.configView(viewModel)
        subscriptionMovementStack.addArrangedSubview(view)
    }
    
    func addSmallSeparatorView() {
        let view = CardSubscriptionDetailSeparatorDottedView()
        subscriptionMovementStack.addArrangedSubview(view)
    }
    
    func addBigSeparatorView() {
        let view = DottedLineView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        subscriptionMovementStack.addArrangedSubview(view)
    }
    
    func addSeeMoreView(_ type: CardSubscriptionSeeMoreType) {
        let view = CardSubscriptionSeeMoreView()
        view.delegate = self
        view.configView(type)
        subscriptionMovementStack.addArrangedSubview(view)
    }
    
    func addSeeFractionableOptionsViewIfNeeded(_ viewModel: CardSubscriptionViewModel) {
        if viewModel.isActive && viewModel.isFractionable {
            let view = CardSubscriptionSeeFractionateOptionsSelectorView()
            view.delegate = self
            let isExpandable = viewModel.transactionViewModel == nil
                ? viewModel.isSeeFractionableOptionsExpanded
                : viewModel.transactionViewModel?.isExpanded ?? false
            let feeViewModels = viewModel.transactionViewModel?.feeViewModels ?? []
            view.configView(isExpandable, feeViewModels: feeViewModels)
            subscriptionMovementStack.addArrangedSubview(view)
        }
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.subscriptionMovementStack.arrangedSubviews.isEmpty {
            self.subscriptionMovementStack.removeAllArrangedSubviews()
        }
    }
    
    func updateViewModels(_ viewModel: CardSubscriptionViewModel, type: CardSubscriptionSeeMoreType) {
        self.transactionViewModel = viewModel.transactionViewModel
        self.viewModel = viewModel
        self.viewModel?.cardSubscriptionType = type
    }
}

extension SubscriptionMovementView: CardSubscriptionPurchaseViewDelegate {
    func didTapInPurchaseView() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didTapInDetail(viewModel)
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool) {
        guard let viewModel = self.viewModel else {
            return
        }
        self.delegate?.didTapInSubscriptionSwitch(isOn, viewModel: viewModel)
    }
}

extension SubscriptionMovementView: DidTapInCardDetailViewDelegate {
    func didTapInCardDetailView() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didTapInDetail(viewModel)
    }
}

extension SubscriptionMovementView: DidTapInSeeMoreViewDelegate {
    func didTapInSeeMoreView() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didTapInDetail(viewModel)
    }
}

extension SubscriptionMovementView: CardSubscriptionSeeFractionateOptionsSelectorViewDelegate {
    func didTapInSelector() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
