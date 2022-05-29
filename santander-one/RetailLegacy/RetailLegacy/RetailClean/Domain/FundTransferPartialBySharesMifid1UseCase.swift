import CoreFoundationLib
import SANLegacyLibrary

struct FundTransferPartialBySharesMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: MifidFundTransferPartialBySharesData
}

class FundTransferPartialBySharesMifid1UseCase: FundsTransferMifid1UseCase<FundTransferPartialBySharesMifid1UseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferPartialBySharesMifid1UseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferPartialBySharesMifid1UseCase: FundTransferPartialBySharesMifidClausesGetter {}
