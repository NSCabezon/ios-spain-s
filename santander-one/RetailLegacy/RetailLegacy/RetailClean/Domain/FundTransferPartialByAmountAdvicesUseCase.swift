import CoreFoundationLib
import SANLegacyLibrary

struct MifidFundTransferPartialByAmountData {
    let originFund: Fund
    let destinationFund: Fund
    let amount: Amount
}

struct FundTransferPartialByAmountAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: MifidFundTransferPartialByAmountData
}

class FundTransferPartialByAmountAdvicesUseCase: FundsTransferMifidAdvicesUseCase<FundTransferPartialByAmountAdvicesUseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferPartialByAmountAdvicesUseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferPartialByAmountAdvicesUseCase: FundTransferPartialByAmountMifidClausesGetter {}

protocol FundTransferPartialByAmountMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: MifidFundTransferPartialByAmountData) throws -> BSANResponse<FundTransferDTO>
}

extension FundTransferPartialByAmountMifidClausesGetter {
    func getClauses(withParameters parameters: MifidFundTransferPartialByAmountData) throws -> BSANResponse<FundTransferDTO> {
        let originDTO = parameters.originFund.fundDTO
        let destinationDTO = parameters.destinationFund.fundDTO
        let amountDTO = parameters.amount.amountDTO
        return try provider.getBsanFundsManager().validateFundTransferPartialByAmount(originFundDTO: originDTO, destinationFundDTO: destinationDTO, amountDTO: amountDTO)
    }
}
