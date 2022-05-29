import CoreFoundationLib
import SANLegacyLibrary

class GetOTPPushDeviceUseCase: UseCase<Void, GetOTPPushDeviceUseCaseOkOutput, GetOTPPushDeviceUseCaseErrorOutput> {
    
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOTPPushDeviceUseCaseOkOutput, GetOTPPushDeviceUseCaseErrorOutput> {
        let response = try bsanManagerProvider.getBsanOTPPushManager().requestDevice()
        if response.isSuccess(), case let deviceDTO? = try? response.getResponseData() {
            return .ok(GetOTPPushDeviceUseCaseOkOutput(device: OTPPushDevice(deviceDTO: deviceDTO)))
        }
        
        let error = try response.getErrorCode()
        let errorDesc = try response.getErrorMessage()
        guard error != OTPPushDeviceErrorType.unregisteredDevice.rawValue else {
            return .error(GetOTPPushDeviceUseCaseErrorOutput(OTPPushDeviceErrorType.unregisteredDevice, errorDesc))
        }
        guard error != OTPPushDeviceErrorType.technicalError.rawValue else {
            return .error(GetOTPPushDeviceUseCaseErrorOutput(OTPPushDeviceErrorType.technicalError, errorDesc))
        }
        guard error != OTPPushDeviceErrorType.differentsDevices.rawValue else {
            return .error(GetOTPPushDeviceUseCaseErrorOutput(OTPPushDeviceErrorType.differentsDevices, errorDesc))
        }
        return .error(GetOTPPushDeviceUseCaseErrorOutput(OTPPushDeviceErrorType.serviceFault, errorDesc))
    }
}

struct GetOTPPushDeviceUseCaseOkOutput {
    let device: OTPPushDevice
}

enum OTPPushDeviceErrorType: String {
    case technicalError = "SUPOTE_000001"
    case unregisteredDevice = "SUPOTE_000002"
    case differentsDevices = "SUPOTE_000003"
    case serviceFault
}

protocol GetOTPPushDeviceErrorProvider {
    var codeError: OTPPushDeviceErrorType { get }
}

class GetOTPPushDeviceUseCaseErrorOutput: StringErrorOutput, GetOTPPushDeviceErrorProvider {
    var codeError: OTPPushDeviceErrorType
    
    init(_ codeError: OTPPushDeviceErrorType, _ errorDesc: String? = "") {
        self.codeError = codeError
        super.init(errorDesc)
    }
}
