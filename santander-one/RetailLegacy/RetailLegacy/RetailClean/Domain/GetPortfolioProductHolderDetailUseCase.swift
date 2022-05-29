import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetPortfolioProductHolderDetailUseCase: UseCase<GetPortfolioProductHolderDetailUseCaseInput, GetPortfolioProductHolderDetailUseCaseOkOutput, GetPortfolioProductHolderDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPortfolioProductHolderDetailUseCaseInput) throws -> UseCaseResponse<GetPortfolioProductHolderDetailUseCaseOkOutput, GetPortfolioProductHolderDetailUseCaseErrorOutput> {
        
        let portfolioManager = provider.getBsanPortfoliosPBManager()
        let portfolioPBDTO = requestValues.portfolio.portfolioDTO
    
        let response = try portfolioManager.getHolderDetail(portfolioPBDTO: portfolioPBDTO)
        
        if response.isSuccess(), let detail = try response.getResponseData() {
            return UseCaseResponse.ok(GetPortfolioProductHolderDetailUseCaseOkOutput(transactionDetail: PortfolioHolderList(detail))) 
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetPortfolioProductHolderDetailUseCaseErrorOutput(errorDescription))
    }
}

struct GetPortfolioProductHolderDetailUseCaseInput {
    let portfolio: Portfolio
    
    init(portfolio: Portfolio) {
        self.portfolio = portfolio
    }
}

struct GetPortfolioProductHolderDetailUseCaseOkOutput {
    let transactionDetail: PortfolioHolderList
    
    init(transactionDetail: PortfolioHolderList) {
        self.transactionDetail = transactionDetail
    }
}

class GetPortfolioProductHolderDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
