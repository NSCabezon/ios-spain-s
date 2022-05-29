import Foundation

public struct PortfolioProductDTO: Codable{
    public var alias: String?
    public var accountDesc: String?
    public var portfolioId: String?
    public var portfolioTypeInd: String?
    public var portfolioTypeDesc: String?
    
    public var valueName: String?
    public var activeType: String?
    public var portfolioBlock: String?
    public var portfolioBlockDesc: String?
    public var priceValue: Decimal?
    
    public var countervalueAmount: AmountDTO?
    public var countervalueCoinAmount: AmountDTO?
    public var impUltSaldoConsolidado: AmountDTO?
    public var cashAmount: AmountDTO?
    public var variationAmount: AmountDTO?
    public var netAssetValue: AmountDTO?
    
    public var stockAccountData: AccountDataDTO?

    public init() {}
}
