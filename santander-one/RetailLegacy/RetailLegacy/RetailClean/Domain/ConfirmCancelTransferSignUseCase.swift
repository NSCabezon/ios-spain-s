import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmCancelTransferSignUseCase: ConfirmUseCase<ConfirmCancelTransferSignUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCancelTransferSignUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        let scheduledTransfer = requestValues.scheduledTransfer
        let scheduledTransferDetail = requestValues.scheduledTransferDetail
        
        guard let ibanDto = scheduledTransferDetail.iban?.ibanDTO else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        
        let responseSignature = try provider.getBsanTransfersManager().removeScheduledTransfer(accountDTO: requestValues.account.accountDTO, orderIbanDTO: ibanDto, transferScheduledDTO: scheduledTransfer.transferDTO, signatureWithTokenDTO: signatureWithTokenDTO)
        
        if responseSignature.isSuccess() {
            return UseCaseResponse.ok()
        }
        
        let signatureType = try getSignatureResult(responseSignature)
        let errorDescription = try responseSignature.getErrorMessage() ?? ""
        let errorCode = try responseSignature.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmCancelTransferSignUseCaseInput {
    let account: Account
    let signatureWithToken: SignatureWithToken
    let scheduledTransfer: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
}
