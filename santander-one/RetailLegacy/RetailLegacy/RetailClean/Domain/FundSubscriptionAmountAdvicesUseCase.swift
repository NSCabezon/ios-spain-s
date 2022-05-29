import CoreFoundationLib
import SANLegacyLibrary

struct MifidFundSubscriptionAmountData {
    let fund: Fund
    let amount: Amount
}

struct FundSubscriptionAmountAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: MifidFundSubscriptionAmountData
}

class FundSubscriptionAmountAdvicesUseCase: FundsSubscriptionMifidAdvicesUseCase<FundSubscriptionAmountAdvicesUseCaseInput> {
    override func getMifidResponse(requestValues: FundSubscriptionAmountAdvicesUseCaseInput) throws -> BSANResponse<FundSubscriptionDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundSubscriptionAmountAdvicesUseCase: FundSubscriptionAmountMifidClausesGetter {}

protocol FundSubscriptionAmountMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: MifidFundSubscriptionAmountData) throws -> BSANResponse<FundSubscriptionDTO>
}

extension FundSubscriptionAmountMifidClausesGetter {
    func getClauses(withParameters parameters: MifidFundSubscriptionAmountData) throws -> BSANResponse<FundSubscriptionDTO> {
        let fundDTO = parameters.fund.fundDTO
        let amountDTO = parameters.amount.amountDTO
        return try provider.getBsanFundsManager().validateFundSubscriptionAmount(fundDTO: fundDTO, amountDTO: amountDTO)
    }
}
