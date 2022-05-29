import Foundation
import SANLegacyLibrary
import SANLegacyLibrary
import CoreFoundationLib

enum NoSepaTransferTypeLocal {
    case bicSwift
    case identifier
}

enum NoSepaTransferTimeLocal {
    case defaultDay
    case now
}

enum NoSepaTransferTime {
    case defaultDay(date: Date)
    case now
}

enum NoSepaTransferType {
    case sepa
    case bicSwift(identifier: String)
    case identifier(name: String, address: String?, locality: String?, country: String?)
}

enum NoSepaTransferExpenses {
    case shared
    case beneficiary
    case payer
    
    static func from(dto: ExpensesType) -> NoSepaTransferExpenses {
        switch dto {
        case .shared: return .shared
        case .our: return .payer
        case .benf: return .beneficiary
        }
    }
    
    var dto: ExpensesType {
        switch self {
        case .shared: return .shared
        case .beneficiary: return .benf
        case .payer: return .our
        }
    }
}

struct InternationalAccount {
    private(set) var dto: InternationalAccountDTO
    
    var account: String {
        return dto.account
    }
    
    var bicSwift: String? {
        return dto.swift
    }
    
    var bankName: String? {
        return dto.bankData?.name
    }
    
    var bankAddress: String? {
        return dto.bankData?.address
    }
    
    var bankLocality: String? {
        return dto.bankData?.location
    }
    
    var bankCountry: String? {
        return dto.bankData?.country
    }
    
    init(account: String) {
        self.dto = InternationalAccountDTO(account: account)
    }
    
    init(swift: String, account: String) {
        self.dto = InternationalAccountDTO(swift: swift, account: account)
    }
    
    init(bankData: BankData, account: String) {
        self.dto = InternationalAccountDTO(bankData: bankData.dto, account: account)
    }
}

struct Address {
    private(set) var dto: AddressDTO
    
    var country: String {
        return dto.country
    }
    
    var address: String? {
        return dto.address
    }
    
    var locality: String? {
        return dto.locality
    }
    
    init(country: String, address: String? = nil, locality: String? = nil) {
        self.dto = AddressDTO(country: country, address: address, locality: locality)
    }
}

struct SwiftValidation {
    private(set) var dto: ValidationSwiftDTO
    
    init(dto: ValidationSwiftDTO) {
        self.dto = dto
    }
}

class NoSepaTransferValidation {
    private(set) var dto: ValidationIntNoSepaDTO
    private let transferExpenses: NoSepaTransferExpenses
    
    init(dto: ValidationIntNoSepaDTO, transferExpenses: NoSepaTransferExpenses) {
        self.dto = dto
        self.transferExpenses = transferExpenses
    }
    
    var settlementAmountPayer: Amount? {
        return Amount.createFromDTO(dto.settlementAmountPayer)
    }
    var settlementAmountBenef: Amount? {
        return Amount.createFromDTO(dto.settlementAmountBenef)
    }
    var impTotComComp: Amount? {
        return Amount.createFromDTO(dto.impTotComComp)
    }
    var impTotComBenefAct: Amount? {
        return Amount.createFromDTO(dto.impTotComBenefAct)
    }
    var impCargoContraval: Amount? {
        return Amount.createFromDTO(dto.impCargoContraval)
    }
    var impNominalOperacion: Amount? {
        return Amount.createFromDTO(dto.impNominalOperacion)
    }
    var impConcepLiqComp: Amount? {
        return Amount.createFromDTO(dto.impConcepLiqComp)
    }
    var valueDate: Date? {
        return dto.valueDate
    }
    
    var refAcelera: String? { dto.refAcelera }
    
    var preciseAmountNumber: Amount { 
        Amount.createFromDTO(dto.tipoCambioPreciso)
    }
    
    var swiftExpenses: Amount? {
        switch transferExpenses {
        case .shared, .payer:
            return Amount.createFromDTO(dto.swiftExpenses?.impConcepLiqComp)
        case .beneficiary:
            return Amount.createFromDTO(dto.swiftExpenses?.impConcepLiqBenefAct)
        }
    }
    var mailExpenses: Amount? {
        switch transferExpenses {
        case .shared, .payer:
            return Amount.createFromDTO(dto.mailExpenses?.impConcepLiqComp)
        case .beneficiary:
            return Amount.createFromDTO(dto.mailExpenses?.impConcepLiqBenefAct)
        }
    }
    var expenses: Amount? {
        switch transferExpenses {
        case .shared, .payer:
            return Amount.createFromDTO(dto.expenses?.impConcepLiqComp)
        case .beneficiary:
            return Amount.createFromDTO(dto.expenses?.impConcepLiqBenefAct)
        }
    }
    var signature: Signature? {
        get {
            return dto.signature.map({ Signature(dto: $0) })
        }
        set {
            dto.signature = newValue?.dto
        }
    }
}

struct BankData {
    private(set) var dto: BankDataDTO
    
    init(name: String, address: String?, locality: String?, country: String?) {
        self.dto = BankDataDTO(name: name, address: address, location: locality, country: country)
    }
}

class NoSepaTransferOperativeData: OperativeParameter {
    let account: Account
    let country: SepaCountryInfo
    let currency: SepaCurrencyInfo
    let amount: Amount
    let concept: String?
    var swiftValidation: SwiftValidation?
    var noSepaTransferValidation: NoSepaTransferValidation?
    var beneficiaryAddress: Address?
    var beneficiary: String?
    var date: Date?
    var transferExpenses: NoSepaTransferExpenses = .shared
    var beneficiaryEmail: String?
    var shouldAskForDetail: Bool = false
    var detailTemporalAccount: String?
    var transferType: NoSepaTransferType?
    var aliasPayee: String?
    var isNewPayee: Bool = false
    var favouriteList: [FavoriteType]
    var favouriteListFiltered: [FavoriteType]?
    var favouriteSelected: FavoriteType?
    var faqs: [FaqsEntity]?
    
    var isSepaNoEur: Bool {
        var isSepa: Bool = false
        switch transferType {
        case .sepa?:
            isSepa = true
        case .identifier?:
            isSepa = false
        case .bicSwift?:
            isSepa = false
        case .none:
            isSepa = false
        }
        
        if amount.currency?.currencyType != .eur && isSepa {
            return true
        }
        return false
    }
    
    var beneficiaryAccount: InternationalAccount? {
        guard let temporalAccount = detailTemporalAccount else { return nil }
        switch transferType {
        case .sepa?:
            return InternationalAccount(account: temporalAccount)
        case .identifier(let name, let address, let locality, let country)?:
            return InternationalAccount(bankData: BankData(name: name, address: address, locality: locality, country: country), account: temporalAccount)
        case .bicSwift(let identifier)?:
            return InternationalAccount(swift: identifier, account: temporalAccount)
        case .none:
            return nil
        }
    }
    
    init(account: Account, country: SepaCountryInfo, currency: SepaCurrencyInfo, amount: Amount, concept: String?, favouriteList: [FavoriteType]) {
        self.account = account
        self.country = country
        self.currency = currency
        self.amount = amount
        self.concept = concept
        self.favouriteList = favouriteList
    }
}
