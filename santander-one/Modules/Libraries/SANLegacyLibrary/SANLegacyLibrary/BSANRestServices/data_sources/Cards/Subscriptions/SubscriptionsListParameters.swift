public struct SubscriptionsListParameters {
    public let pan: String?
    public let dateFrom: String
    public let dateTo: String
    public let clientType: String
    public let clientCode: String
    public init(pan: String?,
                clientType: String,
                clientCode: String,
                dateFrom: String,
                dateTo: String) {
        self.pan = pan
        self.clientType = clientType
        self.clientCode = clientCode
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}
