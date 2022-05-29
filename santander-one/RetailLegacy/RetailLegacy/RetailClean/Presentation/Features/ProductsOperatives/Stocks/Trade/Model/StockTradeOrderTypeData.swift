enum StockTradeOrderType {
    case toMarket
    case byBest
    case byLimitation(amount: String)
    
    var dto: String {
        switch self {
        case .toMarket:
            return "4"
        case .byBest:
            return "0"
        case .byLimitation:
            return "1"
        }
    }
    
    func localizedTitle(with stringLoader: StringLoader) -> LocalizedStylableText {
        switch self {
        case .toMarket:
            return stringLoader.getString("buySale_radiobuton_toMarket")
        case .byBest:
            return stringLoader.getString("buySale_radiobuton_atBest")
        case .byLimitation:
            return stringLoader.getString("buySale_radiobuton_limited")
        }
    }
    
    func radioOrderTypeItemType(with stringLoader: StringLoader) -> OrderTypeItemType {
        switch self {
        case .toMarket:
            return .empty
        case .byBest:
            return .empty
        case .byLimitation(let value):
            return .amount(placeholder: .empty, value: value)
        }
    }
    
    func tooltip(with stringLoader: StringLoader) -> (title: LocalizedStylableText, description: LocalizedStylableText) {
        let titleKey: String
        let descriptionKey: String
        switch self {
        case .toMarket:
            titleKey = "buySale_tooltipTitle_toMarket"
            descriptionKey = "buySale_tooltip_toMarket"
        case .byBest:
            titleKey = "buySale_tooltipTitle_atBest"
            descriptionKey = "buySale_tooltip_atBest"
        case .byLimitation:
            titleKey = "buySale_tooltipTitle_limited"
            descriptionKey = "buySale_tooltip_limited"
        }
        return (title: stringLoader.getString(titleKey), description: stringLoader.getString(descriptionKey))
    }
}

extension StockTradeOrderType: OperativeParameter {}
