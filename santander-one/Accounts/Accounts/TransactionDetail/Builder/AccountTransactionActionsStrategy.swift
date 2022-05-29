//
//  AccountTransactionActionsStrategy.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 13/03/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol AccountTransactionActionsStrategyDelegate: AnyObject {
    func goToTransactionAction(type: AccountTransactionDetailAction)
}

protocol AccountTransactionActionsStrategy: AnyObject {
    var viewModel: AccountTransactionDetailViewModel { get }
    var builder: AccountTransactionDetailOptionsBuilder { get }
    func setupActions()
    func loadActions() -> [AccountTransactionDetailActionViewModel]
    var delegate: AccountTransactionActionsStrategyDelegate? { get set }
    init(transaction: AccountTransactionEntity,
         viewModel: AccountTransactionDetailViewModel,
         builder: AccountTransactionDetailOptionsBuilder,
         trackerManager: TrackerManager,
         delegate: AccountTransactionActionsStrategyDelegate)
}

extension AccountTransactionActionsStrategy where Self: AutomaticScreenActionTrackable, Self.Page == AccountTransactionDetail {
    
    func addTransfer() {
        self.builder.addTransfer {
            self.trackEvent(.sendMoney, parameters: [:])
            self.delegate?.goToTransactionAction(type: .transfers)
        }
    }
    
    func addReturnBill() {
        self.builder.addReturnBill {
            self.trackEvent(.returnBill, parameters: [:])
            self.delegate?.goToTransactionAction(type: .billsAndTaxes)
        }
    }
    
    func addPdf() {
        self.builder.addPdf {
            self.trackEvent(.pdf, parameters: [:])
            self.delegate?.goToTransactionAction(type: .pdf)
        }
    }
    
    func addBills() {
        self.builder.addBill {
            self.trackEvent(.bills, parameters: [:])
            self.delegate?.goToTransactionAction(type: .billsAndTaxes)
        }
    }
    
    func addShare() {
        self.builder.addShare {
            self.trackEvent(.share, parameters: [:])
            self.delegate?.goToTransactionAction(type: .share(self.viewModel))
        }
    }
    
    func addSplitExpenses(with viewType: ActionButtonFillViewType) {
        self.builder.addSplitExpenses(customType: viewType, action: { [weak self] in
            self?.trackEvent(.splitExpenses, parameters: [:])
            guard let viewModel = self?.viewModel else { return }
            self?.delegate?.goToTransactionAction(type: .splitExpense(viewModel))
        })
    }
    
    func addPayBill(viewType: ActionButtonFillViewType) {
        self.builder.addPayBill(customType: viewType, action: { [weak self] in
            self?.trackEvent(.bills, parameters: [:])
            self?.delegate?.goToTransactionAction(type: .payBill)
        })
    }
    
    func setupBillAction() {
        let customeActionModifier = self.viewModel.customeActionModifier
        if let customeActionModifier = customeActionModifier {
            self.addPayBill(viewType: customeActionModifier.customViewTypePayBill())
        } else {
            self.addBills()
        }
    }
    
    func loadActions() -> [AccountTransactionDetailActionViewModel] {
        self.setupActions()
        return self.builder.build()
    }
}

class TransferAccountTransactionActionsStrategy: AccountTransactionActionsStrategy, AutomaticScreenActionTrackable {
    
    let builder: AccountTransactionDetailOptionsBuilder
    let trackerManager: TrackerManager
    weak var delegate: AccountTransactionActionsStrategyDelegate?
    var trackerPage: AccountTransactionDetail {
        return AccountTransactionDetail()
    }
    let transaction: AccountTransactionEntity
    let viewModel: AccountTransactionDetailViewModel
    
    required init(
        transaction: AccountTransactionEntity,
        viewModel: AccountTransactionDetailViewModel,
        builder: AccountTransactionDetailOptionsBuilder,
        trackerManager: TrackerManager,
        delegate: AccountTransactionActionsStrategyDelegate
    ) {
        self.builder = builder
        self.trackerManager = trackerManager
        self.delegate = delegate
        self.transaction = transaction
        self.viewModel = viewModel
    }
    
    func setupActions() {
        guard !viewModel.isPiggyBankAccount else {
            return
        }
        let isPdfEnabled = self.transaction.isPdfEnabled
        let isSplitExpensesEnabled = self.viewModel.isSplitExpensesOperativeEnabled
        let modifier = self.viewModel.accountTransactionDetailModifier
        if isPdfEnabled {
            self.addPdf()
        } else if isSplitExpensesEnabled, let modifier = modifier {
            self.addSplitExpenses(with: modifier.customViewType())
        }
        self.addTransfer()
        if isPdfEnabled && isSplitExpensesEnabled, let modifier = modifier {
            self.addSplitExpenses(with: modifier.customViewType())
        } else {
            self.setupBillAction()
        }
        self.addShare()
    }
}

class BillAccountTransactionActionsStrategy: AccountTransactionActionsStrategy, AutomaticScreenActionTrackable {
    
    let builder: AccountTransactionDetailOptionsBuilder
    let trackerManager: TrackerManager
    weak var delegate: AccountTransactionActionsStrategyDelegate?
    var trackerPage: AccountTransactionDetail {
        return AccountTransactionDetail()
    }
    let transaction: AccountTransactionEntity
    let viewModel: AccountTransactionDetailViewModel
    
    required init(
        transaction: AccountTransactionEntity,
        viewModel: AccountTransactionDetailViewModel,
        builder: AccountTransactionDetailOptionsBuilder,
        trackerManager: TrackerManager,
        delegate: AccountTransactionActionsStrategyDelegate
    ) {
        self.builder = builder
        self.trackerManager = trackerManager
        self.delegate = delegate
        self.transaction = transaction
        self.viewModel = viewModel
    }
    
    func setupActions() {
        guard !viewModel.isPiggyBankAccount else {
            return
        }
        let isPdfEnabled = self.transaction.isPdfEnabled
        let isSplitExpensesEnabled = self.viewModel.isSplitExpensesOperativeEnabled
        let modifier = self.viewModel.accountTransactionDetailModifier
        if isPdfEnabled {
            self.addPdf()
        } else if isSplitExpensesEnabled, let modifier = modifier {
            self.addSplitExpenses(with: modifier.customViewType())
        }
        self.addReturnBill()
        if isPdfEnabled && isSplitExpensesEnabled, let modifier = modifier {
            self.addSplitExpenses(with: modifier.customViewType())
        } else {
            self.setupBillAction()
        }
        self.addShare()
    }
}

class AnyAccountTransactionActionsStrategy: AccountTransactionActionsStrategy, AutomaticScreenActionTrackable {
    
    let builder: AccountTransactionDetailOptionsBuilder
    let trackerManager: TrackerManager
    weak var delegate: AccountTransactionActionsStrategyDelegate?
    var trackerPage: AccountTransactionDetail {
        return AccountTransactionDetail()
    }
    let transaction: AccountTransactionEntity
    let viewModel: AccountTransactionDetailViewModel
    
    required init(
        transaction: AccountTransactionEntity,
        viewModel: AccountTransactionDetailViewModel,
        builder: AccountTransactionDetailOptionsBuilder,
        trackerManager: TrackerManager,
        delegate: AccountTransactionActionsStrategyDelegate
    ) {
        self.builder = builder
        self.trackerManager = trackerManager
        self.delegate = delegate
        self.transaction = transaction
        self.viewModel = viewModel
    }
    
    func setupActions() {
        guard !viewModel.isPiggyBankAccount else {
            return
        }
        let modifier = self.viewModel.accountTransactionDetailModifier
        if self.viewModel.isSplitExpensesOperativeEnabled, let modifier = modifier {
            self.addSplitExpenses(with: modifier.customViewType())
        }
        self.addTransfer()
        self.setupBillAction()
        self.addShare()
    }
}

final class CustomAccountTransactionActionsStrategy: AccountTransactionActionsStrategy, AutomaticScreenActionTrackable {
    let builder: AccountTransactionDetailOptionsBuilder
    let trackerManager: TrackerManager
    weak var delegate: AccountTransactionActionsStrategyDelegate?
    var trackerPage: AccountTransactionDetail {
        return AccountTransactionDetail()
    }
    let transaction: AccountTransactionEntity
    let viewModel: AccountTransactionDetailViewModel
    
    required init(
        transaction: AccountTransactionEntity,
        viewModel: AccountTransactionDetailViewModel,
        builder: AccountTransactionDetailOptionsBuilder,
        trackerManager: TrackerManager,
        delegate: AccountTransactionActionsStrategyDelegate
    ) {
        self.builder = builder
        self.trackerManager = trackerManager
        self.delegate = delegate
        self.transaction = transaction
        self.viewModel = viewModel
    }

    func setupActions() {
        guard !viewModel.isPiggyBankAccount else {
            return
        }
        if let customActions = self.viewModel.customActions {
            customActions.forEach { action in
                self.addActionButton(for: action)
            }
        }
    }
}

private extension CustomAccountTransactionActionsStrategy {
    private func addActionButton(for action: AccountTransactionDetailAction) {
        let modifier = self.viewModel.accountTransactionDetailModifier
        switch action {
        case .pdf:
            self.addPdf()
        case .transfers:
            self.addTransfer()
        case .billsAndTaxes:
            self.addBills()
        case .returnBill:
            self.addReturnBill()
        case .share:
            self.addShare()
        case .splitExpense:
            if self.viewModel.isSplitExpensesOperativeEnabled, let modifier = modifier {
                self.addSplitExpenses(with: modifier.customViewType())
            }
        case .payBill:
            self.setupBillAction()
        }
    }
}
