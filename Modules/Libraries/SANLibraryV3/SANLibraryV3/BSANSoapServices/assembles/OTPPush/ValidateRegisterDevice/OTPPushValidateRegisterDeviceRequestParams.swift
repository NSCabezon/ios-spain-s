//

import Foundation

struct OTPPushValidateRegisterDeviceRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let signature: SignatureWithTokenDTO
}
