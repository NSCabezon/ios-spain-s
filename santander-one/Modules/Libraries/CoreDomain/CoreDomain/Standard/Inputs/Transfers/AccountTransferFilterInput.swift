import Foundation

public struct AccountTransferFilterInput {
    public var endAmount: AmountRepresentable?
    public var startAmount: AmountRepresentable?
    public var transferType: TransferType
    public var movementType: MovementType
    public var dateFilter: DateFilter

    public init(endAmount: AmountRepresentable?, startAmount: AmountRepresentable?, transferType: TransferType, movementType: MovementType, dateFilter: DateFilter) {
        self.endAmount = endAmount;
        self.startAmount = startAmount;
        self.transferType = transferType;
        self.movementType = movementType;
        self.dateFilter = dateFilter;
    }

    public var string: String {
        var toString = ""

        if let endAmountDTO = endAmount {
            toString += endAmountDTO.wholePart + endAmountDTO.getDecimalPart()
        }

        if let startAmountDTO = startAmount {
            toString += startAmountDTO.wholePart + startAmountDTO.getDecimalPart()
        }

        toString += transferType.code + movementType.code + dateFilter.string

        return toString
    }
}

public enum TransferType: String, Codable {
    case all = "000"
    case incomechecks = "035"
    case payChecks = "036"
    case cashIncome = "043"
    case payIncome = "044"
    case transfersReceived = "071"
    case transfersIssued = "072"
    case chargeDocuments = "074"
    case chargeReceipts = "174"

    init?(_ type: String) {
        self.init(rawValue: type)
    }

    public var code: String {
        get {
            return self.rawValue
        }
    }
}

public enum MovementType: String, Codable {
    case all = ""
    case expenses = "D"
    case income = "H"

    init?(_ type: String) {
        self.init(rawValue: type)
    }

    public var code: String {
        get {
            return self.rawValue
        }
    }
}
