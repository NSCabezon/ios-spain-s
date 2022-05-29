//

import Foundation
import CoreDomain

public struct AccountMovementListDTO: Codable {
    public var movements: [AccountMovementDTO] = []
    public var previous: PreviousMovementsDTO?
    public var next: NextMovementsDTO?
    
    public struct PreviousMovementsDTO: Codable {
        public let limit: Int?
        public let offset: String?
        public let direction: String?
    }

    public struct NextMovementsDTO: Codable {
        public let limit: Int?
        public let offset: String?
        public let direction: String?
    }
}

public struct AccountMovementDTO: Codable {
    public let movementId: String
    public let operationDate: Date
    public let accountingDate: Date
    public let consolidatedDate: Date?
    public let valueDate: Date
    public let amount: Double
    public let balance: Double
    public let currency: String
    public let basicOperationCode: String
    public let bankOperationCode: String
    public let movementOrder: Int?
    public let movementNumber: Int
    public let movementNumberDay: Int?
    public let operationType: String
    public let movementType: String
    public let dgoNumber: Int
    public let operationCode: String
    public let originOffice: String
    public let description: String
    public let concept: String
    public let reference1: String?
    public let reference2: String?
    public let docNumber: String?
    public let pdfIndicator: Int?
    public let terminal: String?
    
    public var currencyDTO: CurrencyDTO {
        return CurrencyDTO(currencyName: self.currency, currencyType: .parse(self.currency))
    }
    
    public var amountDTO: AmountDTO {
        return AmountDTO(value: Decimal(self.amount), currency: currencyDTO)
    }
    public var balanceDTO: AmountDTO {
        return AmountDTO(value: Decimal(self.balance), currency: currencyDTO)
    }
}

extension AccountMovementListDTO: DateParseable {
    
    public static var formats: [String: String] {
        return [
            "movements.operationDate": "yyyy-MM-dd",
            "movements.accountingDate": "yyyy-MM-dd",
            "movements.consolidatedDate": "yyyy-MM-dd",
            "movements.valueDate": "yyyy-MM-dd"
        ]
    }
}

extension AccountMovementDTO: AccountMovementRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        return AmountDTO(value: Decimal(amount),
                         currency: CurrencyDTO.create(currency))
    }
    
    public var balanceRepresentable: AmountRepresentable? {
        return AmountDTO(value: Decimal(balance),
                         currency: CurrencyDTO.create(currency))
    }
}
