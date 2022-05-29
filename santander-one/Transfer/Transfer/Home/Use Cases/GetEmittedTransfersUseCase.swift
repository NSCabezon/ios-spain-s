//
//  GetEmittedTransfersUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/20/19.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetEmittedTransfersUseCase: UseCase<GetEmittedTransfersUseCaseInput, GetEmittedTransfersUseCaseOutput, StringErrorOutput> {
    private var provider: BSANTransfersManager {
        return managersProvider.getBsanTransfersManager()
    }
    private let managersProvider: BSANManagersProvider
    private let globalPositionRepresentable: GlobalPositionRepresentable
    
    init(dependenciesResolver: DependenciesResolver) {
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.globalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }
    
    override func executeUseCase(requestValues: GetEmittedTransfersUseCaseInput) throws -> UseCaseResponse<GetEmittedTransfersUseCaseOutput, StringErrorOutput> {
        let completed = try provider.getHistoricalTransferCompleted()
        var response: BSANResponse<TransferEmittedListDTO>
        do {
            response = try completed ? getResponse(for: requestValues) : loadResponse(for: requestValues)
            return try handleResponse(response: response, requestValues: requestValues)
        } catch _ as ParserException {
            response = try loadResponse(for: requestValues)
            return try handleResponse(response: response, requestValues: requestValues)
        }
    }
    
    private func loadResponse(for input: GetEmittedTransfersUseCaseInput) throws -> BSANResponse<TransferEmittedListDTO> {
        return try provider.loadEmittedTransfers(
            account: input.account.dto,
            amountFrom: input.fromAmount?.dto,
            amountTo: input.toAmmout?.dto,
            dateFilter: input.dateFilter.dto,
            pagination: input.pagination?.dto
        )
    }
    
    private func getResponse(for input: GetEmittedTransfersUseCaseInput) throws -> BSANResponse<TransferEmittedListDTO> {
        let transfers = try provider.getEmittedTransfers().getResponseData()
        let response = try managersProvider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true,
                                                                                    isPB: globalPositionRepresentable.isPb ?? false)
        guard let accountsV2 = try response.getResponseData()?.accounts else { return BSANErrorResponse(SANLegacyLibrary.Meta.createKO()) }
        let requestAccount: AccountDTO = accountsV2.first(where: { $0.iban == input.account.dto.iban }) ?? input.account.dto
        guard let contratoPK = requestAccount.contract?.contratoPK, !contratoPK.isEmpty  else { return BSANErrorResponse(SANLegacyLibrary.Meta.createKO()) }
        return SANLegacyLibrary.BSANOkResponse(transfers?[contratoPK])
    }
    
    private func responseWithError(for input: GetEmittedTransfersUseCaseInput) -> GetEmittedTransfersUseCaseOutput {
        return GetEmittedTransfersUseCaseOutput(
            account: input.account,
            transfers: [],
            nextPage: nil,
            error: StringErrorOutput(nil))
    }
    
    private func handleResponse(response: BSANResponse<TransferEmittedListDTO>, requestValues: GetEmittedTransfersUseCaseInput) throws ->  UseCaseResponse<GetEmittedTransfersUseCaseOutput, StringErrorOutput> {
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .ok(responseWithError(for: requestValues))
        }
        
        let entityList = TransactionEmittedListEntity(data)
        return .ok(
            GetEmittedTransfersUseCaseOutput(
                account: requestValues.account,
                transfers: entityList.transfers,
                nextPage: entityList.pagination,
                error: nil
        ))
    }
    
    private func createReturnEntity(with data: TransferEmittedListDTO, requestValues: GetEmittedTransfersUseCaseInput) -> GetEmittedTransfersUseCaseOutput {
        let entityList = TransactionEmittedListEntity(data)
        return
            GetEmittedTransfersUseCaseOutput(
                account: requestValues.account,
                transfers: entityList.transfers,
                nextPage: entityList.pagination,
                error: nil
        )
    }
}

struct GetEmittedTransfersUseCaseInput {
    let account: AccountEntity
    let pagination: PaginationEntity?
    let fromAmount: AmountEntity?
    let toAmmout: AmountEntity?
    let dateFilter: DateFilterEntity
}

struct GetEmittedTransfersUseCaseOutput {
    let account: AccountEntity
    let transfers: [TransferEmittedEntity]
    let nextPage: PaginationEntity?
    let error: StringErrorOutput?
    func isSuccess() -> Bool {
        return error == nil
    }
}
