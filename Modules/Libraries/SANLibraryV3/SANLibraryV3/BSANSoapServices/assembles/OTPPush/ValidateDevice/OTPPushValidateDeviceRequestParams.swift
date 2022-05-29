//

import Foundation

struct OTPPushValidateDeviceRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let languageISO: String
    let dialectISO: String
    let deviceToken: String
}
