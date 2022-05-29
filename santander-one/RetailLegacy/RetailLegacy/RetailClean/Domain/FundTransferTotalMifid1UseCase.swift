import CoreFoundationLib
import SANLegacyLibrary

struct FundTransferTotalMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: MifidFundTransferTotalData
}

class FundTransferTotalMifid1UseCase: FundsTransferMifid1UseCase<FundTransferTotalMifid1UseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferTotalMifid1UseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferTotalMifid1UseCase: FundTransferTotalMifidClausesGetter {}
