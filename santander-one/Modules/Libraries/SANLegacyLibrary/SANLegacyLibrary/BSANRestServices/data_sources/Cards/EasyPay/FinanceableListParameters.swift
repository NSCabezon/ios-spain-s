public struct FinanceableListParameters {
    public let pan: String
    public let isEasyPay: Bool
    public let isElegibleFinancing: Bool
    public var dateFrom: String?
    public var dateTo: String?
    
    public init(pan: String,
                isEasyPay: Bool,
                isElegibleFinancing: Bool,
                dateFrom: String?,
                dateTo: String?) {
        self.pan = pan
        self.isEasyPay = isEasyPay
        self.isElegibleFinancing = isElegibleFinancing
        self.dateTo = dateTo
        self.dateFrom = dateFrom
    }
}
