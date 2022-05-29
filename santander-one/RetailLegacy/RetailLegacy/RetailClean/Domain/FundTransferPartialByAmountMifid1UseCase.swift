import CoreFoundationLib
import SANLegacyLibrary

struct FundTransferPartialByAmountMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: MifidFundTransferPartialByAmountData
}

class FundTransferPartialByAmountMifid1UseCase: FundsTransferMifid1UseCase<FundTransferPartialByAmountMifid1UseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferPartialByAmountMifid1UseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferPartialByAmountMifid1UseCase: FundTransferPartialByAmountMifidClausesGetter {}
