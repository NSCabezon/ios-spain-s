import CoreFoundationLib
import SANLegacyLibrary
import Foundation

class PreValidateStocksTradeUseCase: BaseValidateStocksTradeUseCase<PreValidateStocksTradeUseCaseOkOutput, PreValidateStocksTradeUseCaseErrorOutput> {
    
    override func error(with errorString: String?) -> PreValidateStocksTradeUseCaseErrorOutput {
        return PreValidateStocksTradeUseCaseErrorOutput(errorString)
    }
}

struct PreValidateStocksTradeUseCaseOkOutput {
    let linkedAccountBalance: Amount?
    let limitDate: Date?
    let holder: String?
    let nameStock: String?
    let linkedAccountDescription: String?
    let contractDescription: String?
    let account: Account?
}

extension PreValidateStocksTradeUseCaseOkOutput: ValidateStocksTradeUseCaseOkOutputProtocol {
    init(data: StockDataBuySellDTO, account: Account?) {
        self.init(linkedAccountBalance: Amount.createFromDTO(data.linkedAccountBalance), limitDate: data.limitDate, holder: data.holder, nameStock: data.nameStock, linkedAccountDescription: data.linkedAccountDescription, contractDescription: data.descContract, account: account)
    }
}

class PreValidateStocksTradeUseCaseErrorOutput: StringErrorOutput {
}
