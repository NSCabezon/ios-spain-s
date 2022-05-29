//

import SANLegacyLibrary
import CoreFoundationLib

class GetCounterValueDetailUseCase: UseCase<GetCounterValueDetailUseCaseInput, GetCounterValueDetailUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetCounterValueDetailUseCaseInput) throws -> UseCaseResponse<GetCounterValueDetailUseCaseOkOutput, StringErrorOutput> {
        let mifidManager = provider.getBsanMifidManager()
        let response = try mifidManager.getCounterValueDetail(stockAccountDTO: requestValues.stockAccount.stockAccountDTO, stockQuoteDTO: requestValues.stock.quoteDto)
        if response.isSuccess(), let responseData = try response.getResponseData() {
            return UseCaseResponse.ok(GetCounterValueDetailUseCaseOkOutput(rmvDetail: RMVDetail.create(responseData)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct GetCounterValueDetailUseCaseInput {
    let stockAccount: StockAccount
    let stock: Stock
}

struct GetCounterValueDetailUseCaseOkOutput {
    let rmvDetail: RMVDetail
}
