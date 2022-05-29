public struct FinanceableMovementDetailDTO: Codable {
    public let movement: FinanceableMovementDetailObjectDTO
}

// MARK: - FinanceableMovementDetailObjectDTO
public struct FinanceableMovementDetailObjectDTO: Codable {
    public let contractID, movementID, company, center: String?
    public let product, pan: String?
    public let normalIndicator: Int?
    public let currency: String?
    public let amount, amountOriginCurrency: Double?
    public let originalCurrency: String?
    public let change: Double?
    public let liquidationDate, operationDate, accountingDate: String?
    public let billType: Int?
    public let shopName, townName, originCompany, originOffice: String?
    public let originTerminal: String?
    public let dgoNumber: Int?
    public let statementNumber: String?
    public let movementNumber: Int?
    public let movementDescription: String?
    public let clearedIndicator: Int?
    public let shopCode, activityCode, operationType, signedValue: String?
    public let easyPay: Int?
    public let billLiquidationDate: String?
    public let easyPayDetail: EasyPayDetail?
    public let elegibleFinance: String?
    public let easyPayStatus: FinanceableMovementDetailEasyPayStatus?
    public let country: FinanceableMovementDetailCountry?
    public let hour, movementType: String?

    private enum CodingKeys: String, CodingKey {
        case contractID = "contractId"
        case movementID = "movementId"
        case company, center, product, pan, normalIndicator, amount, currency, amountOriginCurrency, originalCurrency, change, liquidationDate, operationDate, accountingDate, billType, shopName, townName, originCompany, originOffice, originTerminal, dgoNumber, statementNumber, movementNumber
        case movementDescription = "description"
        case clearedIndicator, shopCode, activityCode, operationType, signedValue, easyPay, billLiquidationDate, easyPayDetail, elegibleFinance, easyPayStatus, country, hour, movementType
    }
}

// MARK: - EasyPayDetail
public struct EasyPayDetail: Codable {
    public let numberFees: Int?
    public let balances: Balances?
    public let interests: Interests?
    public let amortizations: [FinanceableMovementDetailAmortizationDTO]?
}

// MARK: - Amortization
public struct FinanceableMovementDetailAmortizationDTO: Codable {
    public let idContrato: String?
    public let numeroOperacionCuotas, numeroFinanciacion, paymentNumber: Int?
    public let paymentDate: String?
    public let interest, paidCapital, totalPaymentAmount: Double?
    public let paymentState: Int?
    public let pendingPaymentCapital: Double?
    public let descriptionPaymentState: FinanceableMovementDetailAmortizationDescriptionPaymentState?
}

// MARK: - Balances
public struct Balances: Codable {
    public let capitalAmount, totalAmount, feeAmount: Double?
    public let lastLiquidationDate: String?
}

// MARK: - Interests
public struct Interests: Codable {
    public let outstandingInterest: Double?
    public let annualNominalInterest, amortizedInterest, interestAmount: Double?
    public let currency: String?
}

// MARK: - Country
public struct FinanceableMovementDetailCountry: Codable {
    public let code: String?
    public let name: String?
}

// MARK: - FinanceableMovementDetailEasyPayStatus
public struct FinanceableMovementDetailEasyPayStatus: Codable {
    public let statusCode: FinanceableMovementDetailEasyPayStatusCode?
    public let paidQuotas: Int?
    public let pendingQuotas: Int?
    public let cancelledQuotas: Int?
}

// MARK: - FinanceableMovementDetailEasyPayStatusCode
public enum FinanceableMovementDetailEasyPayStatusCode: String, Codable {
    case pending = "PENDING"
    case settled = "SETTLED"
    case cancelled = "CANCELLED"
}

// MARK: - FinanceableMovementDetailAmortizationDescriptionPaymentState
public enum FinanceableMovementDetailAmortizationDescriptionPaymentState: String, Codable {
    case settled = "Liquidada"
    case pending = "Pendiente"
    case cancelled = "Cancelada"
}
