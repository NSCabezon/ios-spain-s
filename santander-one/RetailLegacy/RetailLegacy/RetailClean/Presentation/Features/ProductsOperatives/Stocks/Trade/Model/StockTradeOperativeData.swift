enum StocksTradeOrder {
    case buy
    case sell
    
    var mifidOperative: MifidOperative {
        switch self {
        case .buy:
            return .stocksBuy
        case .sell:
            return .stocksSell
        }
    }
    
    var dto: String {
        switch self {
        case .buy:
            return "C"
        case .sell:
            return "V"
        }
    }
}

struct StockTradeData {
    let stock: StockBase
    let order: StocksTradeOrder
}

extension StockTradeData: OperativeParameter {}

struct SelectedTradingStockAccount {
    var stockAccount: StockAccount?
    let isStockAccountSelectedWhenCreated: Bool
    
    init(stockAccount: StockAccount? = nil) {
        self.stockAccount = stockAccount
        self.isStockAccountSelectedWhenCreated = stockAccount != nil
    }
}

extension SelectedTradingStockAccount: OperativeParameter {}
