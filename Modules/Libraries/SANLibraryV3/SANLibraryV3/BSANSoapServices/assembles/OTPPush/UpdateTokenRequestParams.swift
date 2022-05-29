//

import Foundation

public struct UpdateTokenRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let currentToken: String
    let newToken: String
}
