import CoreFoundationLib
import SANLegacyLibrary

struct FundSubscriptionAmountMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: MifidFundSubscriptionAmountData
}

class FundSubscriptionAmountMifid1UseCase: FundsSubscriptionMifid1UseCase<FundSubscriptionAmountMifid1UseCaseInput> {
    override func getMifidResponse(requestValues: FundSubscriptionAmountMifid1UseCaseInput) throws -> BSANResponse<FundSubscriptionDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundSubscriptionAmountMifid1UseCase: FundSubscriptionAmountMifidClausesGetter {}
