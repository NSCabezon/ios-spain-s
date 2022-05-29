import CoreFoundationLib
import SANLegacyLibrary

class GetSecureDevicePhoneUseCase: UseCase<Void, GetSecureDevicePhoneUseCaseOkOutput, StringErrorOutput> {
    private var provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSecureDevicePhoneUseCaseOkOutput, StringErrorOutput> {
        let responseCMPS = try provider.getBsanSendMoneyManager().getCMPSStatus()
        guard responseCMPS.isSuccess(), let data = try responseCMPS.getResponseData(), let phone = data.otpPhoneDecrypted else {
            return UseCaseResponse.ok(.not)
        }
        return UseCaseResponse.ok(.sms(phone: phone.trim()))
    }
}

enum GetSecureDevicePhoneUseCaseOkOutput {
    case not
    case sms(phone: String)
}
