import SANLegacyLibrary

public final class GetFractionablePurchaseDetailUseCase: UseCase<FractionablePurchaseDetailUseCaseInput, FractionablePurchaseDetailUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    public override func executeUseCase(requestValues: FractionablePurchaseDetailUseCaseInput) throws -> UseCaseResponse<FractionablePurchaseDetailUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanCardsManager()
        let input = FractionablePurchaseDetailParameters(pan: requestValues.pan,
                                                         movID: requestValues.movID)
        let response = try manager.getFractionablePurchaseDetail(input: input)
        guard response.isSuccess(),
              let dataResponse = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return .ok(FractionablePurchaseDetailUseCaseOkOutput(movementDetail: FinanceableMovementDetailEntity(dto: dataResponse)))
    }
}

public struct FractionablePurchaseDetailUseCaseOkOutput {
    public let movementDetail: FinanceableMovementDetailEntity
}

public struct FractionablePurchaseDetailUseCaseInput {
    var movID: String
    var pan: String

    public init(movID: String, pan: String) {
        self.movID = movID
        self.pan = pan
    }
}
