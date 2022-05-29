//
//  GetEmittedTransferGroupUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/20/19.
//

import SANLegacyLibrary
import CoreFoundationLib

final class GetEmittedTransferUseCaseGroup<Delegate: SuperUseCaseDelegate>: SuperUseCase<Delegate> {
    private var requestValue: GetEmittedTransferUseCaseGroupInput?
    private var requestGroup: TransferEmittedRequestGroup?
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver, useCaseHandler: UseCaseHandler) {
        self.dependenciesResolver = dependenciesResolver
        super.init(useCaseHandler: useCaseHandler)
    }
    
    override func setupUseCases() {
        self.requestValue?.accounts.forEach { (account) in
            self.callEmittedTransferUseCase(for: account, andPagination: nil)
        }
    }
    
    private func callEmittedTransferUseCase(for account: AccountEntity, andPagination pagination: PaginationEntity?) {
        let useCase = self.dependenciesResolver.resolve(for: GetEmittedTransfersUseCase.self)
        let requestInputs = self.makeEmittedTransferRequestInput(for: account, pagination: pagination)
        self.requestGroup?.setRequested(for: account)
        
        self.add(useCase.setRequestValues(requestValues: requestInputs), isMandatory: false) { response in
            if response.isSuccess() {
                self.requestNextPageOfTransaction(for: response)
            } else {
                self.requestGroup?.addResponse(response)
                self.requestGroup?.leave()
            }
        }
    }
    
    private func requestNextPageOfTransaction(for response: GetEmittedTransfersUseCaseOutput) {
        self.requestGroup?.addResponse(response)
        if requestGroup?.isEnd() == true {
            self.requestGroup?.leave()
        } else {
            self.callEmittedTransferUseCase(for: response.account, andPagination: requestGroup?.nextPage())
        }
    }
    
    private func makeEmittedTransferRequestInput(for account: AccountEntity,
                                                 pagination: PaginationEntity?) -> GetEmittedTransfersUseCaseInput {
        return GetEmittedTransfersUseCaseInput(
            account: account,
            pagination: pagination,
            fromAmount: nil,
            toAmmout: nil,
            dateFilter: self.requestGroup?.dateFilter ?? DateFilterEntity.createSubtractingMonths(months: 1)
        )
    }
    
    func execute(requestValue: GetEmittedTransferUseCaseGroupInput, onSuccess: @escaping([AccountEntity: [TransferEmittedEntity]]) -> Void) {
        self.requestValue = requestValue
        self.requestGroup = TransferEmittedRequestGroup(dependenciesResolver: dependenciesResolver, accounts: requestValue.accounts)
        self.requestGroup?.notify = { result in
            onSuccess(result)
        }
        super.execute()
    }
}
