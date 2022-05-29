import CoreFoundationLib
import SANLegacyLibrary

struct PensionsMifid2IndicatorsUseCaseInput: Mifid2IndicatorsUseCaseInputProtocol {
    let mifidOperative: MifidOperative
    let product: Void
    
    init(mifidOperative: MifidOperative) {
        self.mifidOperative = mifidOperative
    }
}

class PensionsMifid2IndicatorsUseCase: Mifid2IndicatorsUseCase<PensionsMifid2IndicatorsUseCaseInput> {
    override func getMifidResponse(requestValues: PensionsMifid2IndicatorsUseCaseInput) throws -> BSANResponse<MifidIndicatorDTO>? {
        return nil
    }
}
