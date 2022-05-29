import Foundation

struct StocksTradePreValidateData {
    let linkedAccountBalance: Amount?
    let limitDate: Date?
    let owner: String?
    let linkedAccountDescription: String?
    let account: Account?
}

extension StocksTradePreValidateData: OperativeParameter {}
