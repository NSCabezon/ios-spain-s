import CoreFoundationLib

class LoadCardTransactionPullOffersVarsUseCase: UseCase<LoadCardTransactionPullOffersVarsUseCaseInput, Void, StringErrorOutput> {
    private let pullOffersEngine: EngineInterface
    
    init(pullOffersEngine: EngineInterface) {
        self.pullOffersEngine = pullOffersEngine
        super.init()
    }
    
    override func executeUseCase(requestValues: LoadCardTransactionPullOffersVarsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        var output = [String: Any]()

        output["TMDA"] = "\"\(requestValues.card.getAlias())\""
        
        if requestValues.card is CreditCard {
            output["TMDT"] = "\"credito\""
        } else if requestValues.card is DebitCard {
            output["TMDT"] = "\"debito\""
        } else if requestValues.card is PrepaidCard {
            output["TMDT"] = "\"prepago\""
        }

        output["TMDD"] = "\"\(requestValues.cardTransaction.description ?? "")\""
        output["TMDI"] = "\"\(requestValues.cardTransaction.amount.value?.doubleValue ?? 0)\""
        
        pullOffersEngine.addRules(rules: output)
        return UseCaseResponse.ok()
    }
}

struct LoadCardTransactionPullOffersVarsUseCaseInput {
    let card: Card
    let cardTransaction: CardTransactionProtocol
}
