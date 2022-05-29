import SANLegacyLibrary

public class MockCardDataProvider {
    public var getCardSettlementDetail: CardSettlementDetailDTO!
    public var getCardSettlementMovements: [CardSettlementMovementDTO]!
    public var getChangePayment: ChangePaymentDTO!
    public var getCardDetail: CardDetailDTO!
    public var getCardData: CardDataDTO!
    public var getCardTransactionsList: CardTransactionsListDTO!
    public var getCardSubscriptionsHistoricalList: CardSubscriptionsHistoricalListDTO!
    public var getFinanceableMovementDetail: FinanceableMovementDetailDTO!
    public var getEasyPayAmortization: EasyPayAmortizationDTO!
    public var getCardSubscriptionsList: CardSubscriptionsListDTO!
    public var getCardSubscriptionsGraphData: CardSubscriptionsGraphDataDTO!
    public var getCardMovementLocationListDTO: CardMovementLocationListDTO!
    public var getCardTransactionFeesEasyPay: FeeDataDTO!
    public var getTransactionsEasyPayContract: EasyPayContractTransactionListDTO!
    public var getTransactionDetailEasyPay: EasyPayDTO!
    public var getTransactionDetail: CardTransactionDetailDTO!
    public var getFeesInfo: FeesInfoDTO!
}
