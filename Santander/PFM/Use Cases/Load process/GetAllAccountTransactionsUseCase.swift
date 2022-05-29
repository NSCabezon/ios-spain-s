import SANLegacyLibrary
import CoreFoundationLib
import CoreFoundationLib

class GetAllAccountTransactionsUseCase: UseCase<GetAllAccountTransactionsUseCaseInput, GetAllAccountTransactionsUseCaseOkOutput, GetAllAccountTransactionsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetAllAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetAllAccountTransactionsUseCaseOkOutput, GetAllAccountTransactionsUseCaseErrorOutput> {
        let accountManager = provider.getBsanAccountsManager()
        let response = try accountManager.getAccountTransactions(forAccount: requestValues.account.dto, pagination: requestValues.pagination?.dto, dateFilter: requestValues.dateFilter?.dto)
        if response.isSuccess(), let data = try response.getResponseData() {
            let transactions = AccountTransactionsList(data)
            return UseCaseResponse.ok(GetAllAccountTransactionsUseCaseOkOutput(accountTransactions: transactions))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetAllAccountTransactionsUseCaseErrorOutput(errorDescription))
        }
    }
}

extension GetAllAccountTransactionsUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}

struct GetAllAccountTransactionsUseCaseInput {
    let account: AccountEntity
    let dateFilter: DateFilterEntity?
    let pagination: PaginationEntity?
}

struct GetAllAccountTransactionsUseCaseOkOutput {
    let accountTransactions: AccountTransactionsList
}

class GetAllAccountTransactionsUseCaseErrorOutput: StringErrorOutput {
}

struct AccountTransactionsList {
    
    let transactions: [AccountTransactionEntity]?
    let pagination: PaginationEntity?
    
    init(_ dto: AccountTransactionsListDTO) {
        self.transactions = dto.transactionDTOs.map { AccountTransactionEntity($0) }
        self.pagination = PaginationEntity(dto.pagination)
    }
    
    init(transactions: [AccountTransactionEntity]?, pagination: PaginationEntity?) {
        self.transactions = transactions
        self.pagination = pagination
    }
}
