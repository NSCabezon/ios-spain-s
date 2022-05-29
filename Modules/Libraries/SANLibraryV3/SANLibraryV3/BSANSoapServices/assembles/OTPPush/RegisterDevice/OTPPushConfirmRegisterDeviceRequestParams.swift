//

import Foundation

struct OTPPushConfirmRegisterDeviceRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let deviceUDID: String
    let deviceToken: String
    let deviceAlias: String?
    let deviceLanguage: String
    let deviceCode: String
    let deviceModel: String
    let deviceBrand: String
    let appVersion: String
    let sdkVersion: String
    let soVersion: String
    let platform: String
    let modUser: String
    let operativeDes: String
    let stepToken: String
    let ticket: String
    let otpCode: String
}
