//
//  LoanTransactionDetailActionBuilder.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 30/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class LoanTransactionDetailActionBuilder {
    private var actions: [LoanTransactionDetailActionViewModel] = []
    private var entity: LoanEntity
    
    init(entity: LoanEntity) {
        self.entity = entity
    }
    
    func addPDFExtract(viewModel: OldLoanTransactionDetailViewModel, _ action: @escaping (LoanTransactionDetailActionType, LoanEntity) -> Void) {
        let pdfExtract = LoanTransactionDetailActionViewModel(
            entity: entity,
            type: .pdfExtract(nil),
            action: action,
            isDisabled: false
        )
        actions.append(pdfExtract)
    }
    
    func addShare(viewModel: OldLoanTransactionDetailViewModel, _ action: @escaping (LoanTransactionDetailActionType, LoanEntity) -> Void) {
        let share = LoanTransactionDetailActionViewModel(
            entity: entity,
            type: .share,
            action: action,
            isDisabled: false
        )
        actions.append(share)
    }
    
    func build() -> [LoanTransactionDetailActionViewModel] {
        return actions
    }
}
