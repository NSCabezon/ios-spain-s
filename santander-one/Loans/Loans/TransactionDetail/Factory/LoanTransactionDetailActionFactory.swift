//
//  LoanTransactionDetailActionFactory.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 30/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class LoanTransactionDetailActionFactory {
    
    static func getLoanTransactionDetailActionForViewModel(viewModel: OldLoanTransactionDetailViewModel, entity: LoanEntity,
                                                           dependenciesResolver: DependenciesResolver,
                                                           action: @escaping (LoanTransactionDetailActionType, LoanEntity) -> Void) -> [LoanTransactionDetailActionViewModel] {
        let builder = LoanTransactionDetailActionBuilder(entity: entity)
        builder.addPDFExtract(viewModel: viewModel, action)
        builder.addShare(viewModel: viewModel, action)
        return builder.build()
    }
}
