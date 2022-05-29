//
import CoreFoundationLib
import CoreDomain
import Foundation
import SANLegacyLibrary

class GetImpositionsTransactionUseCase: UseCase<GetImpositionsTransactionUseCaseInput, GetImpositionsTransactionUseCaseOkOutput, GetImpositionsTransactionUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetImpositionsTransactionUseCaseInput) throws -> UseCaseResponse<GetImpositionsTransactionUseCaseOkOutput, GetImpositionsTransactionUseCaseErrorOutput> {
        
        guard let imposition = requestValues.imposition else {
            return UseCaseResponse.error(GetImpositionsTransactionUseCaseErrorOutput(""))
        }
        
        let impositionManager = provider.getBsanDepositsManager()
        let dateRange: DateFilter?
        if requestValues.dateFilter == nil {
            dateRange = DateFilter.getDateFilterFor(numberOfYears: -1)
        } else {
            dateRange = requestValues.dateFilter?.dto
        }
        if dateRange?.fromDateModel != nil && dateRange?.toDateModel == nil {
            dateRange?.toDateModel = DateModel(date: Date())
        }
        let response = try impositionManager.getImpositionTransactions(impositionDTO: imposition, pagination: requestValues.pagination?.dto, dateFilter: dateRange)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription =  try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetImpositionsTransactionUseCaseErrorOutput(errorDescription))
        }
        
        let transactionList = ImpositionTransactionList(data)
        return UseCaseResponse.ok(GetImpositionsTransactionUseCaseOkOutput(impositionTransactionList: transactionList))
        
    }
}

struct GetImpositionsTransactionUseCaseInput {
    let imposition: ImpositionDTO?
    let dateFilter: DateFilterDO?
    let pagination: PaginationDO?
    
    init(imposition: Imposition, dateFilter: DateFilterDO?, pagination: PaginationDO?) {
        self.imposition = imposition.dto
        self.pagination = pagination
        self.dateFilter = dateFilter
    }
}

struct GetImpositionsTransactionUseCaseOkOutput {
    let impositionTransaction: ImpositionTransactionList
    
    init(impositionTransactionList: ImpositionTransactionList) {
        self.impositionTransaction = impositionTransactionList
    }
}

class GetImpositionsTransactionUseCaseErrorOutput: StringErrorOutput { }
