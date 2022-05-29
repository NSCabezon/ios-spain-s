import SANLegacyLibrary

public class ChangeCardAliasNameUseCase: UseCase<ChangeCardAliasNameInputUseCase, Void, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    override public func executeUseCase(requestValues: ChangeCardAliasNameInputUseCase) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let carDTO = requestValues.card.dto
        let response = try provider.getBsanCardsManager().changeCardAlias(cardDTO: carDTO, newAlias: requestValues.alias)
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok()
    }
}

public struct ChangeCardAliasNameInputUseCase {
    public let card: CardEntity
    public let alias: String
    public init(card: CardEntity, alias: String) {
        self.card = card
        self.alias = alias
    }
}

extension ChangeCardAliasNameUseCase: ChangeCardAliasNameUseCaseProtocol { }

public protocol ChangeCardAliasNameUseCaseProtocol where Self: UseCase<ChangeCardAliasNameInputUseCase, Void, StringErrorOutput> {
    func executeUseCase(requestValues: ChangeCardAliasNameInputUseCase) throws -> UseCaseResponse<Void, StringErrorOutput>
}
