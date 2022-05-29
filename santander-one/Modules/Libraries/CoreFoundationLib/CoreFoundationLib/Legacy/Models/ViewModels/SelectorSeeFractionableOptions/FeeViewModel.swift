//
//  FeeViewModel.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 7/3/20.
//
import Foundation

public final class FeeViewModel {
    private let feeEntity: MontlyPaymentFeeEntity
    public let maxMonths: String
    private let easyPayAmortization: EasyPayAmortizationEntity?
    private let allInOneCard: Bool
    public var action: ((EasyPayAmortizationEntity?) -> Void)?
    
    public init(feeEntity: MontlyPaymentFeeEntity, maxMonths: Int, allInOneCard: Bool) {
        self.feeEntity = feeEntity
        self.easyPayAmortization = feeEntity.easyPayAmortization
        self.maxMonths = String(maxMonths)
        self.allInOneCard = allInOneCard
    }
    
    public var isAllInOneCard: Bool {
        self.allInOneCard
    }
    
    public func isFeePerMonths() -> Bool {
        return feeEntity.fee != .zero && feeEntity.months != .zero
    }
    
    public func doAction() {
        self.action?(easyPayAmortization)
    }
    
    public var amount: AmountEntity? {
        AmountEntity(value: feeEntity.fee)
    }
    
    public var months: String {
        String(feeEntity.months)
    }
    
    public var isEasyPayMonthText: Bool {
        self.allInOneCard && feeEntity.months == 3
    }
        
    public var getFeeEntity: MontlyPaymentFeeEntity {
        self.feeEntity
    }
}
