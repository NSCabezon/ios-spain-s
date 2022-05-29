//
//  AccountEntity.swift
//  GlobalPosition
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class AccountEntity: Equatable {
    public let representable: AccountRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Account"
    
    public enum OwnershipType: Equatable {
        case holder
        case attorney
        case authorized
        case legalRepresentative
        case additionalMember
        case tutor
        case beneficiary
        case unknown(String)
        case none
    }
    
    struct Constants {
        struct BankLogo {
            static let relativeURl = "RWD/entidades/iconos/"
            static let separator = "_"
            static let fileExtension = ".png"
        }
    }

    public init(_ dto: AccountDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: AccountDTO {
        precondition((representable as? AccountDTO) != nil)
        return representable as! AccountDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: AccountRepresentable) {
        self.representable = representable
    }
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var contractNumber: String? {
        return representable.contractRepresentable?.contractNumber
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var getDetailUI: String? {
        return getIban()?.ibanPapel
    }
    
    public var getIBANShort: String {
        guard let ibanDTO = representable.ibanRepresentable as? IBANDTO else { return "****" }
        return IBANEntity(ibanDTO).ibanShort(asterisksCount: 1)
    }

    public var getIBANFormatted: String {
        guard let ibanDTO = representable.ibanRepresentable as? IBANDTO else { return "" }
        return IBANEntity(ibanDTO).formatted
    }
    
    public func getIban() -> IBANEntity? {
        guard let ibanDTO = representable.ibanRepresentable as? IBANDTO else { return nil }
        return IBANEntity(ibanDTO)
    }
    
    public var amountUI: String? {
        guard let value = representable.currentBalanceRepresentable?.value else { return nil }
        return String(describing: value)
    }
    
    public var currentBalanceAmount: AmountEntity? {
        guard let currentBalance = representable.currentBalanceRepresentable else { return nil}
        return AmountEntity(currentBalance)
    }
    
    public var availableAmount: AmountEntity? {
        guard let availableAmount = representable.availableNoAutAmountRepresentable else { return nil}
        return AmountEntity(availableAmount)
    }
    
    public func getIBANPapel() -> String {
        if let ibanDTO = representable.ibanRepresentable as? IBANDTO {
            let iban = IBANEntity(ibanDTO)
            return iban.ibanPapel
        }
        return "****"
    }
    
    public var overdraftRemaining: AmountEntity? {
        guard let overdraftRemaining = representable.overdraftRemainingRepresentable else { return nil }
        return AmountEntity(overdraftRemaining)
    }
    
    public var earningsAmount: AmountEntity? {
        guard let earningsAmount = representable.earningsAmountRepresentable else { return nil }
        return AmountEntity(earningsAmount)
    }
    
    public var productSubtype: ProductSubtypeRepresentable? {
        return representable.productSubtypeRepresentable != nil &&
        representable.productSubtypeRepresentable?.productType != nil &&
        representable.productSubtypeRepresentable?.productSubtype != nil ? representable.productSubtypeRepresentable : nil
    }
    
    public var ownershipType: OwnershipType {
        switch dto.ownershipType {
        case "01"?: return .holder
        case "07"?: return .attorney
        case "08"?: return .authorized
        case "09"?: return .legalRepresentative
        case "17"?: return .additionalMember
        case "24"?: return .tutor
        case "92"?: return .beneficiary
        default:
            if let ownershipTypeDesc = dto.ownershipTypeDesc {
                return .unknown(ownershipTypeDesc.rawValue)
            } else {
                return .none
            }
        }
    }
    
    public var entityCode: String? {
        guard let iban = representable.ibanRepresentable as? IBANDTO else { return nil }
        return IBANEntity(iban).getEntityCode()
    }
    
    public var contryCode: String? {
       guard let iban = representable.ibanRepresentable as? IBANDTO else { return nil }
        return IBANEntity(iban).countryCode
    }
    
    public var isPiggyBankAccount: Bool {
        return productSubtype?.productType == "300" && productSubtype?.productSubtype == "351"
    }
    
    public func getCounterValueAmountValue() -> Decimal? {
        return representable.countervalueCurrentBalanceAmountRepresentable?.value
    }

    public func getCounterValueAvailableAmountValue() -> Decimal? {
        return representable.countervalueAvailableNoAutAmountRepresentable?.value
    }
    
    public func getAmount() -> AmountEntity? {
        guard let amountDTO = representable.currentBalanceRepresentable else {
            return nil
        }
        return AmountEntity(amountDTO)
    }
    
    public func isAccountHolder() -> Bool {
        let titularRetail = OwnershipType.holder == ownershipType
        let titularPB = OwnershipTypeDesc.holder == representable.ownershipTypeDesc
        return titularRetail || titularPB
    }
    
    public static func == (lhs: AccountEntity, rhs: AccountEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var currencyType: CurrencyType? {
        return representable.currencyRepresentable?.currencyType
    }
    
    public var situationType: String? {
        return representable.tipoSituacionCto
    }
}

extension AccountEntity: GlobalPositionProduct {}

extension AccountEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(getIban()?.ibanPapel)
    }
}

extension AccountEntity {
    public func buildImageRelativeUrl() -> String {
        guard let countryCode = representable.ibanRepresentable?.countryCode.lowercased(),
                let bankCode = representable.ibanRepresentable?.codBban.substring(0, 4)
            else { return ""}
        return AccountEntity.Constants.BankLogo.relativeURl
            + countryCode
            + AccountEntity.Constants.BankLogo.separator
            + bankCode
            + AccountEntity.Constants.BankLogo.fileExtension
            
    }
}
