import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol GetCreditCardUseCase: UseCase<Void, GetCreditCardUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetCreditCardUseCase: UseCase<Void, GetCreditCardUseCaseOkOutput, StringErrorOutput>,
                                  GetCreditCardUseCase {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCreditCardUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cardList = globalPosition.cards
            .visibles()
            .filter({ $0.isCreditCard })
    
        return .ok(GetCreditCardUseCaseOkOutput(cardList: cardList))
    }
}

public struct GetCreditCardUseCaseOkOutput {
    let cardList: [CardEntity]
    
    public init(cardList: [CardEntity]) {
        self.cardList = cardList
    }
}
