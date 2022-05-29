import SANLegacyLibrary

struct ChangePayment {
    private(set) var dto: ChangePaymentDTO
    
    init(_ dto: ChangePaymentDTO) {
        self.dto = dto
    }
    
    private func getFilteredPaymentList(typePayment: [PaymentMethodType]) -> [PaymentMethod]? {
        guard let paymentMethodList = paymentMethodList else { return nil }
        return paymentMethodList.filter {
            guard let paymentMethod = $0.paymentMethod else { return false }
            return typePayment.contains(paymentMethod)
            }.sorted { ($0.paymentMethod!.rawValue) > ($1.paymentMethod!.rawValue) }
    }
    
    var paymentMethodListFiltered: [PaymentMethod]? {
        return getFilteredPaymentList(typePayment: [.monthlyPayment, .deferredPayment, .fixedFee])
    }
    
    var paymentMethodList: [PaymentMethod]? {
        return dto.paymentMethodList?.compactMap { PaymentMethod($0) }
    }
    var marketCode: String? {
        return dto.marketCode
    }
    var currentSettlementType: String? {
        return dto.currentSettlementType
    }
    var paymentMethodStatus: PaymentMethodStatus? {
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
    var currentPaymentMethod: PaymentMethodType? {
        return dto.currentPaymentMethod
    }
    var currentPaymentMethodMode: String? {
        return dto.currentPaymentMethodMode
    }
    var referenceStandard: ReferenceStandardDTO? {
        return dto.referenceStandard
    }
    var currentPaymentMethodTranslated: String? {
        return dto.currentPaymentMethodTranslated
    }
    var currentPaymentMethodDescription: String? {
        return dto.currentPaymentMethodDescription
    }
    var hiddenMarketCode: String? {
        return dto.hiddenMarketCode
    }
    var hiddenPaymentMethodMode: String? {
        return dto.hiddenPaymentMethodMode
    }
    var hiddenReferenceStandard: ReferenceStandardDTO? {
        return dto.hiddenReferenceStandard
    }
}

extension ChangePayment: OperativeParameter {}
