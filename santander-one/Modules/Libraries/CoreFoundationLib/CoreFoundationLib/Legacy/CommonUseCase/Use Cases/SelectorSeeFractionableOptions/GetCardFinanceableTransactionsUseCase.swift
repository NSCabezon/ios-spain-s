import Foundation
import SANLegacyLibrary

public protocol GetCardFinanceableTransactionsUseCase: UseCase<GetCardFinanceableTransactionsUseCaseInput, GetCardFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {}

public final class DafaultGetCardFinanceableTransactionsUseCase: UseCase<GetCardFinanceableTransactionsUseCaseInput, GetCardFinanceableTransactionsUseCaseOkOutput, StringErrorOutput>,
                                                                 GetCardFinanceableTransactionsUseCase{
    
    override public func executeUseCase(requestValues: GetCardFinanceableTransactionsUseCaseInput) throws -> UseCaseResponse<GetCardFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {

        let card = requestValues.card
        guard card.isCreditCard, card.isCardContractHolder else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(GetCardFinanceableTransactionsUseCaseOkOutput(
            card: card,
            transations: []
        ))
    }

}

public struct GetCardFinanceableTransactionsUseCaseInput {
    public let card: CardEntity
    
    public init(card: CardEntity) {
        self.card = card
    }
}

public struct GetCardFinanceableTransactionsUseCaseOkOutput {
    public let card: CardEntity
    public let transations: [CardTransactionEntity]
    
    public init(card: CardEntity, transations: [CardTransactionEntity]) {
        self.card = card
        self.transations = transations
    }
}
