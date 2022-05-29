import CoreFoundationLib
import SANLegacyLibrary
import UIKit

class ConfirmOTPEnableOtpPushUseCase: UseCase<ConfirmOTPEnableOtpPushUseCaseInput, ConfirmOTPEnableOtpPushUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ConfirmOTPEnableOtpPushUseCaseInput) throws -> UseCaseResponse<ConfirmOTPEnableOtpPushUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let notificationProvider = self.dependenciesResolver.resolve(forOptionalType: NotificationDeviceInfoProvider.self)
        let deviceUDID = notificationProvider?.getDeviceUDID() ?? ""
        let deviceToken = requestValues.tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        let alias = requestValues.alias ?? ""
        let deviceLanguage = requestValues.language.languageType.trackerId
        let deviceCode = UIDevice.current.machineName
        let deviceModel = UIDevice.current.model
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let sdkVersion = notificationProvider?.getVersionNumber() ?? ""
        let iOSVersion = UIDevice.current.systemVersion
        
        let deviceInfo = OTPPushConfirmRegisterDeviceInputDTO(deviceUDID: deviceUDID, deviceToken: deviceToken, deviceAlias: alias, deviceLanguage: deviceLanguage, deviceCode: deviceCode, deviceModel: deviceModel, appVersion: appVersion, sdkVersion: sdkVersion, soVersion: iOSVersion)
        
        let otpValidationDto = requestValues.otpValidation.otpValidationDTO
        let otpCode = requestValues.otpCode
        let response = try provider.getBsanOTPPushManager().registerDevice(otpValidation: otpValidationDto, otpCode: otpCode, data: deviceInfo)
        
        if response.isSuccess(), let responseData = try response.getResponseData(), let deviceId = responseData.deviceId {
            return .ok(ConfirmOTPEnableOtpPushUseCaseOkOutput(deviceModel: deviceModel, deviceId: deviceId))
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

struct ConfirmOTPEnableOtpPushUseCaseInput {
    let alias: String?
    let language: Language
    let otpValidation: OTPValidation
    let otpCode: String
    let tokenPush: Data
}

struct ConfirmOTPEnableOtpPushUseCaseOkOutput {
    let deviceModel: String
    let deviceId: String
}
