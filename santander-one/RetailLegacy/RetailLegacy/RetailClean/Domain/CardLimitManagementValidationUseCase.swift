import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class CardLimitManagementValidationUseCase: UseCase<Void, CardLimitManagementValidationUseCaseOkOutput, StringErrorOutput> {
    
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<CardLimitManagementValidationUseCaseOkOutput, StringErrorOutput> {
        let response = try bsanManagerProvider.getBsanSignatureManager().consultCardLimitManagementPositions()
        guard response.isSuccess(), let signatureWithTokenDTO = try response.getResponseData(), let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) else {
            let error = try response.getErrorMessage()
            return .error(StringErrorOutput(error))
        }
        return .ok(CardLimitManagementValidationUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct CardLimitManagementValidationUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
