//
//  ExpensesSelectorView.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 1/3/22.
//

import Foundation
import UI
import UIOneComponents
import CoreFoundationLib

protocol ExpensesSelectorDelegate: AnyObject {
    func didSelectExpense(_ expense: SendMoneyNoSepaExpensesProtocol, viewController: UIViewController?)
}

final class ExpensesSelectorView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: ExpensesSelectorDelegate?
    private var expenses: [SendMoneyNoSepaExpensesProtocol]?
    private var selectedIndex = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setAccessibilityIds()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    func setupViewModel(_ viewModel: AmountAndDateViewModel) {
        self.cleanViews()
        self.expenses = viewModel.expenses
        guard let expenses = self.expenses,
              let selectedExpense = viewModel.selectedExpense
        else { return }
        self.selectedIndex = expenses.firstIndex(where: { $0.equalsTo(other: selectedExpense) }) ?? 1
        let radioButtonViewModels: [OneRadioButtonViewModel] = expenses.map(self.mapToOneRadioButtonViewModel)
        radioButtonViewModels.enumerated().forEach { index, viewModel in
            let view = OneRadioButtonView()
            viewModel.accessibilitySuffix = "_\(index)"
            view.setViewModel(viewModel, index: index)
            view.setByStatus(view.index == self.selectedIndex ? .activated : .inactive)
            view.delegate = self
            self.stackView.addArrangedSubview(view)
            if index < expenses.count - 1 {
                self.addSeparatorView()
            }
        }
        self.updateRadioButtons()
    }
}

private extension ExpensesSelectorView {
    func setupViews() {
        self.titleLabel.textColor = .oneLisboaGray
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.titleLabel.configureText(withKey: "sendMoney_titlePopup_paymentCostSending")
    }
    
    func mapToOneRadioButtonViewModel(_ expense: SendMoneyNoSepaExpensesProtocol) -> OneRadioButtonViewModel {
        return OneRadioButtonViewModel(status: .inactive,
                                       titleKey: expense.titleKey,
                                       subtitleKey: expense.subtitleKey,
                                       isSelected: false)
    }
    
    func addSeparatorView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .oneMediumSkyGray
        self.stackView.addArrangedSubview(view)
    }
    
    func didSelectExpense(at index: Int) {
        self.selectedIndex = index
        self.updateRadioButtons()
        guard let expenses = self.expenses else { return }
        self.delegate?.didSelectExpense(expenses[self.selectedIndex], viewController: self.viewContainingController())
    }
    
    func updateRadioButtons() {
        self.stackView.subviews.forEach { current in
            if let radioButton = current as? OneRadioButtonView {
                radioButton.setByStatus(radioButton.index == self.selectedIndex ? .activated : .inactive)
            }
        }
    }
    
    func cleanViews() {
        self.stackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    func setAccessibilityIds() {
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneyAmountNoSepa.expenseSelectorTitle
    }
}

extension ExpensesSelectorView: OneRadioButtonViewDelegate {
    func didSelectOneRadioButton(_ index: Int) {
        self.didSelectExpense(at: index)
    }
}
