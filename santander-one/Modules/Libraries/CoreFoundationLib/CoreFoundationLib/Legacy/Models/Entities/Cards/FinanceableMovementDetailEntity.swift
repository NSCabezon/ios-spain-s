import SANLegacyLibrary
import Foundation

public protocol FinanceableMovementDetailEntityRepresentable {
    var paidCapital: AmountEntity { get }
    var totalAmount: AmountEntity { get }
    var operationDate: String? { get }
    var lastLiquidationDate: String? { get }
    var numberFees: Int? { get }
    var feeAmount: AmountEntity { get }
    var paidQuotas: Int? { get }
    var pendingQuotas: Int? { get }
    var interestAmount: AmountEntity { get }
    var capitalAmount: AmountEntity { get }
    var amortizations: [FinanceableMovementDetailAmortizationEntity]? { get }
}

public struct FinanceableMovementDetailEntity: FinanceableMovementDetailEntityRepresentable {
    private let dto: FinanceableMovementDetailDTO
    
    public init(dto: FinanceableMovementDetailDTO) {
        self.dto = dto
    }
    
    public var paidCapital: AmountEntity {
        let settledAmortizations = self.dto.movement.easyPayDetail?.amortizations?.filter { $0.descriptionPaymentState == .settled }
        if let amotizations = settledAmortizations {
            let paidCapitalArray = amotizations.map { $0.paidCapital ?? 0 }
            let paidCapitalTotal = paidCapitalArray.reduce(0, +)
            let decimal = Decimal(paidCapitalTotal)
            return AmountEntity(value: decimal)
        }
        return AmountEntity(value: 0)
    }
    
    public var totalAmount: AmountEntity {
        let decimal = Decimal(self.dto.movement.easyPayDetail?.balances?.totalAmount ?? 0)
        return AmountEntity(value: decimal)
    }
    
    public var pendingPaymentCapital: AmountEntity {
        if let lastSettledAmortization = self.amortizations?.first(where: { $0.descriptionPaymentState == .cancelled }) {
            return lastSettledAmortization.pendingPaymentCapital
        }
        if let lastSettledAmortization = self.amortizations?.first(where: { $0.descriptionPaymentState == .settled }) {
            return lastSettledAmortization.pendingPaymentCapital
        }
        let decimal = Decimal(self.dto.movement.easyPayDetail?.balances?.capitalAmount ?? 0)
        return AmountEntity(value: decimal)
    }
    
    public var operationDate: String? {
        return self.dto.movement.operationDate
    }
    
    public var lastLiquidationDate: String? {
        return self.dto.movement.easyPayDetail?.balances?.lastLiquidationDate
    }
    
    public var numberFees: Int? {
        return self.dto.movement.easyPayDetail?.numberFees
    }
    
    public var paidQuotas: Int? {
        return self.dto.movement.easyPayStatus?.paidQuotas
    }
    
    public var pendingQuotas: Int? {
        return self.dto.movement.easyPayStatus?.pendingQuotas
    }
    
    public var feeAmount: AmountEntity {
        guard let pendingQuotas = pendingQuotas, pendingQuotas == 1, let lastAmortization = self.amortizations?.first else {
            let decimal = Decimal(self.dto.movement.easyPayDetail?.balances?.feeAmount ?? 0)
            return AmountEntity(value: decimal)
        }
        return lastAmortization.feeAmount
    }
    
    public var interestAmount: AmountEntity {
        let decimal = Decimal(self.dto.movement.easyPayDetail?.interests?.interestAmount ?? 0)
        let currencyTpe = CurrencyType(self.dto.movement.easyPayDetail?.interests?.currency ?? "EUR")
        return AmountEntity(value: decimal, currency: currencyTpe ?? .eur)
    }
    
    public var capitalAmount: AmountEntity {
        let decimal = Decimal(self.dto.movement.easyPayDetail?.balances?.capitalAmount ?? 0)
        return AmountEntity(value: decimal)
    }
    
    public var amortizations: [FinanceableMovementDetailAmortizationEntity]? {
        let amortizations = self.dto.movement.easyPayDetail?.amortizations?.compactMap {
            FinanceableMovementDetailAmortizationEntity(dto: $0)
        }
        return amortizations?.reversed()
    }
}

public protocol FinanceableMovementDetailAmortizationEntityRepesentable {
    var paymentDate: String? { get }
}

public struct FinanceableMovementDetailAmortizationEntity: FinanceableMovementDetailAmortizationEntityRepesentable {
    private let dto: FinanceableMovementDetailAmortizationDTO
    
    public init(dto: FinanceableMovementDetailAmortizationDTO) {
        self.dto = dto
    }
    
    public var paymentDate: String? {
        return self.dto.paymentDate
    }
    
    public var paymentNumber: Int? {
        return self.dto.paymentNumber
    }
    
    public var feeAmount: AmountEntity {
        let decimal = Decimal(self.dto.totalPaymentAmount ?? 0)
        return AmountEntity(value: decimal)
    }
    
    public var descriptionPaymentState: FinanceableMovementStatus {
        return FinanceableMovementStatus(rawValue: self.dto.descriptionPaymentState?.rawValue ?? "")
    }
    
    public var pendingPaymentCapital: AmountEntity {
        let decimal = Decimal(self.dto.pendingPaymentCapital ?? 0)
        return AmountEntity(value: decimal)
    }
    
    public var interest: AmountEntity {
        let decimal = Decimal(self.dto.interest ?? 0)
        return AmountEntity(value: decimal)
    }
}

public enum FinanceableMovementStatus: String {
    case settled = "Liquidada"
    case pending = "Pendiente"
    case cancelled = "Cancelada"
    
    public init(rawValue: String) {
        switch rawValue {
        case "Liquidada":
            self = .settled
        case "Pendiente":
            self = .pending
        default:
            self = .cancelled
        }
    }
}
