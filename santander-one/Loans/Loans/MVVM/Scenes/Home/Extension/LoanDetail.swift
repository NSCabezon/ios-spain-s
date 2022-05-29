//
//  LoanDetailViewModel.swift
//  Loans
//
//  Created by Jose Carlos Estela Anguita on 09/10/2019.
//

import CoreFoundationLib
import CoreDomain

struct LoanDetail {
    let detail: LoanDetailRepresentable
    let timeManager: TimeManager
    let currentBalance: AmountRepresentable?
    
    init(detail: LoanDetailRepresentable, currentBalance: AmountRepresentable?, dependencies: LoanHomeDependenciesResolver) {
        self.detail = detail
        self.currentBalance = currentBalance
        self.timeManager = dependencies.external.resolve()
    }
    
    var openingDate: String? {
        return timeManager.toString(date: detail.openingDate, outputFormat: .d_MMM_yyyy)
    }
    
    var expirationDate: String? {
        return timeManager.toString(date: detail.currentDueDate, outputFormat: .d_MMM_yyyy)
    }
    
    var progrees: CGFloat {
        guard
            let initialAmount = detail.initialAmountRepresentable?.value,
            let currentBalance = currentBalance?.value,
            abs(initialAmount) > 0
        else {
            return 0
        }
        let paid = abs(currentBalance)
        let total = abs(initialAmount)
        let value = (total - paid) * 100 / total
        let progressPercent = CGFloat(truncating: value as NSNumber)
        return progressPercent > 100 ? 100 : progressPercent
    }
    
    var revocable: Bool? {
        return detail.revocable
    }
    
    var amortizable: Bool? {
        return detail.amortizable
    }
}
