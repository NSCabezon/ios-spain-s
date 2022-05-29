import CoreFoundationLib

public class MockFaqsRepository: FaqsRepositoryProtocol {
    
    let mockDataInjector: MockDataInjector
    private var dto: FaqsListDTO?

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
        self.dto = self.mockDataInjector.mockDataProvider.faqs.getFaqsList
    }
    
    public func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        switch type {
        case .generic:
            return dto?.generic ?? []
        case .transfersHome:
            return dto?.transfersHome ?? []
        case .globalSearch:
            return dto?.globalSearch ?? []
        case .internalTransferOperative:
            return dto?.internalTrasnferOperative ?? []
        case .billPaymentOperative:
            return dto?.billPaymentOperative ?? []
        case .emittersPaymentOperative:
            return dto?.emittersPaymentOperative ?? []
        case .transferOperative:
            return dto?.transferOperative ?? []
        case .nextSettlementCreditCard:
            return dto?.nextSettlementCreditCard ?? []
        case .helpCenter:
            return dto?.helpCenter ?? []
        case .bizumHome:
            return dto?.bizumHome ?? []
        case .santanderKey:
            return dto?.santanderKey ?? []
        }
    }
    
    public func getFaqsList() -> FaqsListDTO? {
        self.dto = self.mockDataInjector.mockDataProvider.faqs.getFaqsList
        return self.dto
    }
}
