//
//  GetReceivedTransfersUseCase.swift
//  Transfer
//
//  Created by alvola on 18/05/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class GetReceivedTransfersUseCase: UseCase<GetReceivedTransfersUseCaseInput, GetReceivedTransfersUseCaseOutput, StringErrorOutput> {
    private var provider: BSANTransfersManager
    
    init(dependenciesResolver: DependenciesResolver) {
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.provider = bsanManagersProvider.getBsanTransfersManager()
    }
    
    override func executeUseCase(requestValues: GetReceivedTransfersUseCaseInput) throws -> UseCaseResponse<GetReceivedTransfersUseCaseOutput, StringErrorOutput> {
        let response = try getResponse(for: requestValues)
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .ok(responseWithError(for: requestValues))
        }
        
        let entityList = TransactionReceivedListEntity(data, accountDTO: requestValues.account.dto)
        return .ok( GetReceivedTransfersUseCaseOutput(account: requestValues.account,
                                                      transfers: entityList.transfers,
                                                      nextPage: entityList.pagination,
                                                      error: nil ))
    }
    
    private func getResponse(for input: GetReceivedTransfersUseCaseInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        return try provider.getAccountTransactions(
            forAccount: input.account.dto,
            pagination: input.pagination?.dto,
            filter: AccountTransferFilterInput(
                endAmount: input.toAmmout?.dto,
                startAmount: input.fromAmount?.dto,
                transferType: TransferType.transfersReceived,
                movementType: MovementType.all,
                dateFilter: input.dateFilter.dto
            )
        )
    }
    
    private func responseWithError(for input: GetReceivedTransfersUseCaseInput) -> GetReceivedTransfersUseCaseOutput {
        return GetReceivedTransfersUseCaseOutput(account: input.account,
                                                 transfers: [],
                                                 nextPage: nil,
                                                 error: StringErrorOutput(nil))
    }
}

struct GetReceivedTransfersUseCaseInput {
    let account: AccountEntity
    let pagination: PaginationEntity?
    let fromAmount: AmountEntity?
    let toAmmout: AmountEntity?
    let dateFilter: DateFilterEntity
}

struct GetReceivedTransfersUseCaseOutput {
    let account: AccountEntity
    let transfers: [TransferReceivedEntity]
    let nextPage: PaginationEntity?
    let error: StringErrorOutput?
    
    func isSuccess() -> Bool {
        return error == nil
    }
}
