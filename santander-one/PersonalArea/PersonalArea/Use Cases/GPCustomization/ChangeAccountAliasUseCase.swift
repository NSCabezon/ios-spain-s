import SANLegacyLibrary
import CoreFoundationLib

class ChangeAccountAliasUseCase: UseCase<ChangeAccountAliasUseCaseInput, Void, StringErrorOutput> {
    
    override func executeUseCase(requestValues: ChangeAccountAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        
        let provider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let globalPositionRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let globalPositionV2Response = try provider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true,
                                                                                    isPB: globalPositionRepresentable.isPb ?? false)
        guard
            let accountsV2 = try globalPositionV2Response.getResponseData()?.accounts,
            let accountV2DTO: AccountDTO = accountsV2.first(where: { $0.iban == requestValues.account.dto.iban })
        else {
            return UseCaseResponse.error(StringErrorOutput(try globalPositionV2Response.getErrorMessage() ?? ""))
        }
        let response = try provider.getBsanAccountsManager().changeAccountAlias(accountDTO: accountV2DTO,
                                                                                newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

struct ChangeAccountAliasUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let account: AccountEntity
    let alias: String?
}
