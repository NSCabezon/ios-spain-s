import CoreFoundationLib
import SANLegacyLibrary

extension PensionMifidDTO: MifidAdvicesResponsePrototocol {
    var advice: MifidAdviceProtocol? {
        return self
    }
}

extension PensionMifidDTO: MifidAdviceProtocol {
    var title: String? {
        return adviceTitle
    }
    var message: String? {
        return adviceMessage
    }
    var resultCode: String? {
        return adviceResultCode
    }
    var evaluationResultCode: String? {
        return mifidEvaluationResultCode
    }
}

struct PensionMifidClausesParamenters {
    let pension: Pension
    let infoOperation: PensionInfoOperation
    let amount: Amount
    let advices: PensionMifidDTO?
}

struct PensionsMifidAdvicesUseCaseInput: MifidAdvicesUseCaseInputProtocol {
    let data: PensionMifidClausesParamenters
}

class PensionsMifidAdvicesUseCase: MifidAdvicesUseCase<PensionsMifidAdvicesUseCaseInput, PensionMifidDTO> {
    override func getMifidResponse(requestValues: PensionsMifidAdvicesUseCaseInput) throws -> BSANResponse<PensionMifidDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension PensionsMifidAdvicesUseCase: PensionMifidClausesGetter {}

protocol PensionMifidClausesGetter {
    var provider: BSANManagersProvider { get }
    func getClauses(withParameters parameters: PensionMifidClausesParamenters) throws -> BSANResponse<PensionMifidDTO>
}

extension PensionMifidClausesGetter {
    func getClauses(withParameters parameters: PensionMifidClausesParamenters) throws -> BSANResponse<PensionMifidDTO> {
        if let advices = parameters.advices {
            return BSANOkResponse(advices)
        } else {
            let pensionDTO = parameters.pension.pensionDTO
            let infoOperationDTO = parameters.infoOperation.pensionInfoOperationDTO
            let amountDTO = parameters.amount.amountDTO
            return try provider.getBsanPensionsManager().getClausesPensionMifid(pensionDTO: pensionDTO, pensionInfoOperationDTO: infoOperationDTO, amountDTO: amountDTO)
        }
    }
}
