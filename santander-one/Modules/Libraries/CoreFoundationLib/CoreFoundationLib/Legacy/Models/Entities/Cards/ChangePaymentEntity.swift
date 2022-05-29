//
//  ChangePaymentEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 14/10/2020.
//

import Foundation
import SANLegacyLibrary

public class ChangePaymentEntity: DTOInstantiable {
    public let dto: ChangePaymentDTO
    
    required public init(_ dto: ChangePaymentDTO) {
        self.dto = dto
    }
    
    public var paymentMethodListFiltered: [PaymentMethodEntity]? {
        return self.getFilteredPaymentList(typePayment: [.monthlyPayment, .deferredPayment, .fixedFee])
    }
    
    public var monthlyPaymentMethod: PaymentMethodEntity? {
        return self.getPaymentMethod(typePayment: .monthlyPayment)
    }
    
    public var deferredPaymentMethod: PaymentMethodEntity? {
        return self.getPaymentMethod(typePayment: .deferredPayment)
    }
    
    public var fixedFeePaymentMethod: PaymentMethodEntity? {
        return self.getPaymentMethod(typePayment: .fixedFee)
    }
    
    public var paymentMethodEntity: PaymentMethodEntity? {
        guard let paymentMethodStatus = self.paymentMethodStatus else { return nil }
        return self.getPaymentMethod(typePayment: paymentMethodStatus)
    }
    
    public var paymentMethodList: [PaymentMethodEntity]? {
        return self.dto.paymentMethodList?.compactMap { PaymentMethodEntity($0) }
    }
    
    public var marketCode: String? {
        return self.dto.marketCode
    }
    
    public var currentSettlementType: String? {
        return self.dto.currentSettlementType
    }
    
    public var paymentMethodStatus: PaymentMethodType? {
        if let status = dto.currentPaymentMethod {
            switch status {
            case .monthlyPayment:
                return .monthlyPayment
            case .fixedFee:
                return .fixedFee
            case .minimalPayment:
                return .minimalPayment
            case .deferredPayment:
                return .deferredPayment
            case .immediatePayment:
                return .immediatePayment
            }
        }
        return nil
    }
    
    public var paymentMethodCategory: PaymentMethodCategory? {
        guard let paymentMethod = self.dto.currentPaymentMethod else { return nil }
        let amount = self.getPaymentMethod(typePayment: paymentMethod)?.feeAmount
        return PaymentMethodCategory(paymentMethod, amount)
    }
    
    public var currentPaymentMethod: PaymentMethodType? {
        return self.dto.currentPaymentMethod
    }
    
    public var currentPaymentMethodMode: String? {
        return self.dto.currentPaymentMethodMode
    }
    
    public var referenceStandard: ReferenceStandardDTO? {
        return self.dto.referenceStandard
    }
    
    public var currentPaymentMethodTranslated: String? {
        return self.dto.currentPaymentMethodTranslated
    }
    
    public var currentPaymentMethodDescription: String? {
        return self.dto.currentPaymentMethodDescription
    }
    
    public var hiddenMarketCode: String? {
        return self.dto.hiddenMarketCode
    }
    
    public var hiddenPaymentMethodMode: String? {
        return self.dto.hiddenPaymentMethodMode
    }
    
    public var hiddenReferenceStandard: ReferenceStandardDTO? {
        return self.dto.hiddenReferenceStandard
    }
    
    public func getPaymentMethod(typePayment: PaymentMethodType) -> PaymentMethodEntity? {
        guard let paymentMethodList = self.paymentMethodListFiltered else { return nil }
        return paymentMethodList.first(where: { $0.paymentMethod == typePayment })
    }
    
    public func getPaymentMethod(paymentCategory: PaymentMethodCategory) -> PaymentMethodEntity? {
        guard let paymentMethodType = self.getPaymentMethodTypeFromCategory(typePayment: paymentCategory) else { return nil }
        return self.getPaymentMethod(typePayment: paymentMethodType)
    }
}

private extension ChangePaymentEntity {
    func getFilteredPaymentList(typePayment: [PaymentMethodType]) -> [PaymentMethodEntity]? {
        guard let paymentMethodList = self.paymentMethodList else { return nil }
        return paymentMethodList.filter {
            guard let paymentMethod = $0.paymentMethod else { return false }
            return typePayment.contains(paymentMethod)
            }.sorted { ($0.paymentMethod!.rawValue) > ($1.paymentMethod!.rawValue) }
    }
    
    func getPaymentMethodTypeFromCategory(typePayment: PaymentMethodCategory?) -> PaymentMethodType? {
        guard let paymentMethodCategory = typePayment else { return nil }
        switch paymentMethodCategory {
        case .monthlyPayment:
            return .monthlyPayment
        case .deferredPayment:
            return .deferredPayment
        case .fixedFee:
            return .fixedFee
        }
    }
}
