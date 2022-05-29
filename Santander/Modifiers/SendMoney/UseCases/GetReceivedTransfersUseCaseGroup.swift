//
//  GetReceivedTransfersUseCaseGroup.swift
//  Transfer
//
//  Created by alvola on 18/05/2020.
//

import SANLegacyLibrary
import CoreFoundationLib

final class GetReceivedTransfersUseCaseGroup<Delegate: SuperUseCaseDelegate>: SuperUseCase<Delegate> {
    private var requestValue: GetEmittedTransferUseCaseGroupInput?
    private var requestGroup: TransferReceivedRequestGroup?
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver, useCaseHandler: UseCaseHandler) {
        self.dependenciesResolver = dependenciesResolver
        super.init(useCaseHandler: useCaseHandler)
    }
    
    override func setupUseCases() {
        self.requestValue?.accounts.forEach { (account) in
            self.callReceivedTransferUseCase(for: account, andPagination: nil)
        }
    }
    
    private func callReceivedTransferUseCase(for account: AccountEntity, andPagination pagination: PaginationEntity?) {
        let useCase = self.dependenciesResolver.resolve(for: GetReceivedTransfersUseCase.self)
        let requestInputs = self.makeReceivedTransferRequestInput(for: account, pagination: pagination)
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
    
    private func requestNextPageOfTransaction(for response: GetReceivedTransfersUseCaseOutput) {
        self.requestGroup?.addResponse(response)
        
        if response.nextPage?.isEnd == true {
            self.requestGroup?.leave()
        } else {
            self.callReceivedTransferUseCase(for: response.account, andPagination: response.nextPage)
        }
    }
    
    private func makeReceivedTransferRequestInput(for account: AccountEntity,
                                                  pagination: PaginationEntity?) -> GetReceivedTransfersUseCaseInput {
        let dateFilter = self.requestGroup?.dateFilter ?? DateFilterEntity.createSubtractingMonths(months: 1)
        return GetReceivedTransfersUseCaseInput(account: account,
                                                pagination: pagination,
                                                fromAmount: nil,
                                                toAmmout: nil,
                                                dateFilter: dateFilter )
    }
    
    func execute(requestValue: GetEmittedTransferUseCaseGroupInput, onSuccess: @escaping([AccountEntity: [TransferReceivedEntity]]) -> Void) {
        self.requestValue = requestValue
        self.requestGroup = TransferReceivedRequestGroup(dependenciesResolver: dependenciesResolver,
                                                         accounts: requestValue.accounts)
        self.requestGroup?.notify = { result in
            onSuccess(result)
        }
        super.execute()
    }
}
