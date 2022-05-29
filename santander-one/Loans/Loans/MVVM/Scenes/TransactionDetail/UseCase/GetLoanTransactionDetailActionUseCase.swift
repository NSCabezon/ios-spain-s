//
//  GetLoanTransactionDetailActionUseCase.swift
//  Loans
//
//  Created by alvola on 28/2/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetLoanTransactionDetailActionUseCase {
    func fetchLoanTransactionDetailActions(transaction: LoanTransactionRepresentable) -> AnyPublisher<[LoanTransactionDetailActionRepresentable], Never>
}
