//
//  MockGetLoanTransactionDetailActionUseCase.swift
//  Loans-Unit-Tests
//
//  Created by alvola on 10/3/22.
//

import Foundation
import Loans
import CoreDomain
import OpenCombine

struct MockGetLoanTransactionDetailActionUseCase: GetLoanTransactionDetailActionUseCase {
    private var actions: [LoanTransactionDetailActionRepresentable] = []
    
    init(_ actions: [LoanTransactionDetailActionRepresentable]) {
        self.actions = actions
    }
    
    func fetchLoanTransactionDetailActions(transaction: LoanTransactionRepresentable) -> AnyPublisher<[LoanTransactionDetailActionRepresentable], Never> {
        Just(self.actions).eraseToAnyPublisher()
    }
}

struct MockLoanTransactionDetailAction: LoanTransactionDetailActionRepresentable {
    var type: LoanTransactionDetailActionType
    var isDisabled: Bool = false
    var isUserInteractionEnable: Bool = false
}
