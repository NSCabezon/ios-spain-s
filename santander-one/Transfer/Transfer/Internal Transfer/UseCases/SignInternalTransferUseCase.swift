import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class SignInternalTransferUseCase: UseCase<SignInternalTransferUseCaseInput, SignInternalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SignInternalTransferUseCaseInput) throws -> UseCaseResponse<SignInternalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature as? SignatureDTO else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let originAccountDTO = requestValues.originAccount.dto
        let destinationAccountDTO = requestValues.destinationAccount.dto
        let amountDTO = requestValues.amount.dto
        let concept = requestValues.concept
        let signatureDTO = requestValues.signature
        
        let response = try self.provider.getBsanTransfersManager().confirmAccountTransfer(originAccountDTO: originAccountDTO, destinationAccountDTO: destinationAccountDTO, accountTransferInput: AccountTransferInput(amountDTO: amountDTO, concept: concept), signatureDTO: signature, trusteerInfo: self.trusteerInfo)
        if response.isSuccess() {
            return .ok(SignInternalTransferUseCaseOkOutput(otp: nil))
        }
        
        let signatureType = try processSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

private extension SignInternalTransferUseCase {

    var trusteerInfo: TrusteerInfoDTO? {
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        guard
            let appSessionId = self.dependenciesResolver.resolve(for: TrusteerRepositoryProtocol.self).appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfers) == true
        else {
            return nil
        }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfigRepository)
    }
}

struct SignInternalTransferUseCaseInput {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String
    let signature: SignatureRepresentable
    let transferTime: TransferTime
}

struct SignInternalTransferUseCaseOkOutput {
    let otp: OTPValidationEntity?
}
