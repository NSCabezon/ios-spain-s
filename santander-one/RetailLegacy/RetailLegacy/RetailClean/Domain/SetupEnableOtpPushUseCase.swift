import SANLegacyLibrary
import CoreFoundationLib


class SetupEnableOtpPushUseCase: SetupUseCase<SetupEnableOtpPushUseCaseInput, SetupEnableOtpPushUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupEnableOtpPushUseCaseInput) throws -> UseCaseResponse<SetupEnableOtpPushUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let operativeMode: EnableOTPPushOperativeMode
        if let isAnyDeviceRegistered = requestValues.isAnyDeviceRegistered {
            operativeMode = isAnyDeviceRegistered ? .update: .registration
        } else {
            let response = try bsanManagersProvider.getBsanOTPPushManager().requestDevice()
            if response.isSuccess(), try response.getResponseData() != nil {
                operativeMode = .update
            } else {
                operativeMode = .registration
            }
        }
        return UseCaseResponse.ok(SetupEnableOtpPushUseCaseOkOutput(operativeConfig: operativeConfig, operativeMode: operativeMode))
    }
}

struct SetupEnableOtpPushUseCaseInput {
    let isAnyDeviceRegistered: Bool?
}

struct SetupEnableOtpPushUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    let operativeMode: EnableOTPPushOperativeMode
}
