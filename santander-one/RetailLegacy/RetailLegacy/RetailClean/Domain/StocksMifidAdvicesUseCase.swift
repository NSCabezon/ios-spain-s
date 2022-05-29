import CoreFoundationLib
import SANLegacyLibrary

extension MifidDTO: MifidAdvicesResponsePrototocol {
    var advice: MifidAdviceProtocol? {
        return mifidAdviceDTO
    }
}

struct StockMifidClausesParamenters {
    let stockAccount: StockAccount
    let stockTradeData: StockTradeData
    let tradeType: StocksTradeOrder
    let configuration: OrderTitlesAndDateConfiguration
}

struct StocksMifidAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: StockMifidClausesParamenters
}

class StocksMifidAdvicesUseCase: MifidAdvicesUseCase<StocksMifidAdvicesUseCaseInput, MifidDTO> {
    override func getMifidResponse(requestValues: StocksMifidAdvicesUseCaseInput) throws -> BSANResponse<MifidDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension StocksMifidAdvicesUseCase: StocksMifidClausesGetter {}

protocol StocksMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: StockMifidClausesParamenters) throws -> BSANResponse<MifidDTO>
}

extension StocksMifidClausesGetter {
    func getClauses(withParameters parameters: StockMifidClausesParamenters) throws -> BSANResponse<MifidDTO> {
        let stockAccountDTO = parameters.stockAccount.stockAccountDTO
        let stockQuoteDTO = parameters.stockTradeData.stock.quoteDto
        let sharesCount = parameters.configuration.numberOfTitlesValue
        let transferMode = parameters.tradeType.dto
        return try provider.getBsanMifidManager().getMifidClauses(stockAccountDTO: stockAccountDTO,
                                                                   stockQuoteDTO: stockQuoteDTO,
                                                                   tradedSharesCount: sharesCount,
                                                                   transferMode: transferMode)
    }
}
