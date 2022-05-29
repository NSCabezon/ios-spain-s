import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetCreditCardsUseCase: UseCase<Void, GetCreditCardsUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCreditCardsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cards = globalPosition.cards.visibles().filter({ $0.isCreditCard && $0.isCardContractHolder && !$0.isInactive && !$0.isTemporallyOff })
        guard cards.count > 0 else {
            return .error(StringErrorOutput("deeplink_alert_errorPdfExtract"))
        }
        return .ok(GetCreditCardsUseCaseOkOutput(cards: cards))
    }
}

struct GetCreditCardsUseCaseOkOutput {
    let cards: [CardEntity]
}
