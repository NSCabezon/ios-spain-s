import CoreFoundationLib
import SANLegacyLibrary

final class ValidateOTPPushDeviceUseCase: UseCase<ValidateOTPPushDeviceUseCaseInput, ValidateOTPPushDeviceUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: ValidateOTPPushDeviceUseCaseInput) throws -> UseCaseResponse<ValidateOTPPushDeviceUseCaseOkOutput, StringErrorOutput> {
        let deviceToken = requestValues.deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let response = try bsanManagerProvider.getBsanOTPPushManager().validateDevice(deviceToken: deviceToken)
        
        if response.isSuccess(), let data = try? response.getResponseData(), let returnCode = data.returnCode {
            return .ok(ValidateOTPPushDeviceUseCaseOkOutput(returnCode: CoreFoundationLib.ReturnCodeOTPPush(returnCode.rawValue)))
        }
        return .error(StringErrorOutput(nil))
    }
}

struct ValidateOTPPushDeviceUseCaseInput {
    let deviceToken: Data
}

struct ValidateOTPPushDeviceUseCaseOkOutput {
    let returnCode: CoreFoundationLib.ReturnCodeOTPPush?
}
