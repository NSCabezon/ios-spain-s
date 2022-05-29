//
//  CardListFinanceableTransactionViewModel.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import Foundation

public typealias EasyPayAction = (CardEntity, CardTransactionEntity, EasyPayOperativeDataEntity?) -> Void

public final class CardListFinanceableTransactionViewModel {
    public let card: CardEntity
    public var financeableTransaction: FinanceableTransaction
    public var easyPayAction: EasyPayAction?
    public var isExpanded = false
    public var easyPayFail = false
    public var isEasyPayEnable = true
    
    public init(card: CardEntity, financeableTransaction: FinanceableTransaction) {
        self.card = card
        self.financeableTransaction = financeableTransaction
    }
    
    public var operativeDate: Date {
        return financeableTransaction.transaction.operationDate ?? Date()
    }
    
    public var title: String? {
        return financeableTransaction.transaction.description?.capitalized
    }
    
    public var amount: AmountEntity? {
        let transaction = financeableTransaction.transaction
        guard let amount = transaction.amount else {
            return nil
        }
        return amount
    }
    
    public func toggle() {
        self.isExpanded = !self.isExpanded
    }
    
    public func isEasyPayLoaded() -> Bool {
        return financeableTransaction.easyPayOperativeData != nil &&
               financeableTransaction.fractionatedPayment != nil
    }
    
    public func setEasyPayError() {
        self.easyPayFail = true
    }
    
    public func updateWith(_ viewModel: CardListFinanceableTransactionViewModel) {
        self.financeableTransaction = viewModel.financeableTransaction
        self.isExpanded = !viewModel.easyPayFail
    }
    
    public var feeViewModels: [FeeViewModel] {
        let montlyFeeItems = self.financeableTransaction.fractionatedPayment?.montlyFeeItems
        let maxMonths = self.financeableTransaction.fractionatedPayment?.maxMonths ?? 36
        return montlyFeeItems?.map({
            let viewModel = FeeViewModel(feeEntity: $0,
                                         maxMonths: maxMonths,
                                         allInOneCard: self.card.isAllInOne)
            viewModel.action = self.doEasyPayAction
            return viewModel
        }) ?? []
    }
    
    public func doEasyPayAction(_ easyPayAmortization: EasyPayAmortizationEntity?) {
        let easyPayOperativeData = self.financeableTransaction.easyPayOperativeData
        easyPayOperativeData?.easyPayAmortization = easyPayAmortization
        self.easyPayAction?(card, financeableTransaction.transaction, easyPayOperativeData)
    }
}

extension CardListFinanceableTransactionViewModel: Equatable {
    public static func == (lhs: CardListFinanceableTransactionViewModel, rhs: CardListFinanceableTransactionViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CardListFinanceableTransactionViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.financeableTransaction.transaction.hashValue)
    }
}
