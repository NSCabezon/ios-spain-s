//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmLocalTransferUseCase: ConfirmUseCase<ConfirmLocalTransferUseCaseInput, ConfirmLocalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmLocalTransferUseCaseInput) throws -> UseCaseResponse<ConfirmLocalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
        let originAccountDTO = requestValues.originAccount.accountDTO
        let destinationAccountDTO = requestValues.destinationAccount.accountDTO
        let amountDTO = requestValues.amount.amountDTO
        let concept = requestValues.concept
        let signatureDTO = requestValues.signature.dto
        
        switch requestValues.transferTime {
        case .now:
            let response = try provider.getBsanTransfersManager().confirmAccountTransfer(originAccountDTO: originAccountDTO, destinationAccountDTO: destinationAccountDTO, accountTransferInput: AccountTransferInput(amountDTO: amountDTO, concept: concept), signatureDTO: signatureDTO)
            if response.isSuccess() {
                return UseCaseResponse.ok(ConfirmLocalTransferUseCaseOkOutput(otp: nil))
            }
            
            let signatureType = try getSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
            
        case .day:
            let strategy = NationalDeferredTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: self.trusteerRepository, dependenciesResolver: self.dependenciesResolver)
             guard let iban = requestValues.destinationAccount.getIban(), let scheduledTransfer = requestValues.scheduledTransfer else {
                return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
             }
             
             let input = ConfirmOnePayTransferUseCaseInput(
                signature: requestValues.signature,
                type: .national,
                originAccount: requestValues.originAccount,
                amount: requestValues.amount,
                beneficiary: "",
                isSpanishResident: true,
                iban: iban,
                saveAsUsual: false,
                concept: requestValues.concept,
                saveAsUsualAlias: nil,
                beneficiaryMail: nil,
                time: requestValues.transferTime,
                dataMagicPhrase: scheduledTransfer.dataMagicPhrase
             )
            
             let response = try  strategy.confirmTransfer(requestValues: input)
             guard response.isOkResult else {
                return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
             }
            
             let responseData = try response.getOkResult()
             let confirmLocalTransferUseCaseOkOutput = ConfirmLocalTransferUseCaseOkOutput(otp: responseData.otp)
             return UseCaseResponse.ok(confirmLocalTransferUseCaseOkOutput)
            
        case .periodic:
            let strategy = NationalPeriodicTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
            guard let iban = requestValues.destinationAccount.getIban(), let scheduledTransfer = requestValues.scheduledTransfer else {
                return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
            }
            
            let input = ConfirmOnePayTransferUseCaseInput(
                signature: requestValues.signature,
                type: .national,
                originAccount: requestValues.originAccount,
                amount: requestValues.amount,
                beneficiary: "",
                isSpanishResident: true,
                iban: iban,
                saveAsUsual: false,
                concept: requestValues.concept,
                saveAsUsualAlias: nil,
                beneficiaryMail: nil,
                time: requestValues.transferTime,
                dataMagicPhrase: scheduledTransfer.dataMagicPhrase
            )
            
            let response = try strategy.confirmTransfer(requestValues: input)
            guard response.isOkResult else {
                return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
            }
            
            let responseData = try response.getOkResult()
            let confirmLocalTransferUseCaseOkOutput = ConfirmLocalTransferUseCaseOkOutput(otp: responseData.otp)
            return UseCaseResponse.ok(confirmLocalTransferUseCaseOkOutput)
        }
    }
}

struct ConfirmLocalTransferUseCaseInput {
    let originAccount: Account
    let destinationAccount: Account
    let amount: Amount
    let concept: String
    let signature: Signature
    let transferTime: OnePayTransferTime
    let scheduledTransfer: ScheduledTransfer?
}

struct ConfirmLocalTransferUseCaseOkOutput {
    let otp: OTP?
}
