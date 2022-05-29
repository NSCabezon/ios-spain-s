import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class ConfirmCancelTransferSignUseCase: UseCase<ConfirmCancelTransferSignUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let dependencies: DependenciesResolver

    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: ConfirmCancelTransferSignUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let scheduledTransferDetail = requestValues.scheduledTransferDetail
        
        guard let ibanDto = scheduledTransferDetail.iban?.dto else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        
        let transferManager = self.dependencies.resolve(for: BSANManagersProvider.self).getBsanTransfersManager()
        let signatureResponse = try transferManager.removeScheduledTransfer(
            accountDTO: requestValues.account.dto,
            orderIbanDTO: ibanDto,
            transferScheduledDTO: requestValues.scheduledTransfer.transferDTO,
            signatureWithTokenDTO: requestValues.signatureWithToken.signatureWithTokenDTO
        )

        if signatureResponse.isSuccess() {
            return .ok()
        }
        
        let signatureType = try processSignatureResult(signatureResponse)
        let errorDescription = try signatureResponse.getErrorMessage() ?? ""
        let errorCode = try signatureResponse.getErrorCode()
        return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmCancelTransferSignUseCaseInput {
    let account: AccountEntity
    let signatureWithToken: SignatureWithTokenEntity
    let scheduledTransfer: ScheduledTransferEntity
    let scheduledTransferDetail: ScheduledTransferDetailEntity
}
