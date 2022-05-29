//
//  LoanTransactionDetailUseCase.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 31/8/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol LoanTransactionDetailUseCaseProtocol: UseCase<LoanTransactionDetailUseCaseInput, LoanTransactionDetailUseCaseOkOutput, StringErrorOutput> {}

final class LoanTransactionDetailUseCase: UseCase<LoanTransactionDetailUseCaseInput, LoanTransactionDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let localAppConfig: LocalAppConfig

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    override func executeUseCase(requestValues: LoanTransactionDetailUseCaseInput) throws -> UseCaseResponse<LoanTransactionDetailUseCaseOkOutput, StringErrorOutput> {
        let loansManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanLoansManager()
        guard let loanDTO = requestValues.loan.representable as? LoanDTO else {
            return .error(StringErrorOutput("transaction_label_emptyError"))
        }
        let response = try loansManager.getLoanTransactionDetail(forLoan: loanDTO, loanTransaction: requestValues.transaction.dto)
        guard response.isSuccess(), let loanTransactionDetailDTO = try response.getResponseData() else {
            return .error(StringErrorOutput("transaction_label_emptyError"))
        }
        return .ok(LoanTransactionDetailUseCaseOkOutput(detail: LoanTransactionDetailEntity(loanTransactionDetailDTO)))
    }
}

extension LoanTransactionDetailUseCase: LoanTransactionDetailUseCaseProtocol {}

public struct LoanTransactionDetailUseCaseInput {
    public let transaction: LoanTransactionEntity
    public let loan: LoanEntity
    
    public init(loan: LoanEntity, transaction: LoanTransactionEntity) {
        self.loan = loan
        self.transaction = transaction
    }
}

public struct LoanTransactionDetailUseCaseOkOutput {
    let detail: LoanTransactionDetailEntity
    
    public init(detail: LoanTransactionDetailEntity) {
        self.detail = detail
    }
}
