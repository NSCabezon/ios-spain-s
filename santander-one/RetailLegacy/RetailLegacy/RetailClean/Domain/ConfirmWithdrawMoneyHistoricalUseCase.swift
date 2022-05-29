import CoreFoundationLib
import SANLegacyLibrary

class ConfirmWithdrawMoneyHistoricalUseCase: ConfirmUseCase<ConfirmWithdrawMoneyHistoricalUseCaseInput, ConfirmWithdrawMoneyHistoricalUseCaseOkOutput, ConfirmWithdrawMoneyHistoricalUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmWithdrawMoneyHistoricalUseCaseInput) throws -> UseCaseResponse<ConfirmWithdrawMoneyHistoricalUseCaseOkOutput, ConfirmWithdrawMoneyHistoricalUseCaseErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        
        let dispensationsResponse = try provider.getBsanCashWithdrawalManager().getHistoricalWithdrawal(cardDTO: cardDTO, signatureWithTokenDTO: signatureWithTokenDTO)
        guard dispensationsResponse.isSuccess(), let historicalData = try dispensationsResponse.getResponseData() else {
            let signatureResult = try getSignatureResult(dispensationsResponse)
            return UseCaseResponse.error(ConfirmWithdrawMoneyHistoricalUseCaseErrorOutput(try dispensationsResponse.getErrorMessage(), signatureResult, try dispensationsResponse.getErrorCode()))
        }
        let list = historicalData.dispensationList?.compactMap {
            Dispensation(dto: $0)
        }.filter { $0.pan == cardDTO.formattedPAN } ?? []
        return UseCaseResponse.ok(ConfirmWithdrawMoneyHistoricalUseCaseOkOutput(dispensationsList: DispensationsList(list: list)))
    }
}

struct ConfirmWithdrawMoneyHistoricalUseCaseInput {
    let card: Card
    let signatureWithToken: SignatureWithToken
}

struct ConfirmWithdrawMoneyHistoricalUseCaseOkOutput {
    let dispensationsList: DispensationsList
}

class ConfirmWithdrawMoneyHistoricalUseCaseErrorOutput: GenericErrorSignatureErrorOutput {
}
