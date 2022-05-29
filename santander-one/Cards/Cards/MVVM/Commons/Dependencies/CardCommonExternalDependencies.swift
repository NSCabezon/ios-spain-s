import UI

public protocol CardCommonExternalDependenciesResolver {
    // Card actions
    func cardActivateCoordinator() -> BindableCoordinator
    func cardCVVCoordinator() -> BindableCoordinator
    func cardOnCoordinator() -> BindableCoordinator
    func cardInstantCashCoordinator() -> BindableCoordinator
    func cardDelayPaymentCoordinator() -> BindableCoordinator
    func cardPayOffCoordinator() -> BindableCoordinator
    func cardChargeDischargeCoordinator() -> BindableCoordinator
    func cardPinCoordinator() -> BindableCoordinator
    func cardBlockCoordinator() -> BindableCoordinator
    func cardWithdrawMoneyWithCodeCoordinator() -> BindableCoordinator
    func cardMobileTopUpCoordinator() -> BindableCoordinator
    func cardCesCoordinator() -> BindableCoordinator
    func cardPdfExtractCoordinator() -> BindableCoordinator
    func cardHistoricPdfExtractCoordinator() -> BindableCoordinator
    func cardPdfDetailCoordinator() -> BindableCoordinator
    func cardFractionablePurchasesCoordinator() -> BindableCoordinator
    func cardModifyLimitsCoordinator() -> BindableCoordinator
    func cardSolidarityRoundingCoordinator() -> BindableCoordinator
    func cardChangePaymentMethodCoordinator() -> BindableCoordinator
    func cardHireCoordinator() -> BindableCoordinator
    func cardDivideCoordinator() -> BindableCoordinator
    func cardShareCoordinator() -> BindableCoordinator
    func cardFraudCoordinator() -> BindableCoordinator
    func cardChargePrepaidCoordinator() -> BindableCoordinator
    func cardApplePayCoordinator() -> BindableCoordinator
    func cardDuplicatedCoordinator() -> BindableCoordinator
    func cardSuscriptionCoordinator() -> BindableCoordinator
    func cardConfigureCoordinator() -> BindableCoordinator
    func cardSubscriptionsCoordinator() -> BindableCoordinator
    func cardFinancingBillsCoordinator() -> BindableCoordinator
    func cardCustomeCoordinator() -> BindableCoordinator
    func cardOffCoordinator() -> BindableCoordinator
    func offersCoordinator() -> BindableCoordinator
    func showPANCoordinator() -> BindableCoordinator
    func easyPayCoordinator() -> BindableCoordinator
}
