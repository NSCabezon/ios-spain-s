//
//  CardSubscriptionDetailHistoricStackPillView.swift
//  Cards
//
//  Created by Ignacio González Miró on 6/5/21.
//

import UIKit
import UI

protocol CardSubscriptionDetailHistoricStackPillViewDelegate: AnyObject {
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel)
}

final class CardSubscriptionDetailHistoricStackPillView: XibView {
    @IBOutlet private weak var historicStackView: UIStackView!
    
    weak var delegate: CardSubscriptionDetailHistoricStackPillViewDelegate?
    private var viewModel: CardSubscriptionDetailHistoricViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        self.viewModel = viewModel
        removeArrangedSubviewsIfNeeded()
        addHistoricPill(viewModel)
        if viewModel.isFractionable {
            addSeeFractionableOptionsView(viewModel)
        }
    }
}

private extension CardSubscriptionDetailHistoricStackPillView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func addHistoricPill(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        let view = CardSubscriptionDetailHistoricPillView()
        view.configView(viewModel)
        view.heightAnchor.constraint(equalToConstant: 76).isActive = true
        self.historicStackView.addArrangedSubview(view)
    }
    
    func addSeeFractionableOptionsView(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        let view = CardSubscriptionSeeFractionateOptionsSelectorView()
        view.delegate = self
        let isExpanded = viewModel.transactionViewModel?.isExpanded ?? viewModel.isSeeFractionableOptionsExpanded
        let feeViewModels = viewModel.transactionViewModel?.feeViewModels ?? []
        view.configView(isExpanded, feeViewModels: feeViewModels)
        self.historicStackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.historicStackView.arrangedSubviews.isEmpty {
            self.historicStackView.removeAllArrangedSubviews()
        }
    }
}

extension CardSubscriptionDetailHistoricStackPillView: CardSubscriptionSeeFractionateOptionsSelectorViewDelegate {
    func didTapInSelector() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
