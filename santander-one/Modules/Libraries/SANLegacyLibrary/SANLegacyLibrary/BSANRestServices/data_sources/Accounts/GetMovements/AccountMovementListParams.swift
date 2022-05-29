public struct AccountMovementListParams: Codable {
    
    public enum MovementType: String {
        case debit = "Debe"
        case credit = "Haber"
    }
    
    public let accountNumber: String?
    let limit: Int
    let offset: String?
    let direction: String?
    let fromDate: Date
    let toDate: Date
    let fromAmount: Double?
    let toAmount: Double?
    let movementType: String?
    let operationCode: String?
    let concept: String?
    let bankingOperation: String?
    let basicOperation: String?
    let fromAnnotationNote: Date?
    let toAnnotationNote: Date?
    
    public init(accountNumber: String? = nil,
        limit: Int = 200,
        offset: String? = nil,
        direction: String? = nil,
        fromDate: Date,
        toDate: Date,
        fromAmount: Double? = nil,
        toAmount: Double? = nil,
        movementType: MovementType? = nil,
        operationCode: [String]? = nil,
        concept: String? = nil,
        bankingOperation: String? = nil,
        basicOperation: String? = nil,
        fromAnnotationNote: Date? = nil,
        toAnnotationNote: Date? = nil) {
        self.accountNumber = accountNumber
        self.limit = limit
        self.offset = offset
        self.direction = direction
        self.fromDate = fromDate
        self.toDate = toDate
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        self.movementType = movementType?.rawValue
        self.operationCode = operationCode?.joined(separator: ",")
        self.concept = concept
        self.bankingOperation = bankingOperation
        self.basicOperation = basicOperation
        self.fromAnnotationNote = fromAnnotationNote
        self.toAnnotationNote = toAnnotationNote
    }
    
    enum CodingKeys: String, CodingKey {
        case accountNumber = "accountNumber"
        case limit = "limit"
        case offset = "offset"
        case direction = "direction"
        case fromDate = "from_date"
        case toDate = "to_date"
        case fromAmount = "from_amount"
        case toAmount = "to_amount"
        case movementType = "movement_type"
        case operationCode = "operation_code"
        case concept = "concept"
        case bankingOperation = "banking_operation"
        case basicOperation = "basic_operation"
        case fromAnnotationNote = "from_annotation_date"
        case toAnnotationNote = "to_annotation_date"
    }
}

extension AccountMovementListParams: DateParseable {
    public static var formats: [String: String] {
        return [
            "from_date": "yyyy-MM-dd",
            "to_date": "yyyy-MM-dd",
            "from_annotation_date": "yyyy-MM-dd",
            "to_annotation_date": "yyyy-MM-dd"
        ]
    }
}
