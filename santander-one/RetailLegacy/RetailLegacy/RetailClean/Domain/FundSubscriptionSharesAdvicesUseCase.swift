import CoreFoundationLib
import SANLegacyLibrary
import Foundation

struct MifidFundSubscriptionSharesData {
    let fund: Fund
    let shares: Decimal
}

struct FundSubscriptionSharesAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: MifidFundSubscriptionSharesData
}

class FundSubscriptionSharesAdvicesUseCase: FundsSubscriptionMifidAdvicesUseCase<FundSubscriptionSharesAdvicesUseCaseInput> {
    override func getMifidResponse(requestValues: FundSubscriptionSharesAdvicesUseCaseInput) throws -> BSANResponse<FundSubscriptionDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundSubscriptionSharesAdvicesUseCase: FundSubscriptionSharesMifidClausesGetter {}

protocol FundSubscriptionSharesMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: MifidFundSubscriptionSharesData) throws -> BSANResponse<FundSubscriptionDTO>
}

extension FundSubscriptionSharesMifidClausesGetter {
    func getClauses(withParameters parameters: MifidFundSubscriptionSharesData) throws -> BSANResponse<FundSubscriptionDTO> {
        let fundDTO = parameters.fund.fundDTO
        let shares = parameters.shares
        return try provider.getBsanFundsManager().validateFundSubscriptionShares(fundDTO: fundDTO, sharesNumber: shares)
    }
}
