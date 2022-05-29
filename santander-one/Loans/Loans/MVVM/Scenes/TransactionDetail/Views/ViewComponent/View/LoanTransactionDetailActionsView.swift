//
//  LoanTransactionDetailActionsView.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 30/8/21.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

final class LoanTransactionDetailActionsView: UIView {
    private var actionButtons: [ActionButton] = []    
    let didSelectActionSubject = PassthroughSubject<LoanTransactionDetailActionType, Never>()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.heightAnchor.constraint(equalToConstant: 72).isActive = true
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
    
    func setActions(_ actions: [LoanTransactionDetailAction]) {
        actions.forEach { action in
            let detailAction = self.makeTransactionDetailActionForAction(action)
            self.actionButtons.append(detailAction)
        }
        addActionButtonsToStackView()
    }
    
    @available(*, deprecated, message: "")
    func setViewModels(_ actions: [LoanTransactionDetailActionViewModel]) {
        actions.forEach { action in
            let detailAction = self.makeTransactionDetailActionForAction(action)
            self.actionButtons.append(detailAction)
        }
        addActionButtonsToStackView()
    }
    
    @objc func performLoanTransactionDetailAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton,
              let viewModel = actionButton.getViewModel() as? LoanTransactionDetailAction else { return }
        didSelectActionSubject.send(viewModel.type)
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

private extension LoanTransactionDetailActionsView {
    func setup() {
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            self.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: 10)
        ])
    }
    
    func makeTransactionDetailActionForAction(_ viewModel: LoanTransactionDetailAction) -> ActionButton {
        let action = ActionButton()
        action.setExtraLabelContent(viewModel.highlightedInfo)
        action.setViewModel(viewModel)
        action.addSelectorAction(target: self, #selector(performLoanTransactionDetailAction))
        action.setIsDisabled(viewModel.isDisabled)
        return action
    }
    
    func makeTransactionDetailActionForAction(_ viewModel: LoanTransactionDetailActionViewModel) -> ActionButton {
        let action = ActionButton()
        action.setExtraLabelContent(viewModel.highlightedInfo)
        action.setViewModel(viewModel)
        action.addSelectorAction(target: self, #selector(performLoanTransactionDetailAction))
        action.setIsDisabled(viewModel.isDisabled)
        return action
    }
}
