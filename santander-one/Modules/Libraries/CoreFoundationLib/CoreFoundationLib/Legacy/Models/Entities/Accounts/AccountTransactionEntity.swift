import SANLegacyLibrary
import CoreDomain

public struct AccountTransactionEntity: DTOInstantiable {
    
    public enum TransactionType: String {
        case transfer = "transferencia"
        case bill = "recibo"
        case shopping = "compra"
        case contactless = "contactless"
        case bizum = "bizum"
        case unknown = ""
    }
    
    public let dto: AccountTransactionDTO
    
    public init(_ dto: AccountTransactionDTO) {
        self.dto = dto
    }
    
    public var productIdentifier: String {
        return dto.newContract?.formattedValue ?? ""
    }
    
    public var alias: String? {
        return dto.description
    }
    
    public var balance: AmountEntity? {
        return dto.balance.map(AmountEntity.init)
    }
    
    public var detailUI: String? {
        guard let date = dto.operationDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    public var newTransaction: Bool {
        return true
    }
    
    public var amount: AmountEntity? {
        guard let amount = dto.amount else { return nil}
        return AmountEntity(amount)
    }
    
    public var amountUI: String? {
        guard let value = dto.balance?.value else { return nil }
        return String(describing: value)
    }
    
    public var operationDate: Date? {
        return dto.operationDate
    }
    
    public var valueDate: Date? {
        return dto.valueDate
    }
    
    public var dgo: String {
        return dto.dgoNumber?.description ?? ""
    }
    
    public var isPdfEnabled: Bool {
        return dto.pdfIndicator == "2"
    }
    
    public var type: TransactionType {
        guard let lowerCasedAlias = self.alias?.lowercased() else { return .unknown }
        if lowerCasedAlias.contains("transferencia") {
            return .transfer
        } else if lowerCasedAlias.contains("recibo") {
            return .bill
        } else if lowerCasedAlias.contains("compra") {
            return .shopping
        } else if lowerCasedAlias.contains("contactless") {
            return .contactless
        } else if lowerCasedAlias.contains("bizum") {
            return .bizum
        }
        return .unknown
    }
    public var entryStatus: TransactionStatusRepresentableType? {
        guard let transactionStatus = self.dto.transactionStatus else {
            return nil
        }
        return TransactionStatusRepresentableType.init(rawValue: transactionStatus)
    }
}

extension AccountTransactionEntity: EasyPayTransaction {
    public var description: String? {
        return dto.description
    }
}

extension AccountTransactionEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(productIdentifier)
        hasher.combine(balance?.value)
        hasher.combine(valueDate)
        hasher.combine(operationDate)
        hasher.combine(amountUI)
        hasher.combine(detailUI)
        hasher.combine(alias)
        hasher.combine(dgo)
    }
}

extension AccountTransactionEntity: Equatable {
    
    public static func == (lhs: AccountTransactionEntity, rhs: AccountTransactionEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public class AccountTransactionWithAccountEntity {
    
    public var accountTransactionEntity: AccountTransactionEntity
    public var accountEntity: AccountEntity
    
    public init(accountTransactionEntity: AccountTransactionEntity, accountEntity: AccountEntity) {
        self.accountTransactionEntity = accountTransactionEntity
        self.accountEntity = accountEntity
    }
} 

extension AccountTransactionEntity {
    public var isNegativeAmount: Bool {
        return (self.dto.amount?.value ?? 0.0).isSignMinus
    }
}

public extension AccountTransactionEntity {
    var accountPendingTrasactionRepresentable: AccountPendingTransactionRepresentable {
        return self.dto
    }
}
