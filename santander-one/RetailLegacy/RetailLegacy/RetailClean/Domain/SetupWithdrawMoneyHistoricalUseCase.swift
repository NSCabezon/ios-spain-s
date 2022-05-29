import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupWithdrawMoneyHistoricalUseCase: SetupUseCase<Void, SetupWithdrawMoneyHistoricalUseCaseOkOutput, SetupWithdrawMoneyHistoricalUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupWithdrawMoneyHistoricalUseCaseOkOutput, SetupWithdrawMoneyHistoricalUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let response = try provider.getBsanSignatureManager().consultCashWithdrawalSignaturePositions()
        
        guard response.isSuccess(), let dto = try response.getResponseData(), let signatureWithToken = SignatureWithToken(dto: dto) else {
            return UseCaseResponse.error(SetupWithdrawMoneyHistoricalUseCaseErrorOutput(try response.getErrorMessage()))
        }
        return UseCaseResponse.ok(SetupWithdrawMoneyHistoricalUseCaseOkOutput(operativeConfig: operativeConfig, signatureWithToken: signatureWithToken))
    }
}

struct SetupWithdrawMoneyHistoricalUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let signatureWithToken: SignatureWithToken
}

extension SetupWithdrawMoneyHistoricalUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupWithdrawMoneyHistoricalUseCaseErrorOutput: StringErrorOutput {
}
