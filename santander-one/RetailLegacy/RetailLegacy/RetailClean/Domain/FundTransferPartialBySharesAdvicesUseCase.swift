import CoreFoundationLib
import SANLegacyLibrary
import Foundation

struct MifidFundTransferPartialBySharesData {
    let originFund: Fund
    let destinationFund: Fund
    let shares: Decimal
}

struct FundTransferPartialBySharesAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: MifidFundTransferPartialBySharesData
}

class FundTransferPartialBySharesAdvicesUseCase: FundsTransferMifidAdvicesUseCase<FundTransferPartialBySharesAdvicesUseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferPartialBySharesAdvicesUseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferPartialBySharesAdvicesUseCase: FundTransferPartialBySharesMifidClausesGetter {}

protocol FundTransferPartialBySharesMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: MifidFundTransferPartialBySharesData) throws -> BSANResponse<FundTransferDTO>
}

extension FundTransferPartialBySharesMifidClausesGetter {
    func getClauses(withParameters parameters: MifidFundTransferPartialBySharesData) throws -> BSANResponse<FundTransferDTO> {
        let originDTO = parameters.originFund.fundDTO
        let destinationDTO = parameters.destinationFund.fundDTO
        let shares = parameters.shares
        return try provider.getBsanFundsManager().validateFundTransferPartialByShares(originFundDTO: originDTO, destinationFundDTO: destinationDTO, sharesNumber: shares)
    }
}
