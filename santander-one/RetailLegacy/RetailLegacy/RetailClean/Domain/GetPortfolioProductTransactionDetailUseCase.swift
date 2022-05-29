import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetPortfolioProductTransactionDetailUseCase: UseCase<GetPortfolioProductTransactionDetailUseCaseInput, GetPortfolioProductTransactionDetailUseCaseOkOutput, GetPortfolioProductTransactionDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPortfolioProductTransactionDetailUseCaseInput) throws -> UseCaseResponse<GetPortfolioProductTransactionDetailUseCaseOkOutput, GetPortfolioProductTransactionDetailUseCaseErrorOutput> {
        
        let portfolioManager = provider.getBsanPortfoliosPBManager()
        let portfolioTransactionDTO = requestValues.portfolioProductTransaction.dto
        
        let response = try portfolioManager.getPortfolioProductTransactionDetail(transactionDTO: portfolioTransactionDTO)
        
        if response.isSuccess(), let detail = try response.getResponseData() {
            return UseCaseResponse.ok(GetPortfolioProductTransactionDetailUseCaseOkOutput(portfolioProductTransactionDetail: PortfolioProductTransactionDetail(dto: detail)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetPortfolioProductTransactionDetailUseCaseErrorOutput(errorDescription))
    }
}

struct GetPortfolioProductTransactionDetailUseCaseInput {
    let portfolioProductTransaction: PortfolioProductTransaction
    
    init(portfolioProductTransaction: PortfolioProductTransaction) {
        self.portfolioProductTransaction = portfolioProductTransaction
    } 
}

struct GetPortfolioProductTransactionDetailUseCaseOkOutput {
    let portfolioProductTransactionDetail: PortfolioProductTransactionDetail
    
    init(portfolioProductTransactionDetail: PortfolioProductTransactionDetail) {
        self.portfolioProductTransactionDetail = portfolioProductTransactionDetail
    }
}

class GetPortfolioProductTransactionDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
