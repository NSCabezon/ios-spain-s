//
//  LoanViewModel.swift
//  Loans
//
//  Created by Jose Carlos Estela Anguita on 09/10/2019.
//

import CoreFoundationLib
import CoreDomain
import OpenCombine

class Loan {
    let loan: LoanRepresentable
    var detail: LoanDetail?
    let dependencies: LoanHomeDependenciesResolver
    
    init(loan: LoanRepresentable, detail: LoanDetailRepresentable, dependencies: LoanHomeDependenciesResolver) {
        self.loan = loan
        self.dependencies = dependencies
        self.detail = LoanDetail(detail: detail, currentBalance: loan.currentBalanceAmountRepresentable, dependencies: dependencies)
    }
    
    init(loan: LoanRepresentable, dependencies: LoanHomeDependenciesResolver) {
        self.loan = loan
        self.dependencies = dependencies
    }
    
    var alias: String {
        return loan.alias?.capitalized ?? ""
    }
    
    var productNumber: String {
        guard let contractDisplayNumber = self.loan.contractDisplayNumber else { return "" }
        return contractDisplayNumber
    }
    
    var amountBigAttributedString: NSAttributedString? {
        guard let balance = loan.currentBalanceAmountRepresentable.map(AmountEntity.init) else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(balance, font: font)
        return amount.getFormatedCurrency()
    }
    
    var amountSmall: NSAttributedString? {
        guard let balance = loan.currentBalanceAmountRepresentable.map(AmountEntity.init) else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 17)
        let amount = MoneyDecorator(balance, font: font)
        return amount.getCurrencyWithoutFormat()
    }
    
    var amount: String? {
        guard let balance = loan.currentBalanceAmountRepresentable.map(AmountEntity.init) else { return nil }
        return balance.getStringValue()
    }
}

extension Loan: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(loan.productIdentifier)
        hasher.combine(loan.alias)
        hasher.combine(loan.contractStatusDesc)
        hasher.combine(loan.contractDescription)
        hasher.combine(loan.typeOwnershipDesc)
    }
}

extension Loan: Equatable {
    static func == (lhs: Loan, rhs: Loan) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Loan: Shareable {
    func getShareableInfo() -> String {
        return loan.contractDescription ?? ""
    }
}
