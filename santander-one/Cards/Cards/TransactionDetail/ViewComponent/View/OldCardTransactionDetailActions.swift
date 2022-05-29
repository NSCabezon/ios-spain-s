//
//  TransactionDetailActions.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 12/4/19.
//

import UIKit
import UI
import CoreFoundationLib

class OldCardTransactionDetailActions: UIView {
    private var actionButtons: [ActionButton] = []
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            self.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: 10)
        ])
    }
    
    func setViewModels(_ viewModels: [CardActionViewModel]) {
        viewModels.forEach { (viewModel) in
            let cardAction = self.makeCardTransactionDetailActionForViewModel(viewModel)
            self.actionButtons.append(cardAction)
        }
        addActionButtonsToStackView()
    }
    
    private func makeCardTransactionDetailActionForViewModel(_ viewModel: CardActionViewModel) -> ActionButton {
        let action = ActionButton()
        action.setExtraLabelContent(viewModel.highlightedInfo)
        action.setViewModel(viewModel)
        action.addSelectorAction(target: self, #selector(performCardTransactionDetailAction))
        action.setIsDisabled(viewModel.isDisabled)
        action.accessibilityIdentifier = viewModel.accessibilityIdentifier
        return action
    }
    
    @objc func performCardTransactionDetailAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let viewModel = actionButton.getViewModel() as? CardActionViewModel else { return }
        viewModel.action?(viewModel.type, viewModel.entity)
    }
    
    func addActionButtonsToStackView() {
        self.actionButtons.forEach {
            self.stackView.addArrangedSubview($0)
        }
    }
    
    public func removeSubviews() {
        self.actionButtons.removeAll()
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
