import CoreFoundationLib
import SANLegacyLibrary

struct MifidFundTransferTotalData {
    let originFund: Fund
    let destinationFund: Fund
}

struct FundTransferTotalAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: MifidFundTransferTotalData
}

class FundTransferTotalAdvicesUseCase: FundsTransferMifidAdvicesUseCase<FundTransferTotalAdvicesUseCaseInput> {
    override func getMifidResponse(requestValues: FundTransferTotalAdvicesUseCaseInput) throws -> BSANResponse<FundTransferDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension FundTransferTotalAdvicesUseCase: FundTransferTotalMifidClausesGetter {}

protocol FundTransferTotalMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: MifidFundTransferTotalData) throws -> BSANResponse<FundTransferDTO>
}

extension FundTransferTotalMifidClausesGetter {
    func getClauses(withParameters parameters: MifidFundTransferTotalData) throws -> BSANResponse<FundTransferDTO> {
        let originDTO = parameters.originFund.fundDTO
        let destinationDTO = parameters.destinationFund.fundDTO
        return try provider.getBsanFundsManager().validateFundTransferTotal(originFundDTO: originDTO, destinationFundDTO: destinationDTO)
    }
}
