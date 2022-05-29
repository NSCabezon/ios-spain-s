//
//  CardEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public enum CardDOType {
    enum EcashConstants: String {
        case miniTypeProduct = "502"
        case miniSubtypeProduct = "536"

    }

    public var keyGP: String {
        switch self {
        case .credit:
            return "pg_label_creditCard"
        case .debit:
            return "pg_label_debitCard"
        case .prepaid:
            return "pg_label_ecashCard"
        }
    }

    case debit, credit, prepaid

    public init(_ representable: CardRepresentable) {
        guard let type = representable.cardType?.uppercased() else {
            let firstChar = representable.cardTypeDescription?.prefix(1).lowercased()
            if firstChar?.elementsEqual("c") == true {
                self = .credit
            } else if firstChar?.elementsEqual("p") == true {
                self = .prepaid
            } else if firstChar?.elementsEqual("d") == true {
                self = .debit
            } else {
                self = .debit
            }
            return
        }
        switch type {
        case "C":
            self = .credit
        case "P":
            self = .prepaid
        case "D":
            self = .debit
        default:
            self = .debit
        }
    }
}

public class CardEntity {

    struct Constants {
        struct CardImage {
            static let relativeURl = "RWD/tarjetas/"
            static let miniature = "m"
            static let fileExtension = ".png"
        }
    }
    public var representable: CardRepresentable
    // swiftlint:disable force_cast
    public var dto: CardDTO {
        get {
            precondition((representable as? CardDTO) != nil)
            return representable as! CardDTO
        }
        set(newValue) {
            precondition((representable as? CardDTO) != nil)
            representable = newValue
        }
    }
    // swiftlint:enable force_cast
    public var cardType: CardDOType
    public var dataDTO: CardDataDTO?
    public var cardBalanceDTO: CardBalanceDTO?
    public var isVisible: Bool = true
    public var productId: String = "Card"
    public var isTemporallyOff: Bool = false
    public var inactive: Bool = false

    public convenience init(cardRepresentable: CardRepresentable,
                            cardDataDTO: CardDataDTO?,
                            cardBalanceDTO: CardBalanceDTO?,
                            temporallyOff: Bool,
                            inactiveCard: Bool) {
        self.init(cardRepresentable)
        self.dataDTO = cardDataDTO
        self.cardBalanceDTO = cardBalanceDTO
        self.isTemporallyOff = temporallyOff
        self.inactive = inactiveCard
        self.dto.cardBalanceDTO = cardBalanceDTO
        self.dto.dataDTO = cardDataDTO
        self.dto.temporallyOff = isTemporallyOff
        self.dto.inactive = inactiveCard
        self.cardType = CardDOType(representable)
    }
    
    required public init(_ representable: CardRepresentable) {
        self.representable = representable
        self.cardType = CardDOType(representable)
    }
    
    public var productIdentifier: String {
        return representable.PAN ?? ""
    }

    public var alias: String? {
        return representable.alias?.camelCasedString
    }

    public var detailUI: String? {
        return representable.PAN?.trim() ?? ""
    }

    public var visualCode: String? {
        if let dataDTO = dataDTO {
            return dataDTO.visualCode
        }
        return productType + productSubtype
    }

    public var amount: AmountEntity? {
        switch cardType {
        case .debit:
            return nil
        case .credit:
            return currentBalance
        case .prepaid:
            return availableAmount
        }
    }

    public var creditLimitAmount: AmountEntity {
        if let amount = cardBalanceDTO?.creditLimitAmount {
            return AmountEntity(amount)
        } else {
            return AmountEntity(value: 0.0)
        }
    }

    public var currentBalance: AmountEntity {
        if let amount = cardBalanceDTO?.currentBalance {
            return AmountEntity(amount)
        } else {
            return AmountEntity(value: 0.0)
        }
    }

    public var availableAmount: AmountEntity {
        if let amount = cardBalanceDTO?.availableAmount {
            return AmountEntity(amount)
        } else {
            return AmountEntity(value: 0.0)
        }
    }

    public func buildImageRelativeUrl(miniature: Bool) -> String {
        if let dataDTO = dataDTO {
            return Constants.CardImage.relativeURl
                + (dataDTO.visualCode ?? "")
                + (miniature ? Constants.CardImage.miniature : "L")
                + Constants.CardImage.fileExtension
        }
        return Constants.CardImage.relativeURl
            + productType
            + productSubtype
            + (miniature ? Constants.CardImage.miniature : "L")
            + Constants.CardImage.fileExtension
    }

    public var pan: String {
        return representable.formattedPAN ?? ""
    }

    public var shortContract: String {
        guard let PAN = representable.formattedPAN else { return "****" }
        return "*" + (PAN.substring(PAN.count - 4) ?? "*")
    }

    public var cardContract: String {
        guard let contract = representable.contractRepresentable?.contractNumber else { return "" }
        return contract
    }

    public var formattedContract: String {
        guard let contract = representable.contractRepresentable?.contractNumber else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }

    public var amountUI: String? {
        guard let value = representable.currencyRepresentable?.currencyName else { return nil }
        return String(describing: value)
    }

    public var productType: String {
        return representable.productSubtypeRepresentable?.productType ?? ""
    }

    public var productSubtype: String {
        return representable.productSubtypeRepresentable?.productSubtype ?? ""
    }

    public var isCreditCard: Bool {
        return cardType == .credit
    }

    public var isPrepaidCard: Bool {
        return cardType == .prepaid
    }

    public var isDebitCard: Bool {
        return cardType == .debit
    }

    public var isDisabled: Bool {
        return isInactive || isTemporallyOff || isContractBlocked
    }

    public var isPINAndCVVDisabled: Bool {
        return isTemporallyOff && !isInactive
    }

    public var isInactive: Bool {
        return inactive
    }

    public var isActiveOrNotButDisabled: Bool {
        return isTemporallyOff || isContractBlocked
    }

    public var isOwnerSuperSpeed: Bool {
        return dataDTO?.cardSuperSpeedDTO?.qualityParticipation == OwnershipType.holder.rawValue
    }

    public var isBeneficiary: Bool {
        return representable.ownershipType == "17"
    }

    public var allowsDirectMoney: Bool {
        return representable.allowsDirectMoney ?? false
    }

    public var allowsPayLater: Bool {
        return isContractActive && isCardContractHolder && isCreditBalance()
    }
    
    public var isContractActive: Bool {
        if let type = representable.cardContractStatusType {
            return type == .active
        }
        return false
    }
    
    public var isContractInactive: Bool {
        if let type = representable.cardContractStatusType {
            return type == .inactive
        }
        return false
    }
    
    public var isContractBlocked: Bool {
        if let type = representable.cardContractStatusType {
            return type == CardContractStatusType.blocked
        }
        return false
    }

    public var isContractCancelled: Bool {
        if let type = representable.cardContractStatusType {
            return type == CardContractStatusType.cancelled
        }
        return false
    }
    
    public var isContractReplacement: Bool {
        if let type = representable.cardContractStatusType {
            return type == CardContractStatusType.replacement
        }
        return false
    }
    
    public var isContractIssued: Bool {
        if let type = representable.cardContractStatusType {
            return type == CardContractStatusType.issued
        }
        return false
    }

    public var isCardContractHolder: Bool {
        let titularRetail = OwnershipType.holder.rawValue == representable.ownershipType
        let titularPB = OwnershipTypeDesc.holder.rawValue == representable.ownershipTypeDesc?.rawValue
        return titularRetail || titularPB
    }

    public var isReadyForOff: Bool {
        return isCardContractHolder && !inactive && !isTemporallyOff && !isContractCancelled
    }

    public var isReadyForOn: Bool {
        return isCardContractHolder && !inactive && isTemporallyOff && !isContractCancelled
    }

    public var cardHeaderAmountInfoKey: String {
        if isCreditCard {
            return "pg_label_outstandingBalanceDots"
        } else if isPrepaidCard {
            return "pg_label_balanceDots"
        } else {
            return ""
        }
    }

    public var dailyATMLimit: AmountEntity? {
        guard let amount = dataDTO?.dailyATMCurrentLimitAmount else { return nil }
        return AmountEntity(amount)
    }

    public var dailyATMMaximumLimit: AmountEntity? {
        guard let amount = dataDTO?.dailyATMMaximumLimitAmount else { return nil }
        return AmountEntity(amount)
    }

    public var dailyLimit: AmountEntity? {
        guard let amount = dataDTO?.dailyCurrentLimitAmount else { return nil }
        return AmountEntity(amount)
    }

    public var dailyMaximumLimit: AmountEntity? {
        guard let amount = dataDTO?.dailyMaximumLimitAmount else { return nil }
        return AmountEntity(amount)
    }

    public var expirationDate: String? {
        return dataDTO?.cardSuperSpeedDTO?.expirationDate
    }

    public var formattedPAN: String? {
        return representable.formattedPAN
    }

    public func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return (alias ?? getAliasCamelCase()) + " | " + shortContract
    }

    func transformToAliasAndInfo(alias: String) -> String {
        if alias.count <= 20 {
            return alias
        } else {
            return (alias.substring(0, 19) ?? "") + "..."
        }
    }

    public func getAliasCamelCase() -> String {
        return alias?.camelCasedString ?? ""
    }

    public func getPANShort() -> String {
        guard let pan = representable.PAN else { return "****" }
        return "***" + (pan.substring(pan.count - 4) ?? "*")
    }

    public func hiddenPan() -> String {
        guard let pan = representable.PAN, pan.count >= 4 else { return "····" }
        let lastFourDigits = pan.substring(pan.count - 4) ?? ""
        var hiddenPan = String(repeating: "···· ", count: (pan.count - 4) / 4)
        hiddenPan += lastFourDigits
        return hiddenPan
    }

    public var trackId: String {
        switch cardType {
        case .credit:
            return "credito"
        case .debit:
            return "debito"
        case .prepaid:
            return "prepago"
        }
    }

    public var description: String? {
        return self.dataDTO?.description
    }

    public var status: CardContractStatusType? {
        return representable.cardContractStatusType
    }

    public var statusDescription: String? {
        return representable.statusDescription
    }

    public var situation: CardContractStatusType? {
        return representable.situation
    }
}

extension CardEntity: Equatable, Hashable {
    public static func == (lhs: CardEntity, rhs: CardEntity) -> Bool {
        return lhs.detailUI == rhs.detailUI
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(detailUI)
    }
}

extension CardEntity: GlobalPositionProduct {}

// MARK: - Cardboarding
extension CardEntity {
    public func cardImageUrl() -> String {
          if let dataDTO = dataDTO {
              return Constants.CardImage.relativeURl
                  + (dataDTO.visualCode ?? "")
                  + Constants.CardImage.fileExtension
          }
          return Constants.CardImage.relativeURl
              + productType
              + productSubtype
              + Constants.CardImage.fileExtension
      }
    public var stampedName: String? {
        return dataDTO?.stampedName
    }
}

// MARK: - EasyPay
extension CardEntity {
    public var isAllInOne: Bool {
        let candidatesTypes = ["501", "502"]
        let candidatesSubtype = ["665", "699", "608", "620", "694"]
        return candidatesTypes.contains(self.productType) && candidatesSubtype.contains(self.productSubtype)
    }
}

private extension CardEntity {
    
    func creditCardBalance() -> AmountEntity {
        guard let cardBalance = self.cardBalanceDTO else { return AmountEntity(value: 0) }
        return cardBalance.currentBalance.map(AmountEntity.init) ?? AmountEntity(value: 0)
    }
    
    func isCreditBalance() -> Bool {
        if let value = creditCardBalance().value {
            return abs(value) > 0
        }
        return false
    }
}
