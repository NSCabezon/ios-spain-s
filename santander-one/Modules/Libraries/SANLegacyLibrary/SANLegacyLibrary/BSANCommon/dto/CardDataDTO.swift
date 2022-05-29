public struct CardDataDTO: Codable, Hashable {
    public var PAN: String?
    public var visualCode: String?
    public var stampedName: String?
    public var creditLimitAmount: AmountDTO?
    public var currentBalance: AmountDTO?
    public var availableAmount: AmountDTO?
    public var description: String?
    public private(set) var cardSuperSpeedDTO: CardSuperSpeedDTO?
    public var dailyATMCurrentLimitAmount: AmountDTO? {
        return cardSuperSpeedDTO?.dailyCashierLimit
    }
    public var dailyATMMaximumLimitAmount: AmountDTO? {
        return cardSuperSpeedDTO?.maximumDailyCashierLimit
    }
    public var dailyCurrentLimitAmount: AmountDTO? {
        return cardSuperSpeedDTO?.dailyDebitLimit
    }
    public var dailyMaximumLimitAmount: AmountDTO? {
        return cardSuperSpeedDTO?.maximumDailyDebitLimit
    }
    
    public var currency: CurrencyDTO? {
        return availableAmount?.currency
    }
    
    public init() {}
    
    public static func == (lhs: CardDataDTO, rhs: CardDataDTO) -> Bool {
        guard let lhsPAN = lhs.PAN else {
            return false
        }
        guard let rhsPAN = rhs.PAN else {
            return false
        }
        return lhsPAN.replace(" ", "") == rhsPAN.replace(" ", "")
    }

    public func hash(into hasher: inout Hasher) {
        guard let PAN = PAN, let hash = Int(PAN) else { return hasher.combine(0) }
        return hasher.combine(hash)
    }
    
    public static func createFromCardSuperSpeedDTO(from: CardSuperSpeedDTO) -> CardDataDTO{
        var newCardDataDTO = CardDataDTO()
        newCardDataDTO.PAN = from.PAN
        newCardDataDTO.visualCode = from.visualCode
        newCardDataDTO.stampedName = from.stampingName
        newCardDataDTO.creditLimitAmount = from.creditLimitAmount
        newCardDataDTO.currentBalance = from.currentBalance
        newCardDataDTO.availableAmount = from.availableAmount
        newCardDataDTO.cardSuperSpeedDTO = from
        
        return newCardDataDTO
    }
}
