import CoreFoundationLib
import SANLegacyLibrary

struct FundsMifid2IndicatorsUseCaseInput: Mifid2IndicatorsUseCaseInputProtocol {
    let mifidOperative: MifidOperative
    let product: Fund
}

class FundsMifid2IndicatorsUseCase: Mifid2IndicatorsUseCase<FundsMifid2IndicatorsUseCaseInput> {
    override func getMifidResponse(requestValues: FundsMifid2IndicatorsUseCaseInput) throws -> BSANResponse<MifidIndicatorDTO>? {
        let fundDTO = requestValues.product.fundDTO
        
        guard let contract = fundDTO.contract else {
            return nil
        }
        
        return try provider.getBsanMifidManager().getMifidIndicator(contractDTO: contract)
    }
}
