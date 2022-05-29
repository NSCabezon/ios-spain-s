//
//  AccountTransactionDetailActions.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/5/19.
//
import UIKit
import UI
import CoreFoundationLib

final class AccountTransactionDetailActions: UIView {
    private var actionButtons: [ActionButton] = []
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fill
        
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
        self.backgroundColor = UIColor.skyGray
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 16),
            self.stackView.heightAnchor.constraint(equalToConstant: 72),
            self.stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: 10),
            self.stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func setViewModels(_ viewModels: [AccountTransactionDetailActionViewModel]) {
        let count = CGFloat(viewModels.count)
        var buttonWidth = (UIScreen.main.bounds.width - 20 - (count - 1) * 9) / count
        buttonWidth = count == 1 ? 168 : buttonWidth
        viewModels.forEach { (viewModel) in
            let cardAction = self.makeAccountTransactionActionForViewModel(viewModel)
            cardAction.translatesAutoresizingMaskIntoConstraints = false
            cardAction.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
            self.actionButtons.append(cardAction)
        }
        addActionButtonsToStackView()
    }
    
    private func makeAccountTransactionActionForViewModel(_ viewModel: AccountTransactionDetailActionViewModel) -> ActionButton {
        let actionButton = ActionButton()
        actionButton.setExtraLabelContent(viewModel.highlightedInfo)
        actionButton.setViewModel(viewModel)
        actionButton.addSelectorAction(target: self, #selector(performAccountTransactionAction))
        actionButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
        return actionButton
    }
    
    @objc func performAccountTransactionAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let viewModel = actionButton.getViewModel() as? AccountTransactionDetailActionViewModel else { return }
        viewModel.action()
    }
    
    public func addActionButtonsToStackView() {
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
