import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class AddToApplePayConfirmationUseCase: UseCase<AddToApplePayConfirmationUseCaseInput, AddToApplePayConfirmationUseCaseOkOutput, StringErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: AddToApplePayConfirmationUseCaseInput) throws -> UseCaseResponse<AddToApplePayConfirmationUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = self.bsanManagersProvider.getBsanCardsManager()
        let response = try cardsManager.confirmApplePay(
            card: requestValues.card.dto,
            cardDetail: requestValues.detail.dto,
            otpValidation: requestValues.otpValidation.dto,
            otpCode: requestValues.otpCode,
            encryptionScheme: requestValues.encryptionScheme,
            publicCertificates: requestValues.publicCertificates,
            nonce: requestValues.nonce,
            nonceSignature: requestValues.nonceSignature
        )
        guard
            response.isSuccess(),
            let data = try response.getResponseData()
        else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        return .ok(AddToApplePayConfirmationUseCaseOkOutput(
            encryptedPassData: data.encryptedPassData,
            activationData: data.activationData,
            ephemeralPublicKey: data.ephemeralPublicKey,
            wrappedKey: data.wrappedKey)
        )
    }
}

struct AddToApplePayConfirmationUseCaseInput {
    let card: CardEntity
    let detail: CardDetailEntity
    let otpValidation: OTPValidationEntity
    let otpCode: String
    let encryptionScheme: String
    let publicCertificates: [Data]
    let nonce: Data
    let nonceSignature: Data
}

struct AddToApplePayConfirmationUseCaseOkOutput {
    let encryptedPassData: Data
    let activationData: Data
    let ephemeralPublicKey: Data
    let wrappedKey: Data?
}
