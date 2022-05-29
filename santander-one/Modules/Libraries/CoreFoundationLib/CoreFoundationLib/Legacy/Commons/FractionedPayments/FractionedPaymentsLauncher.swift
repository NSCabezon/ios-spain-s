public protocol FractionedPaymentsLauncher {
    func didSelectInMenu()
    func gotoCardEasyPayOperative(card: CardEntity,
                                  transaction: CardTransactionEntity,
                                  easyPayOperativeData: EasyPayOperativeDataEntity?)
    func goToFractionedPaymentDetail(_ transaction: CardTransactionEntity,
                                     card: CardEntity)
}
