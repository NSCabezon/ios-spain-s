import SANLegacyLibrary

public protocol CardSubscriptionEntityRepresentable {
    var providerName: String { get }
    var amount: AmountEntity? { get }
    var date: Date? { get }
    var active: Bool { get }
    var formattedPAN: String? { get }
    var lastStateChangeDate: Date? { get }
    var instaId: String? { get }
    var isFractionable: Bool { get }
    var creditMovementNum: String? { get }
    var creditExtractNum: String? { get }
}

public struct CardSubscriptionEntity: CardSubscriptionEntityRepresentable {
    private let dto: CardSubscriptionDTO
    public init(dto: CardSubscriptionDTO) {
        self.dto = dto
    }
    
    public var providerName: String {
        return dto.providerName?.trim() ?? ""
    }
    
    public var amount: AmountEntity? {
        guard let optionalStringAmount = dto.value,
              let amount = Decimal(string: optionalStringAmount)
        else { return nil }
        return AmountEntity(value: amount)
    }
    
    public var date: Date? {
        guard let optionalStringDate = dto.lastUseDate else { return nil }
        return DateFormats.toDate(string: optionalStringDate, output: .YYYYMMDD)
    }
    
    public var active: Bool {
        guard
            let optionalStringState = dto.subscriptionStatus?.rawValue.lowercased()
        else { return false }
        return optionalStringState == "act"
    }
    
    public var formattedPAN: String? {
        return dto.pan?.trim()
    }
    
    public var lastStateChangeDate: Date? {
        guard let optionalStringDate = dto.lastStateChangeDate else {
            return nil
        }
        let lastStateChangeDate = DateFormats.toDate(string: optionalStringDate, output: .YYYYMMDD)
        return lastStateChangeDate
    }
    
    public var instaId: String? {
        return dto.instaId?.trim()
    }
    public var isFractionable: Bool {
        dto.isFractionable
    }
    
    public var creditMovementNum: String? {
        dto.creditMovementNum
    }
    
    public var creditExtractNum: String? {
        dto.creditExtractNum
    }
}
