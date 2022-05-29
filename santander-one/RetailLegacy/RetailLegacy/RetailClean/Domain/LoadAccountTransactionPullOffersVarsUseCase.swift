import CoreFoundationLib

class LoadAccountTransactionPullOffersVarsUseCase: UseCase<LoadAccountTransactionPullOffersVarsUseCaseInput, Void, StringErrorOutput> {
    private let pullOffersEngine: EngineInterface
    
    init(pullOffersEngine: EngineInterface) {
        self.pullOffersEngine = pullOffersEngine
        super.init()
    }
    
    override func executeUseCase(requestValues: LoadAccountTransactionPullOffersVarsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        var output = [String: Any]()
        
        //REGLAS POR MOVIMIENTO
        output["CMDA"] = requestValues.account.getAlias() ?? ""
        output["CMDS"] = requestValues.account.getAmount()?.value?.doubleValue ?? 0
        
        output["CMDD"] = requestValues.movement.description.uppercased()
        output["CMDI"] = requestValues.movement.amount.value?.doubleValue ?? 0

        pullOffersEngine.addRules(rules: output)
        return UseCaseResponse.ok()
    }
}

struct LoadAccountTransactionPullOffersVarsUseCaseInput {
    let account: Account
    let movement: AccountTransaction
}
