import SANLegacyLibrary
import CoreFoundationLib

final class PreSetupPayOffCardUseCase: UseCase<PreSetupPayOffCardUseCaseInput, PreSetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
    private let resolver: DependenciesResolver
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }
    
    override func executeUseCase(requestValues: PreSetupPayOffCardUseCaseInput) throws -> UseCaseResponse<PreSetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
        guard requestValues.card == nil else { return .ok(PreSetupPayOffCardUseCaseOkOutput(cards: [])) }
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = resolver.resolve()
        let visibleCards = globalPosition.cards.visibles()
        let filteredCards = visibleCards.filter({ allowsPayOff(card: $0) })
        guard !filteredCards.isEmpty else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(PreSetupPayOffCardUseCaseOkOutput(cards: filteredCards.map { CardFactory.getCard($0) }))
    }
    
    private func allowsPayOff(card: CardEntity) -> Bool {
        guard let currentBalance = card.currentBalance.value else { return false }
        return card.isContractActive && card.isCardContractHolder && abs(currentBalance) > 0
    }
}

struct PreSetupPayOffCardUseCaseInput {
    let card: Card?
}

struct PreSetupPayOffCardUseCaseOkOutput {
    let cards: [Card]
}
