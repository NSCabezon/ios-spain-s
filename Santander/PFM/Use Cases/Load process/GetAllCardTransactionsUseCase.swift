import SANLegacyLibrary
import CoreFoundationLib
import Darwin

final class GetAllCardTransactionsUseCase: UseCase<GetAllCardTransactionsUseCaseInput, GetAllCardTransactionsUseCaseOkOutput, GetAllCardTransactionsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetAllCardTransactionsUseCaseInput) throws -> UseCaseResponse<GetAllCardTransactionsUseCaseOkOutput, GetAllCardTransactionsUseCaseErrorOutput> {
        let cardManager = provider.getBsanCardsManager()
        let response = try cardManager.getCardTransactions(cardDTO: requestValues.card.dto, pagination: requestValues.pagination?.dto, dateFilter: requestValues.dateFilter?.dto)
        if response.isSuccess(), let data = try response.getResponseData() {
            let transactions = data.transactionDTOs.map { (transactionDTO) -> CardTransactionEntity in
                let transaction = CardTransactionEntity(transactionDTO)
                return transaction
            }
            let pagination = PaginationEntity(data.pagination)
            return UseCaseResponse.ok(GetAllCardTransactionsUseCaseOkOutput(transaction: transactions, pagination: pagination))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetAllCardTransactionsUseCaseErrorOutput(errorDescription))
        }
        
    }
}

extension GetAllCardTransactionsUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}

struct GetAllCardTransactionsUseCaseInput {
    let card: CardEntity
    let dateFilter: DateFilterEntity?
    let pagination: PaginationEntity?
}

struct GetAllCardTransactionsUseCaseOkOutput {
    let transaction: [CardTransactionEntity]
    let pagination: PaginationEntity?
}

class GetAllCardTransactionsUseCaseErrorOutput: StringErrorOutput {
    
}
