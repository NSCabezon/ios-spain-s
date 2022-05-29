import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain
import Foundation

class GetPensionTransactionsUseCase: UseCase<GetPensionTransactionsUseCaseInput, GetPensionTransactionsUseCaseOkOutput, GetPensionTransactionsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPensionTransactionsUseCaseInput) throws -> UseCaseResponse<GetPensionTransactionsUseCaseOkOutput, GetPensionTransactionsUseCaseErrorOutput> {
        let pensionsManager = provider.getBsanPensionsManager()
        let dto = requestValues.pension.pensionDTO
        let dateRange: DateFilter?
        if requestValues.dateFilter == nil {
            dateRange = DateFilter.getDateFilterFor(numberOfYears: -1)
        } else {
            dateRange = requestValues.dateFilter?.dto
        }
        if dateRange?.fromDateModel != nil && dateRange?.toDateModel == nil {
            dateRange?.toDateModel = DateModel(date: Date())
        }
        let response = try pensionsManager.getPensionTransactions(forPension: dto, pagination: requestValues.pagination?.dto, dateFilter: dateRange)
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetPensionTransactionsUseCaseOkOutput(transactionList: PensionTransactionsList(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetPensionTransactionsUseCaseErrorOutput(errorDescription))
    }
}

struct GetPensionTransactionsUseCaseInput {
    let pension: Pension
    var dateFilter: DateFilterDO?
    var pagination: PaginationDO?
}

struct GetPensionTransactionsUseCaseOkOutput {
    let transactionList: PensionTransactionsList
    
    init(transactionList: PensionTransactionsList) {
        self.transactionList = transactionList
    }
}

class GetPensionTransactionsUseCaseErrorOutput: StringErrorOutput {

}
