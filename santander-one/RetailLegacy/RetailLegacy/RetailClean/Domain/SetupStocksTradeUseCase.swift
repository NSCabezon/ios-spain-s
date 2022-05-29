import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class SetupStocksTradeUseCase: SetupUseCase<SetupStocksTradeUseCaseInput, SetupStocksTradeUseCaseOkOutput, SetupStocksTradeUseCaseErrorOutput> {
    
    let provider: BSANManagersProvider
    
    init(appConfig: AppConfigRepository, bsanManagerProvider: BSANManagersProvider) {
        self.provider = bsanManagerProvider
        super.init(appConfigRepository: appConfig)
    }
    
    override func executeUseCase(requestValues: SetupStocksTradeUseCaseInput) throws -> UseCaseResponse<SetupStocksTradeUseCaseOkOutput, SetupStocksTradeUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let stockAccountList: StockAccountList?
        if requestValues.stockAccount == nil {
            guard let rvNotManagedStockAccount = try checkRepositoryResponse(provider.getBsanPortfoliosPBManager().getRVNotManagedStockAccountList()) else {
                return UseCaseResponse.error(SetupStocksTradeUseCaseErrorOutput(nil))
            }
            guard let globalPosition = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) else {
                return UseCaseResponse.error(SetupStocksTradeUseCaseErrorOutput(nil))
            }
            stockAccountList = try selectableStockAccounts(globalPosition: globalPosition, notManagedStockAccounts: rvNotManagedStockAccount, order: requestValues.order, stockQuote: requestValues.stock.quoteDto)
        } else {
            stockAccountList = nil
        }
        
        return UseCaseResponse.ok(SetupStocksTradeUseCaseOkOutput(allowsOperative: true, stockAccountList: stockAccountList, operativeConfig: operativeConfig))
    }
    
    private func selectableStockAccounts(globalPosition: GlobalPositionDTO, notManagedStockAccounts: [StockAccountDTO], order: StocksTradeOrder, stockQuote: StockQuoteDTO) throws -> StockAccountList {
        var stockAccountsList: [StockAccountDTO] = []
        let stockAccountsDTOs = globalPosition.stockAccounts ?? []
        switch order {
        case .buy:
            stockAccountsList = stockAccountsDTOs
            stockAccountsList.append(contentsOf: notManagedStockAccounts)
        case .sell:
            var tempAccountDTOList = stockAccountsDTOs
            tempAccountDTOList.append(contentsOf: notManagedStockAccounts)
            stockAccountsList = try tempAccountDTOList.filter { stockAccountDTO in
                let response = try provider.getBsanStocksManager().getStocks(stockAccountDTO: stockAccountDTO, pagination: nil)
                guard response.isSuccess() else {
                    return false
                }
                let stocks = try response.getResponseData()
                let found = stocks?.stockListDTO?.firstIndex {
                    $0.sharesCount != nil && $0.sharesCount! > 0 && $0.stockQuoteDTO.getLocalId() == stockQuote.getLocalId()
                }
                return found != nil
            }
        }
        return StockAccountList.create(stockAccountsList, stockAccountType: .CCV)
    }
}

struct SetupStocksTradeUseCaseInput {
    let order: StocksTradeOrder
    var stockAccount: StockAccount?
    let stock: StockBase
}

struct SetupStocksTradeUseCaseOkOutput {
    let allowsOperative: Bool
    let stockAccountList: StockAccountList?
    var operativeConfig: OperativeConfig
}

extension SetupStocksTradeUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupStocksTradeUseCaseErrorOutput: StringErrorOutput {
    
}
