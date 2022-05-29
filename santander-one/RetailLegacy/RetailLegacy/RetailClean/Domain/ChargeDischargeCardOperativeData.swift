class ChargeDischargeCardOperativeData: ProductSelection<Card> {
    
    var accountList: AccountList?
    var prepaidCardData: PrepaidCardData?
    var account: Account?
    var inputType: ChargeDischargeType?
    var validatePrepaidCard: ValidatePrepaidCard?
    var topUpOptions = [String]()
    var withdrawOptions = [String]()

    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_chargeDischarge", subTitleKey: "deeplink_label_selectOriginCard")
    }
    
    var minAllowed: Double? {
        guard let card = productSelected else { return nil }
        let eCash = CardFactory.isEcashMini(cardDTO: card.cardDTO)
        let minimumAmount = (eCash)
            ? ChargeDischargeCardOperative.Constants.minimumChargeAmountECashMini
            : ChargeDischargeCardOperative.Constants.minimumChargeAmountOtherPrepaidCards
        return minimumAmount.rawValue
    }
    
    var maxAllowed: Double? {
        guard let card = productSelected else { return nil }
        let eCash = CardFactory.isEcashMini(cardDTO: card.cardDTO)
        let maxAmount = (eCash)
            ? ChargeDischargeCardOperative.Constants.maximumChargeAmountECashMini
            : ChargeDischargeCardOperative.Constants.maximumChargeAmountOtherPrepaidCards
        return maxAmount.rawValue
    }
}
