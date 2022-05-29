import SANLegacyLibrary

struct ChangePaymentMethodConfirmation {
    private(set) var dto: ChangePaymentMethodConfirmationInput
    
    private init?(changePayment: ChangePayment, selectedPaymentMethod: PaymentMethodDTO, amount: AmountDTO) {
        guard let referenceStandard = changePayment.referenceStandard,
            let hiddenReferenceStandard = changePayment.hiddenReferenceStandard else {
                return nil
        }
        dto = ChangePaymentMethodConfirmationInput(
            referenceStandard: referenceStandard,
            hiddenReferenceStandard: hiddenReferenceStandard,
            selectedAmount: amount,
            currentPaymentMethod: changePayment.currentPaymentMethod,
            currentPaymentMethodMode: changePayment.currentPaymentMethodMode ?? "",
            currentSettlementType: changePayment.currentSettlementType ?? "",
            marketCode: changePayment.marketCode ?? "",
            hiddenMarketCode: changePayment.hiddenMarketCode ?? "",
            hiddenPaymentMethodMode: changePayment.hiddenPaymentMethodMode ?? "",
            selectedPaymentMethod: selectedPaymentMethod)
    }
    
    static func create(changePayment: ChangePayment,
                       selectedPaymentMethod: PaymentMethodDTO,
                       amount: AmountDTO) -> ChangePaymentMethodConfirmation? {
        return ChangePaymentMethodConfirmation(changePayment: changePayment,
                                               selectedPaymentMethod: selectedPaymentMethod,
                                               amount: amount)
    }
}
