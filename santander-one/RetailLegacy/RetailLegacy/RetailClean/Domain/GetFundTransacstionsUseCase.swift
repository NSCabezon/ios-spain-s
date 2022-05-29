import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain
import Foundation

class GetFundTransactionsUseCase: UseCase<GetFundTransactionsUseCaseInput, GetFundTransactionsUseCaseOkOutput, GetFundTransactionsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetFundTransactionsUseCaseInput) throws -> UseCaseResponse<GetFundTransactionsUseCaseOkOutput, GetFundTransactionsUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let dto = requestValues.fund.fundDTO
        let dateRange: DateFilter?
        if requestValues.dateFilter == nil {
            dateRange = DateFilter.getDateFilterFor(numberOfYears: -1)
        } else {
            dateRange = requestValues.dateFilter?.dto
        }
        if dateRange?.fromDateModel != nil && dateRange?.toDateModel == nil {
            dateRange?.toDateModel = DateModel(date: Date())
        }
        let response = try fundsManager.getFundTransactions(forFund: dto, dateFilter: dateRange, pagination: requestValues.pagination?.dto)
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetFundTransactionsUseCaseOkOutput(transactionList: FundTransactionsList(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetFundTransactionsUseCaseErrorOutput(errorDescription))
    }
}

struct GetFundTransactionsUseCaseInput {
    let fund: Fund
    var dateFilter: DateFilterDO?
    var pagination: PaginationDO?
    
    init(fund: Fund, dateFilter: DateFilterDO? = nil, pagination: PaginationDO?) {
        self.fund = fund
        self.dateFilter = dateFilter
        self.pagination = pagination
    }
}

struct GetFundTransactionsUseCaseOkOutput {
    let transactionList: FundTransactionsList
    
    init(transactionList: FundTransactionsList) {
        self.transactionList = transactionList
    }
}

class GetFundTransactionsUseCaseErrorOutput: StringErrorOutput {

}
