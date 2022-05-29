//
//  TransactionsGroupViewModel.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/5/20.
//

import Foundation
import CoreFoundationLib

protocol TransactionsGroupViewModel {
    var date: Date { get set }
    var transactions: [TransactionViewModel] { get set }
    var dateFormatted: LocalizedStylableText { get }
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText
}

protocol TransactionViewModel {
    var title: String? { get }
    var balanceString: String? { get }
    var amountAttributeString: NSAttributedString? { get }
    var amountValue: Decimal? { get }
    var description: String? { get }
    var isEasyPayEnabled: Bool { get }
}

enum CrossSellingViewModelState {
    case unknown
    case initial
    case withoutOffer
}

final class CrossSellingViewModel {
    // MARK: Private properties
    private let transaction: TransactionViewModel
    private let crossSellingEnabled: Bool
    private let isPiggyBankAccount: Bool
    private let accountsCrossSelling: [AccountMovementsCrossSellingProperties]
    private var crossSellingSelected: AccountMovementsCrossSellingProperties?
    private var availableAccountBalance: Decimal?
    
    // MARK: Public properties
    var actionNameCrossSelling = String()
    
    var state: CrossSellingViewModelState {
        if loading && offers == nil && !processed {
            return .initial
        } else if !loading && offers == nil && processed {
            return .withoutOffer
        }
        return .unknown
    }
    var loading: Bool = false
    var offers: [PullOfferLocation: OfferEntity]?
    var bannerHeight: CGFloat = 0
    var processed: Bool = false
    var isCrossSellingEnabled: Bool {
        guard crossSellingEnabled,
              !isPiggyBankAccount,
              let accountCrossSelling = self.getAccountCrossSelling() else { return false }
        self.actionNameCrossSelling = accountCrossSelling.actionNameCrossSelling
        self.crossSellingSelected = accountCrossSelling
        return true
    }
    
    var indexCrossSelling: Int {
        guard let accountCrossSelling = self.crossSellingSelected else { return -1 }
        return self.accountsCrossSelling.firstIndex(of: accountCrossSelling) ?? -1
    }
    
    var isEasyPayEnabled: Bool {
        return transaction.isEasyPayEnabled
    }
    
    init(transaction: TransactionViewModel,
         accountsCrossSelling: [AccountMovementsCrossSellingProperties],
         crossSellingEnabled: Bool,
         isPiggyBankAccount: Bool,
         availableAccountBalance: Decimal?) {
        self.transaction = transaction
        self.crossSellingEnabled = crossSellingEnabled
        self.isPiggyBankAccount = isPiggyBankAccount
        self.accountsCrossSelling = accountsCrossSelling
        self.availableAccountBalance = availableAccountBalance
    }
}

extension CrossSellingViewModel {
    var transactionViewModel: TransactionViewModel {
        return self.transaction
    }
}

private extension CrossSellingViewModel {
    func getAccountCrossSelling() -> AccountMovementsCrossSellingProperties? {
        let values = getCrossSellingWithAccountValues()
        return CrossSellingBuilder(
            itemsCrossSelling: accountsCrossSelling,
            transaction: transaction.title,
            amount: transaction.amountValue,
            crossSellingValues: values
        ).getCrossSelling()
    }
    
    func getCrossSellingWithAccountValues() -> CrossSellingValues {
        let availableAmount = availableAccountBalance ?? 0
        let accountValues = AccountValues(availableAmount)
        let values = CrossSellingValues(accountValues: accountValues)
        return values
    }
}
