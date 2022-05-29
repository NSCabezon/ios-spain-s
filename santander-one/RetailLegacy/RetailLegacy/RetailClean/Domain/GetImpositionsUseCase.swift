import SANLegacyLibrary
import CoreFoundationLib

class GetImpositionsUseCase: UseCase<GetImpositionsUseCaseInput, GetImpositionsUseCaseOkOutput, GetImpositionsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetImpositionsUseCaseInput) throws -> UseCaseResponse<GetImpositionsUseCaseOkOutput, GetImpositionsUseCaseErrorOutput> {
        let depositsManager = provider.getBsanDepositsManager()
        let dto = requestValues.deposit.depositDTO
        
        let response = try depositsManager.getDepositImpositionsTransactions(depositDTO: dto, pagination: requestValues.pagination?.dto)

        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetImpositionsUseCaseOkOutput(impositionsList: ImpositionsList(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetImpositionsUseCaseErrorOutput(errorDescription))
    }
}

struct GetImpositionsUseCaseInput {
    let deposit: Deposit
    var pagination: PaginationDO?
}

struct GetImpositionsUseCaseOkOutput {
    let impositionsList: ImpositionsList
    
    init(impositionsList: ImpositionsList) {
        self.impositionsList = impositionsList
    }
}

class GetImpositionsUseCaseErrorOutput: StringErrorOutput {
    
}
