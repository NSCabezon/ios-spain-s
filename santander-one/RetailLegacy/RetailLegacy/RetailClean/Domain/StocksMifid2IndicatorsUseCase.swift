import CoreFoundationLib
import SANLegacyLibrary

struct StocksMifid2IndicatorsUseCaseInput: Mifid2IndicatorsUseCaseInputProtocol {
    let mifidOperative: MifidOperative
    let product: StockAccount
}

class StocksMifid2IndicatorsUseCase: Mifid2IndicatorsUseCase<StocksMifid2IndicatorsUseCaseInput> {
    override func getMifidResponse(requestValues: StocksMifid2IndicatorsUseCaseInput) throws -> BSANResponse<MifidIndicatorDTO>? {
        guard requestValues.mifidOperative != .stocksSell else {
            return nil
        }
        let stockAccountDTO = requestValues.product.stockAccountDTO
        
        guard let contract = stockAccountDTO.contract else {
            return nil
        }
        
        return try provider.getBsanMifidManager().getMifidIndicator(contractDTO: contract)
    }
}
