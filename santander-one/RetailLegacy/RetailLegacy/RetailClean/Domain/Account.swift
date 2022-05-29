import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class Account: GenericProduct {
    
    static func create(_ from: AccountDTO) -> Account {
        return Account(dto: from)
    }
    
    let accountEntity: AccountEntity
    var accountDTO: AccountDTO {
        return accountEntity.dto
    }
    var movements: Int = 0
    
    init(_ entity: AccountEntity) {
        self.accountEntity = entity
        super.init()
    }
    
    override func setVisible(_ visible: Bool) {
        super.setVisible(visible)
        self.accountEntity.isVisible = visible
    }
    
    convenience init(dto: AccountDTO) {
        self.init(AccountEntity(dto))
    }
    
    override var productIdentifier: String {
        return accountDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String? {
        return accountDTO.alias
    }
    
    override func getDetailUI() -> String? {
        guard let iban = getIban() else {
            return nil
        }
        return iban.ibanPapel
    }
    
    func getIban() -> IBAN? {
        guard let ibanDTO = accountDTO.iban else {
            return nil
        }
         let iban = IBAN.create(ibanDTO)
        return iban
    }
    
    override func getAmountValue() -> Decimal? {
        return accountDTO.currentBalance?.value
    }
    
    func getAvailableAmount() -> Amount? {
        return Amount.createFromDTO(accountDTO.availableNoAutAmount)
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return accountDTO.currentBalance?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return accountDTO.ownershipTypeDesc
    }
    
    var currentBalance: Amount? {
        return Amount.createFromDTO(accountDTO.currentBalance)
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getIBANShort()
    }
    
    var productType: String {
        return accountDTO.productSubtypeDTO?.productType ?? ""
    }
    
    var productSubtype: ProductSubtypeDTO? {
        return accountDTO.productSubtypeDTO != nil &&
        accountDTO.productSubtypeDTO!.productType != nil &&
        accountDTO.productSubtypeDTO!.productSubtype != nil ? accountDTO.productSubtypeDTO : nil
    }

    func isKidAccount() -> Bool {
        return checkProductSubtype(productType: "300", productSubtype: "325") || checkProductSubtype(productType: "301", productSubtype: "549")
    }

    func checkProductSubtype(productType: String, productSubtype: String) -> Bool {
        if let productSubtypeDTO = accountDTO.productSubtypeDTO {
            return productSubtypeDTO.productType == productType && productSubtypeDTO.productSubtype == productSubtype
        }
        return false
    }
    
    func getIBANShort() -> String {
        if let ibanDTO = accountDTO.iban {
            let iban = IBAN.create(ibanDTO)
            return iban.ibanShort()
        }

        return "****"
    }
    
    func getIBANShortLisboaStyle() -> String {
        if let ibanDTO = accountDTO.iban {
            let iban = IBAN.create(ibanDTO)
            return iban.ibanShort(showCountryCode: false, asterisksCount: 1, lastDigitsCount: 4)
        }

        return "****"
    }

    func getIBANPapel() -> String {
        if let ibanDTO = accountDTO.iban {
            let iban = IBAN.create(ibanDTO)
            return iban.ibanPapel
        }
        
        return "****"
    }
    
    func getIBANShortWithCountryCode() -> String {
        if let ibanDTO = accountDTO.iban {
            let iban = IBAN.create(ibanDTO)
            return iban.ibanShortWithCountryCode
        }
        return "****"
    }
    
    func getAsteriskIban() -> String {
        if let ibanDTO = accountDTO.iban {
            let iban = IBAN.create(ibanDTO)
            return iban.getAsterisk()
        }
        return "****"
    }

    func isAccountHolder() -> Bool {
        let titularRetail = OwnershipType.holder.rawValue == accountDTO.ownershipType
        let titularPB = OwnershipTypeDesc.holder.rawValue == accountDTO.ownershipTypeDesc?.rawValue
        return titularRetail || titularPB
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        return accountDTO.countervalueCurrentBalanceAmount?.value
    }
    
    public var isPiggyBankAccount: Bool {
        return productSubtype?.productType == "300" && productSubtype?.productSubtype == "351"
    }
}

extension Account: Equatable {}

extension Account: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(getIBANPapel())
    }
}

extension Account: OperativeParameter {}

func == (lhs: Account, rhs: Account) -> Bool {
    return lhs.getIBANPapel() == rhs.getIBANPapel()
}
