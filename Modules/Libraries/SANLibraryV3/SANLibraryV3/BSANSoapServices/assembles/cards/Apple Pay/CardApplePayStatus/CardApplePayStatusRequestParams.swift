import CoreDomain
import Foundation

struct CardApplePayStatusRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let card: CardDTO
    let expirationDate: DateModel
}
