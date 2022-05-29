import CoreFoundationLib
import CoreDomain
import Foundation
import SANLegacyLibrary

class GetPortfolioProductTransactionsUseCase: UseCase<GetPortfolioProductTransactionsUseCaseInput, GetPortfolioProductTransactionsUseCaseOkOutput, GetPortfolioProductTransactionsUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPortfolioProductTransactionsUseCaseInput) throws -> UseCaseResponse<GetPortfolioProductTransactionsUseCaseOkOutput, GetPortfolioProductTransactionsUseCaseErrorOutput> {
        guard let product = requestValues.product else {
            return UseCaseResponse.error(GetPortfolioProductTransactionsUseCaseErrorOutput(""))
        }
        let portfolioManager = provider.getBsanPortfoliosPBManager()
        let response = try portfolioManager.getPortfolioProductTransactions(portfolioProductPBDTO: product, pagination: requestValues.pagination?.dto, dateFilter: requestValues.filter)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetPortfolioProductTransactionsUseCaseErrorOutput(errorDescription))
        }
        let transactionList = PortfolioProductTransactionList(data)
        return UseCaseResponse.ok(GetPortfolioProductTransactionsUseCaseOkOutput(transactionList: transactionList))
    }
    
}

struct GetPortfolioProductTransactionsUseCaseInput {
    
    let product: PortfolioProductDTO?
    let filter: DateFilter
    let pagination: PaginationDO?
    
    init(portfolio: PortfolioProduct, pagination: PaginationDO?, filter: DateFilterDO? = nil) {
        self.product = portfolio.product
        self.pagination = pagination
        if let filter = filter {
            self.filter = filter.dto
        } else {
            self.filter = DateFilter.getDateFilterFor(numberOfYears: -1)
        }
    }
    
}

struct GetPortfolioProductTransactionsUseCaseOkOutput {
    
    let transactionList: PortfolioProductTransactionList
    
    init(transactionList: PortfolioProductTransactionList) {
        self.transactionList = transactionList
    }
    
}

class GetPortfolioProductTransactionsUseCaseErrorOutput: StringErrorOutput {
    
}
