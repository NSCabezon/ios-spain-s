import CoreFoundationLib
import SANLegacyLibrary

struct FundSubscriptionSharesMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: MifidFundSubscriptionSharesData
}

class FundSubscriptionSharesMifid1UseCase: FundsSubscriptionMifid1UseCase<FundSubscriptionSharesMifid1UseCaseInput> {
    override func getMifidResponse(requestValues: FundSubscriptionSharesMifid1UseCaseInput) throws -> BSANResponse<FundSubscriptionDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundSubscriptionSharesMifid1UseCase: FundSubscriptionSharesMifidClausesGetter {}
