import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetEmittedTransfersUseCase: UseCase<GetEmittedTransfersUseCaseInput, GetEmittedTransfersUseCaseOkOutput, GetEmittedTransfersUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider

    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetEmittedTransfersUseCaseInput) throws -> UseCaseResponse<GetEmittedTransfersUseCaseOkOutput, GetEmittedTransfersUseCaseErrorOutput> {
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.loadEmittedTransfers(account: requestValues.account.accountDTO, amountFrom: requestValues.amountFrom?.amountDTO, amountTo: requestValues.amountTo?.amountDTO, dateFilter: requestValues.dateFilter.dto, pagination: requestValues.pagination?.dto)
        if response.isSuccess() && !canceled {
            let data = try response.getResponseData()
            let list = data?.transactionDTOs ?? []
            let result = list.map { TransferEmitted.create($0) }
            let nextPage = PaginationDO(dto: data?.paginationDTO)
            return UseCaseResponse.ok(GetEmittedTransfersUseCaseOkOutput(transferList: result, nextPage: nextPage))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""

            return UseCaseResponse.error(GetEmittedTransfersUseCaseErrorOutput(errorDescription))
        }
    }
}

extension GetEmittedTransfersUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}

struct GetEmittedTransfersUseCaseInput {
    let account: Account
    let pagination: PaginationDO?
    let amountFrom: Amount?
    let amountTo: Amount?
    let dateFilter: DateFilterDO
}

struct GetEmittedTransfersUseCaseOkOutput {
    let transferList: [TransferEmitted]
    let nextPage: PaginationDO?
}

class GetEmittedTransfersUseCaseErrorOutput: StringErrorOutput {
    
}
