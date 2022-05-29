public struct CardBalanceDTO: Codable {

    public var creditLimitAmount: AmountDTO?
    public var currentBalance: AmountDTO?
    public var availableAmount: AmountDTO?
    public var prepaidBalance: AmountDTO?
    
    public init() {}
    
    public static func createFromCardSuperSpeedDTO(from: CardSuperSpeedDTO) -> CardBalanceDTO{
        var newCardBalance = CardBalanceDTO()
        newCardBalance.creditLimitAmount = from.creditLimitAmount
        newCardBalance.currentBalance = from.currentBalance
        newCardBalance.availableAmount = from.availableAmount
        
        return newCardBalance
    }
    
    public static func create(from: CardDetailDTO) -> CardBalanceDTO{
        var newCardBalance = CardBalanceDTO()
        newCardBalance.creditLimitAmount = from.creditLimitAmount
        newCardBalance.currentBalance = from.currentBalance
        newCardBalance.availableAmount = from.availableAmount

        return newCardBalance
    }

    public static func create(from: PrepaidCardDataDTO) -> CardBalanceDTO {
        var newCardBalance = CardBalanceDTO()
        newCardBalance.currentBalance = from.currentBalance

        return newCardBalance
    }
}
