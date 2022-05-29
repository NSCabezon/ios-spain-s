
public final class GetVisibleCardsUseCase: UseCase<Void, GetVisibleCardsUseCaseOkOutPut, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private var merger: GlobalPositionPrefsMergerEntity

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        self.merger = GlobalPositionPrefsMergerEntity(resolver: dependenciesResolver,
                                                      globalPosition: globalPosition,
                                                      saveUserPreferences: false)
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetVisibleCardsUseCaseOkOutPut, StringErrorOutput> {
        let cards = merger.cards.visibles()
            .filter({ $0.isDebitCard || $0.isCreditCard })
        return .ok(GetVisibleCardsUseCaseOkOutPut(cards: cards))
    }
}

public struct GetVisibleCardsUseCaseOkOutPut {
    public let cards: [CardEntity]
}
