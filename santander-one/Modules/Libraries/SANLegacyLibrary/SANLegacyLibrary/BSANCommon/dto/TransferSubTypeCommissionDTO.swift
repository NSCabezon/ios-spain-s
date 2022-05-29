import Foundation

public enum TransferSubTypeDTO: String, Codable {
    case urgent
    case instant
    case standard
}

public struct TransferPackage {
    public var numberTransfers: Int
    public var remainingTransfers: Int
    public var packageName: String
    public var expirationDate: String
    
    public init(numberTransfers: Int, remainingTransfers: Int, packageName: String, expirationDate: String) {
        self.numberTransfers = numberTransfers
        self.remainingTransfers = remainingTransfers
        self.packageName = packageName
        self.expirationDate = expirationDate
    }
}

public struct TransferSubTypeCommissionDTO: Decodable {
    
    public let commissions: [TransferSubTypeDTO: AmountDTO?]
    public let taxes: [TransferSubTypeDTO: AmountDTO?]?
    public var total: [TransferSubTypeDTO: AmountDTO?]?
    public var transferPackage: [TransferSubTypeDTO: TransferPackage?]?
    
    enum CodingKeys: String, CodingKey {
        case instant = "inmediata"
        case urgent = "urgente"
        case standard = "estandar"
    }
    
    enum BasicDataCodingKeys: String, CodingKey {
        case basicData = "datosBasicos"
    }
    
    enum CommissionCodingKeys: String, CodingKey {
        case commission = "impComision"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let instant = try? values
            .nestedContainer(keyedBy: BasicDataCodingKeys.self, forKey: .instant)
            .nestedContainer(keyedBy: CommissionCodingKeys.self, forKey: .basicData)
            .decodeIfPresent(Decimal.self, forKey: .commission)
        let urgent = try? values
            .nestedContainer(keyedBy: BasicDataCodingKeys.self, forKey: .urgent)
            .nestedContainer(keyedBy: CommissionCodingKeys.self, forKey: .basicData)
            .decodeIfPresent(Decimal.self, forKey: .commission)
        let standard = try? values
            .nestedContainer(keyedBy: BasicDataCodingKeys.self, forKey: .standard)
            .nestedContainer(keyedBy: CommissionCodingKeys.self, forKey: .basicData)
            .decodeIfPresent(Decimal.self, forKey: .commission)
        self.commissions = [
            .urgent: urgent.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .instant: instant.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .standard: standard.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) })
        ]
        self.taxes = [
            .urgent: urgent.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .instant: instant.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .standard: standard.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) })
        ]
        self.total = [
            .urgent: urgent.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .instant: instant.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) }),
            .standard: standard.map({ AmountDTO(value: $0, currency: .create(SharedCurrencyType.default)) })
        ]
        self.transferPackage = [
            .urgent: nil,
            .instant: nil,
            .standard: nil
        ]
    }
    
    public init(commissions: [TransferSubTypeDTO: AmountDTO?], taxes: [TransferSubTypeDTO: AmountDTO?]?, total: [TransferSubTypeDTO: AmountDTO?]?,transferPackage: [TransferSubTypeDTO: TransferPackage?]?){
        self.commissions = commissions
        self.taxes = taxes
        self.total = total
        self.transferPackage = transferPackage
    }
}
