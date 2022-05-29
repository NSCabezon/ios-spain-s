import CoreFoundationLib
import SANLegacyLibrary
import Transfer

final class SpainConfirmDeleteFavouriteUseCase: UseCase<ConfirmDeleteFavouriteUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: ConfirmDeleteFavouriteUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let provider: BSANManagersProvider = self.dependencies.resolve(for: BSANManagersProvider.self)
        guard let signatureWithToken = requestValues.signatureWithToken
        else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        guard let signature = signatureWithToken.signature as? SignatureDTO else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signature, magicPhrase: signatureWithToken.magicPhrase)
        let response = try provider.getBsanTransfersManager().confirmRemoveSepaPayee(payeeId: nil, signatureWithTokenDTO: signatureWithTokenDTO)
        let signatureType = try processSignatureResult(response)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorDescription))
        }
        return UseCaseResponse.ok()
    }
}

extension SpainConfirmDeleteFavouriteUseCase: ConfirmDeleteFavouriteUseCaseProtocol {}
