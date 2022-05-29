import CoreTestData

public final class CardsServiceInjector: CustomServiceInjector {

    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.gpData.getCardsInfoMock,
            filename: "posGlobalCardsList"
        )
        injector.register(
            for: \.cardsData.getChangePayment,
            filename: "getChangePayment"
        )
        injector.register(
            for: \.cardsData.getCardDetail,
            filename: "getCardDetail"
        )
        injector.register(
            for: \.cardsData.getCardData,
            filename: "posGlobalCardsList"
        )
        injector.register(
            for: \.cardsData.getCardSettlementMovements,
            filename: "getSettlementMovements"
        )
        injector.register(
            for: \.cardsData.getCardMovementLocationListDTO,
            filename: "getCardMovementLocationListMock"
        )
        injector.register(
            for: \.cardsData.getCardTransactionsList,
            filename: "getCardTransactions"
        )
    }
}
