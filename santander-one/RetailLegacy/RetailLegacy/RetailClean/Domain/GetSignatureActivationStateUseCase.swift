import SANLegacyLibrary
import CoreFoundationLib

class GetSignatureActivationStateUseCase: UseCase<Void, GetSignatureActivationStateUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSignatureActivationStateUseCaseOkOutput, StringErrorOutput> {
        let signatureInfo = try provider.getBsanSignatureManager().getCMCSignature()
        guard signatureInfo.isSuccess(),
            let data = try signatureInfo.getResponseData() else {
                return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let signatureData = SignatureData(signatureDataDTO: data.signatureDataDTO)
        let isSignatureActivationPending = signatureData.isSignatureActivationPending()
        let output = GetSignatureActivationStateUseCaseOkOutput(isSignatureActivationPending: isSignatureActivationPending)
        return UseCaseResponse.ok(output)
    }
}

struct GetSignatureActivationStateUseCaseOkOutput {
    let isSignatureActivationPending: Bool
}
