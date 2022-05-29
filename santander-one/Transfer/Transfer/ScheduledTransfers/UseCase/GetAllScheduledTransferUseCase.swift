//
//  GetAllScheduledTransferUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 2/10/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetAllScheduledTransferUseCase: UseCase<GetAllScheduledTransferUseCaseInput, GetAllScheduledTransferUseCaseOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    var transfers: [ScheduledTransferEntity] = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAllScheduledTransferUseCaseInput) throws -> UseCaseResponse<GetAllScheduledTransferUseCaseOutput, StringErrorOutput> {
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanTransfersManager()
        let response = try manager.loadScheduledTransfers(
            account: requestValues.account.dto,
            amountFrom: nil,
            amountTo: nil,
            pagination: requestValues.pagination?.dto)
        
        guard response.isSuccess(),
            let data = try response.getResponseData() else {
            let output = GetAllScheduledTransferUseCaseOutput(transfers: transfers)
            return .ok(output)
        }
        
        let newTransfers = data.transactionDTOs.map { ScheduledTransferEntity(dto: $0) }
        self.transfers.append(contentsOf: newTransfers)
        
        if data.paginationDTO.endList {
            let output = GetAllScheduledTransferUseCaseOutput(transfers: transfers)
            return .ok(output)
        }
        
        let nextPageRequestInput = GetAllScheduledTransferUseCaseInput(
            account: requestValues.account,
            pagination: PaginationEntity(data.paginationDTO)
        )
        
        return try self.executeUseCase(requestValues: nextPageRequestInput)
    }
}

struct GetAllScheduledTransferUseCaseInput {
    let account: AccountEntity
    let pagination: PaginationEntity?
}

struct GetAllScheduledTransferUseCaseOutput {
    let transfers: [ScheduledTransferEntity]
}
