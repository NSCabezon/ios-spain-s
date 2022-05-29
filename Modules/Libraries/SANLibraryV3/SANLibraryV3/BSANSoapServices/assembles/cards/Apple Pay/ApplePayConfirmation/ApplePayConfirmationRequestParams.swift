//

import Foundation

struct ApplePayConfirmationRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let card: CardDTO
    let cardDetail: CardDetailDTO
    let otpValidation: OTPValidationDTO
    let otpCode: String
    let encryptionScheme: String
    let publicCertificates: [Data]
    let nonce: Data
    let nonceSignature: Data
    let linkedCompany: String
}
