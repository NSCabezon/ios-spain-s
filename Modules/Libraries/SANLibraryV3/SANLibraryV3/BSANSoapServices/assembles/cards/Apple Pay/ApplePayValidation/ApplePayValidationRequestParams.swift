import Foundation

struct ApplePayValidationRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let signature: SignatureWithTokenDTO
    let card: CardDTO
    let linkedCompany: String
}
