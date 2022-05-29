import SANLegacyLibrary
import CoreFoundationLib

class GetFundTransactionDetailUseCase: UseCase<GetFundTransactionDetailUseCaseInput, GetFundTransactionDetailUseCaseOkOutput, GetFundTransactionDetailUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetFundTransactionDetailUseCaseInput) throws -> UseCaseResponse<GetFundTransactionDetailUseCaseOkOutput, GetFundTransactionDetailUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        let transactionDTO = requestValues.fundTransaction.fundTransactionDTO
        
        let response = try fundsManager.getFundTransactionDetail(forFund: fundDTO, fundTransactionDTO: transactionDTO)
        
        if response.isSuccess(), let detail = try response.getResponseData() {
            return UseCaseResponse.ok(GetFundTransactionDetailUseCaseOkOutput(fundTransactionDetail: FundTransactionDetail(detail)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetFundTransactionDetailUseCaseErrorOutput(errorDescription))
    }
}

struct GetFundTransactionDetailUseCaseInput {
    let fund: Fund
    let fundTransaction: FundTransaction
    
    init(fund: Fund, fundTransaction: FundTransaction) {
        self.fund = fund
        self.fundTransaction = fundTransaction
    }
}

struct GetFundTransactionDetailUseCaseOkOutput {
    let fundTransactionDetail: FundTransactionDetail
    
    init(fundTransactionDetail: FundTransactionDetail) {
        self.fundTransactionDetail = fundTransactionDetail
    }
}

class GetFundTransactionDetailUseCaseErrorOutput: StringErrorOutput {
    
}
