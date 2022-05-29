//
//  NextSettlementActionView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 15/10/2020.
//

import UI

final class NextSettlementActionView: UIDesignableView {
    
    @IBOutlet private weak var actionButtonStackView: UIStackView!

    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
    }
    
    func setActions(_ viewModels: [NextSettlementActionViewModel]) {
        self.actionButtonStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        viewModels.forEach { (viewModel) in
            actionButtonStackView.addArrangedSubview(self.makeActionForViewModel(viewModel))
        }
    }
}

private extension NextSettlementActionView {
    func makeActionForViewModel(_ viewModel: NextSettlementActionViewModel) -> ActionButton {
        let actionButton = ActionButton()
        actionButton.setExtraLabelContent(viewModel.highlightedInfo)
        actionButton.setViewModel(viewModel)
        actionButton.setAppearance(withStyle: viewModel.isRemarkable ? .remarkableStyle : .defaultStyleWithGrayBackground)
        actionButton.setIsDisabled(viewModel.isDisabled)
        actionButton.addSelectorAction(target: self, #selector(performAction))
        actionButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
        return actionButton
    }
    
    @objc func performAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let actionViewModel = actionButton.getViewModel() as? NextSettlementActionViewModel else { return }
        actionViewModel.action?(actionViewModel.type, actionViewModel.entity)
    }
}
