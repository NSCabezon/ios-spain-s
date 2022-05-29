import SANLegacyLibrary
import CoreFoundationLib

class CreditCard: Card {
    static func createCreditCard(cardDTO: CardDTO,
                                 cardDataDTO: CardDataDTO?,
                                 temporallyOffCard: InactiveCardDTO?,
                                 inactiveCard: InactiveCardDTO?,
                                 cardBalanceDTO: CardBalanceDTO?) -> CreditCard {
        return CreditCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOff: temporallyOffCard != nil, inactiveCard: inactiveCard != nil, cardBalanceDTO: cardBalanceDTO)
    }
    
    static func createCreditCard(cardEntity: CardEntity) -> CreditCard {
        return CreditCard(cardEntity: cardEntity)
    }
    
    var cardBalanceDTO: CardBalanceDTO? {
        return cardEntity.cardBalanceDTO
    }
    
    private init(cardDTO: CardDTO,
                 cardDataDTO: CardDataDTO?,
                 temporallyOff: Bool,
                 inactiveCard: Bool,
                 cardBalanceDTO: CardBalanceDTO?) {
        super.init(CardEntity(cardRepresentable: cardDTO, cardDataDTO: cardDataDTO, cardBalanceDTO: cardBalanceDTO, temporallyOff: temporallyOff, inactiveCard: inactiveCard))
    }
    
    private init(cardEntity: CardEntity) {
        super.init(cardEntity)
    }
    
    override func getAmountDTOValue() -> Amount? {
        return getCreditBalance()
    }
    
    override func getAmountUI() -> String {
        return getAmount()?.getAbsFormattedAmountUIWith1M() ?? ""
    }
    
    func getCreditBalance() -> Amount {
        guard let cardBalance = self.cardBalanceDTO else { return Amount.createZeroEur() }
        return Amount.createFromDTO(cardBalance.currentBalance)
    }
    
    func getCreditLimitAmount() -> Amount {
        guard let cardBalance = self.cardBalanceDTO else { return Amount.createFromDTO(nil) }
        return Amount.createFromDTO(cardBalance.creditLimitAmount)
    }
    
    func getAvailableAmount() -> Amount? {
        guard let cardBalance = self.cardBalanceDTO else { return nil }
        return Amount.createFromDTO(cardBalance.availableAmount)
    }
    
    /**
     * Devuelve true si la tarjeta tiene saldo dispuesto > 0€
     */
    func isCreditBalance() -> Bool {
        if let value = getCreditBalance().value {
            return abs(value) > 0
        }
        return false
    }
    
    /**
     * Permite la opción dinero directo
     */
    override var allowDirectMoney: Bool {
        return cardDTO.allowsDirectMoney ?? false
    }
    
    /**
     * Devuelve true si la tarjeta permite la operativa de Cambio de método de pago
     */
    override var allowsChangePaymentMethod: Bool {
        return isCardContractHolder
    }
    
    /**
     * Permite la opción pago luego
     */
    override var allowPayLater: Bool {
        return isContractActive && isCardContractHolder && isCreditBalance()
    }
    
    /**
     * Permite la opción Ingreso en tarjeta
     */
    override var allowPayoff: Bool {
        return isContractActive && isCardContractHolder && isCreditBalance()
    }
    
    override var allowsEasyPay: Bool {
        return isCardContractHolder
    }
    
    /// Allows card limit management
    override var allowsCardLimitManagement: Bool {
        return true
    }
    
}
