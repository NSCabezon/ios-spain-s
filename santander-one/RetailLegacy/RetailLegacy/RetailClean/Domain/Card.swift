import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class Card: GenericProduct {

    struct Constants {
        struct CardImage {
            static let relativeURl = "RWD/tarjetas/"
            static let miniature = "m"
            static let fileExtension = ".png"
        }
    }
    let cardEntity: CardEntity
    var cardDTO: CardDTO {
        return cardEntity.dto
    }
    var cardDataDTO: CardDataDTO? {
        return cardEntity.dataDTO
    }
    var isTemporallyOff: Bool {
        return cardEntity.isTemporallyOff
    }
    var inactive: Bool {
        return cardEntity.inactive
    }
    var movements: Int = 0
    
    init(_ entity: CardEntity) {
        self.cardEntity = entity
        super.init()
    }

    convenience init(cardDTO: CardDTO, cardDataDTO: CardDataDTO?, temporallyOff: Bool, inactiveCard: Bool) {
        self.init(CardEntity(cardRepresentable: cardDTO, cardDataDTO: cardDataDTO, cardBalanceDTO: nil, temporallyOff: temporallyOff, inactiveCard: inactiveCard))
    }
    
    override var productIdentifier: String {
        return cardDTO.PAN ?? ""
    }

    var isActive: Bool {
        return !inactive
    }

    var isInactive: Bool {
        return inactive
    }

    override func getAlias() -> String {
        return cardDTO.alias ?? ""
    }

    internal func getAmountDTOValue() -> Amount? {
        fatalError()
    }

    override func getAmountCurrency() -> CurrencyDTO? {
        return getAmountDTOValue()?.currency
    }

    override func getAmountValue() -> Decimal? {
        return getAmountDTOValue()?.value
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getPANShort()
    }

    var isCreditCard: Bool {
        return self is CreditCard
    }

    var isPrepaidCard: Bool {
        return self is PrepaidCard
    }

    var isDebitCard: Bool {
        return self is DebitCard
    }
    
    var cardHeaderAmountInfoKey: String {
        if isCreditCard {
            return "pg_label_outstandingBalanceDots"
        } else if isPrepaidCard {
            return "pg_label_balanceDots"
        } else {
            return ""
        }
    }

    var trackId: String {
        if isCreditCard {
            return "credito"
        } else if isPrepaidCard {
            return "prepago"
        } else {
            return "debito"
        }
    }

    var isReadyForOff: Bool {
        return self.cardEntity.isReadyForOff
    }

    var isReadyForOn: Bool {
        return self.cardEntity.isReadyForOn
    }

    var isCardContractHolder: Bool {
        // NOTA: Ojo porque en los servicios de PGRetail y PGConCestasInversion
        // (PB), vienen campos distintos

        let titularRetail = OwnershipType.holder.rawValue == cardDTO.ownershipType
        let titularPB = OwnershipTypeDesc.holder.rawValue == cardDTO.ownershipTypeDesc?.rawValue
        return titularRetail || titularPB
 
    }

    var isPKAS: Bool {
        // TODO USER STORY ON/OFF: hay que llamar al servicio getDetalleTarjetaToken al pulsar el boton "apagar tarjeta"
        // y despues llamar a éste método. Si es PKAS está disponible la opción
        // igual habrá que añadir un nuevo BO al wrapper con el DTO que devuelve getDetalleTarjetaToken o no
        return false
    }

    var cardContractStatus: CardContractStatus {
        if let status = cardDTO.cardContractStatusType {
            switch status {
            case .active:
                return .active
            case .blocked:
                return .blocked
            default:
                break
            }
        }
        return .other
    }

    var isContractActive: Bool {
        if let type = cardDTO.cardContractStatusType {
            return type == CardContractStatusType.active
        }
        return false
    }

    var isContractBlocked: Bool {
        if let type = cardDTO.cardContractStatusType {
            return type == CardContractStatusType.blocked
        }
        return false
    }

    func buildImageRelativeUrl(_ miniature: Bool) -> String {
        if cardDataDTO != nil {
            return Constants.CardImage.relativeURl
                    + cardDataDTO!.visualCode!
                    + (miniature ? Constants.CardImage.miniature : "")
                    + Constants.CardImage.fileExtension
        }
        return Constants.CardImage.relativeURl
                + getProductType()
                + getProductSubtype()
                + (miniature ? Constants.CardImage.miniature : "")
                + Constants.CardImage.fileExtension
    }

    /**
     * Permite la retirar dinero en cajeros mediante un código
     */
    var allowWithdrawMoneyWithCode: Bool {
        return isDebitCard && isContractActive && isActive && !isTemporallyOff
    }

    /**
     * Permite la recarga de tarjetas prepago
     */
    var allowPrepaidCharge: Bool {
        return false
    }

    /**
     * Permite la opción dinero directo
     */
    var allowDirectMoney: Bool {
        return false
    }

    /**
     * Devuelve true si la tarjeta permite la operativa de Cambio de método de pago
     */
    var allowsChangePaymentMethod: Bool {
        return false
    }

    /**
     * Permite la opción pago luego
     */
    var allowPayLater: Bool {
        return false
    }

    /**
     * Permite la opción Ingreso en tarjeta
     */
    var allowPayoff: Bool {
        return false
    }
    
    /// Allows card limit management
    var allowsCardLimitManagement: Bool {
        return false
    }
    
    var allowsEasyPay: Bool {
        return false
    }
    
    var allowsChangePayment: Bool {
        return self.isCreditCard && self.isCardContractHolder && self.isActive && !self.isTemporallyOff
    }

    override func getTipoInterv() -> OwnershipTypeDesc? {
        return cardDTO.ownershipTypeDesc
    }
    
    func getPANShort() -> String {
        guard let pan = cardDTO.PAN else { return "****" }
        return "*" + (pan.substring(pan.count - 4) ?? "*")
    }

    override func getDetailUI() -> String {
        return cardDTO.PAN?.trim() ?? ""
    }

    override func getAmountUI() -> String {
        fatalError("")
    }

    func getCardDTO() -> CardDTO {
        return cardDTO
    }

    func getContractDTO() -> ContractDTO? {
        return cardDTO.contract
    }

    func getProductType() -> String {
        return cardDTO.productSubtypeDTO?.productType ?? ""
    }

    func getProductSubtype() -> String {
        return cardDTO.productSubtypeDTO?.productSubtype ?? ""
    }
    
    var dailyATMLimit: Amount? {
        guard let amount = cardDataDTO?.dailyATMCurrentLimitAmount else { return nil }
        return Amount.createFromDTO(amount)
    }
    
    var dailyATMMaximumLimit: Amount? {
        guard let amount = cardDataDTO?.dailyATMMaximumLimitAmount else { return nil }
        return Amount.createFromDTO(amount)
    }
    
    var dailyLimit: Amount? {
        guard let amount = cardDataDTO?.dailyCurrentLimitAmount else { return nil }
        return Amount.createFromDTO(amount)
    }
    
    var dailyMaximumLimit: Amount? {
        guard let amount = cardDataDTO?.dailyMaximumLimitAmount else { return nil }
        return Amount.createFromDTO(amount)
    }
}

extension Card: Equatable {
}

extension Card: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(getDetailUI())
    }
}

func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.getDetailUI() == rhs.getDetailUI()
}

extension Card: OperativeParameter {
}
