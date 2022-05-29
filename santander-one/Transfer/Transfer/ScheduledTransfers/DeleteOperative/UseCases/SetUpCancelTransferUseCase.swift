import CoreFoundationLib
import SANLegacyLibrary
import Operative

final class SetUpCancelTransferUseCase: UseCase<Void, SetUpCancelTransferUseCaseOkOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
        
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetUpCancelTransferUseCaseOkOutput, StringErrorOutput> {
        let signatureManager = self.dependencies.resolve(for: BSANManagersProvider.self).getBsanSignatureManager()
        let response = try signatureManager.consultScheduledSignaturePositions()
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        let signatureWithToken = SignatureWithTokenDTO(signatureDTO: dto.signatureDTO, magicPhrase: dto.magicPhrase)
        return .ok(SetUpCancelTransferUseCaseOkOutput(signatureWithToken: SignatureWithTokenEntity(signatureWithToken),
                                                      predefinedSCA: .signature))
    }
}

struct SetUpCancelTransferUseCaseInput {
    let scheduledTransfer: ScheduledTransferEntity?
    let destAccount: AccountEntity
    let originAccount: AccountEntity
}

struct SetUpCancelTransferUseCaseOkOutput {
    public let signatureWithToken: SignatureWithTokenEntity?
    public let predefinedSCA: PredefinedSCAEntity?
}
