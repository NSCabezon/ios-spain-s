import CoreDomain

public enum FaqsType {
    case generic
    case transfersHome
    case globalSearch
    case internalTransferOperative
    case billPaymentOperative
    case emittersPaymentOperative
    case transferOperative
    case nextSettlementCreditCard
    case helpCenter
    case bizumHome
    case santanderKey
}

public struct FaqsListDTO: Codable {
    public let generic: [FaqDTO]?
    public let transfersHome: [FaqDTO]?
    public let globalSearch: [FaqDTO]?
    public let internalTrasnferOperative: [FaqDTO]?
    public let billPaymentOperative: [FaqDTO]?
    public let emittersPaymentOperative: [FaqDTO]?
    public let transferOperative: [FaqDTO]?
    public let nextSettlementCreditCard: [FaqDTO]?
    public let helpCenter: [FaqDTO]?
    public let bizumHome: [FaqDTO]?
    public let santanderKey: [FaqDTO]?

    public func sortedLists() -> [[FaqDTO]?] {
        return [generic,
                transfersHome,
                billPaymentOperative,
                emittersPaymentOperative,
                internalTrasnferOperative]
    }
}

public struct FaqDTO: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id_faq"
        case question
        case answer
        case icon
        case keywords
    }
    
    public let identifier: Int?
    public let question: String
    public let answer: String
    public let icon: String?
    public let keywords: [String]?
    
    public init(identifier: Int?, question: String, answer: String, icon: String?, keywords: [String]?) {
        self.identifier = identifier
        self.question = question
        self.answer = answer
        self.icon = icon
        self.keywords = keywords
    }
}

extension FaqDTO: FaqRepresentable {}
