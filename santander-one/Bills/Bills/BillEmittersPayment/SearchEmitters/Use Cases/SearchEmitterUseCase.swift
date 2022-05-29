import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SearchEmitterUseCase: UseCase<SearchEmitterUseCaseInput, SearchEmitterUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: SearchEmitterUseCaseInput) throws -> UseCaseResponse<SearchEmitterUseCaseOkOutput, StringErrorOutput> {
        let params = EmittersConsultParamsDTO(
            account: requestValues.account.dto,
            emitterName: "",
            emitterCode: requestValues.emitterCode,
            pagination: EmittersPaginationAdapter(pagination: requestValues.pagination?.dto)
        )
        
        let response = try provider.getBsanBillTaxesManager().emittersConsult(params: params)
        guard response.isSuccess(), let emitterConsult = try response.getResponseData() else {
            return .error(StringErrorOutput( try response.getErrorMessage() ?? ""))
        }
        
        let emitterList = emitterConsult.emitterList.map({ EmitterEntity($0) })
        var pagination: PaginationEntity?
        if let paginationDTO = emitterConsult.pagination {
            pagination = PaginationEntity(paginationDTO)
        }
        return .ok(SearchEmitterUseCaseOkOutput(emitters: emitterList, pagination: pagination))
    }
}

struct SearchEmitterUseCaseInput {
    let account: AccountEntity
    let emitterCode: String
    let pagination: PaginationEntity?
}

struct SearchEmitterUseCaseOkOutput {
    let emitters: [EmitterEntity]
    let pagination: PaginationEntity?
}
