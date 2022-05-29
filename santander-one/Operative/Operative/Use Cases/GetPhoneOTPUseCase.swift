import CoreFoundationLib
import SANLegacyLibrary

class GetPhoneOTPUseCase: UseCase<Void, GetPhoneOTPUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private var provider: BSANManagersProvider {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPhoneOTPUseCaseOkOutput, StringErrorOutput> {
        let response = try provider.getBsanOTPPushManager().requestDevice()
        if response.isSuccess() {
            guard let data = try response.getResponseData() else {
                return UseCaseResponse.ok(.not)
            }
            let model = data.deviceModel
            return UseCaseResponse.ok(.push(model: model))
        } else {
            let error = try response.getErrorCode()
            if error == "SUPOTE_000002" {
                let responseCMPS = try provider.getBsanSendMoneyManager().getCMPSStatus()
                guard responseCMPS.isSuccess(), let data = try responseCMPS.getResponseData(), let phone = data.otpPhoneDecrypted else {
                    return UseCaseResponse.ok(.not)
                }
                return UseCaseResponse.ok(.sms(phone: phone.trim()))
            } else {
                return UseCaseResponse.ok(.not)
            }
        }
    }
}

enum GetPhoneOTPUseCaseOkOutput {
    case not
    case push(model: String)
    case sms(phone: String)
}
