import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetEmitterIncomesUseCase: UseCase<GetEmitterIncomesUseCaseInput, GetEmitterIncomesUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private var incomesList: [IncomeEntity] = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetEmitterIncomesUseCaseInput) throws -> UseCaseResponse<GetEmitterIncomesUseCaseOkOutput, StringErrorOutput> {
        let emitter = requestValues.emitter
        let account = requestValues.account
        let response = try provider.getBsanBillTaxesManager()
            .loadBillCollectionList(
                emitterCode: emitter.code,
                account: account.dto,
                pagination: requestValues.pagination?.dto
        )
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            if incomesList.isEmpty {
                return .error(StringErrorOutput( try response.getErrorMessage()))
            } else {
                return .ok(GetEmitterIncomesUseCaseOkOutput(incomes: incomesList))
            }
        }
        
        let incomes = data.billCollections.map({ IncomeEntity($0) })
        self.incomesList.append(contentsOf: incomes)
        
        guard let pagination = data.pagination else {
            return .ok(GetEmitterIncomesUseCaseOkOutput(incomes: incomesList))
        }
        
        guard pagination.endList else {
            let nextPage = GetEmitterIncomesUseCaseInput(emitter: emitter, account: account, pagination: PaginationEntity(pagination))
            return try self.executeUseCase(requestValues: nextPage)
        }
        
        return .ok(GetEmitterIncomesUseCaseOkOutput(incomes: incomesList))
    }
}

struct GetEmitterIncomesUseCaseInput {
    let emitter: EmitterEntity
    let account: AccountEntity
    let pagination: PaginationEntity?
}

struct GetEmitterIncomesUseCaseOkOutput {
    let incomes: [IncomeEntity]
}
