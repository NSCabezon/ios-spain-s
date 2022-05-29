import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetPortfolioProductListUseCase: UseCase<GetPortfolioProductListUseCaseInput, GetPortfolioProductListUseCaseOkOutput, GetPortfolioProductListUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPortfolioProductListUseCaseInput) throws -> UseCaseResponse<GetPortfolioProductListUseCaseOkOutput, GetPortfolioProductListUseCaseErrorOutput> {
        let portfolioManager = provider.getBsanPortfoliosPBManager()
        var transactions = [PortfolioProductDTO]()
        let response = try portfolioManager.getPortfolioProducts(portfolioPBDTO: requestValues.portfolio)
        if response.isSuccess(), let data = try response.getResponseData() {
            transactions = data
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetPortfolioProductListUseCaseErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(GetPortfolioProductListUseCaseOkOutput(transactions: transactions))
    }
    
}

struct GetPortfolioProductListUseCaseInput {
    
    let portfolio: PortfolioDTO
    
    init(portfolio: Portfolio) {
        self.portfolio = portfolio.portfolioDTO
    }
    
}

struct GetPortfolioProductListUseCaseOkOutput {
    
    let transactions: [PortfolioProductDTO]
    
    init(transactions: [PortfolioProductDTO]) {
        self.transactions = transactions
    }
    
}

class GetPortfolioProductListUseCaseErrorOutput: StringErrorOutput {
    
}
