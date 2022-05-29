import SANLegacyLibrary
import CoreFoundationLib

class ChangeCardAliasUseCase: UseCase<ChangeCardAliasUseCaseInput, Void, StringErrorOutput> {
    override func executeUseCase(requestValues: ChangeCardAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias, !alias.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let provider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let dto = requestValues.card.dto
        let response = try provider.getBsanCardsManager().changeCardAlias(cardDTO: dto, newAlias: alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

struct ChangeCardAliasUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let card: CardEntity
    let alias: String?
}
