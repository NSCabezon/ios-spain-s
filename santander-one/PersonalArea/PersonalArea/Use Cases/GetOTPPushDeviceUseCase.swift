import CoreFoundationLib
import SANLegacyLibrary

public class GetOTPPushDeviceUseCase: UseCase<Void, GetOTPPushDeviceUseCaseOkOutput, GetOTPPushDeviceUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOTPPushDeviceUseCaseOkOutput, GetOTPPushDeviceUseCaseErrorOutput> {
        let bsanManagerProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try bsanManagerProvider.getBsanOTPPushManager().requestDevice()
        if response.isSuccess(), case let deviceDTO? = try? response.getResponseData() {
            return .ok(GetOTPPushDeviceUseCaseOkOutput(device: OTPPushDeviceEntity(deviceDTO: deviceDTO)))
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

public struct GetOTPPushDeviceUseCaseOkOutput {
    public let device: OTPPushDeviceEntity
}

public enum OTPPushDeviceErrorType: String {
    case technicalError = "SUPOTE_000001"
    case unregisteredDevice = "SUPOTE_000002"
    case differentsDevices = "SUPOTE_000003"
    case serviceFault
}

public protocol GetOTPPushDeviceErrorProvider {
    var codeError: OTPPushDeviceErrorType { get }
}

public class GetOTPPushDeviceUseCaseErrorOutput: StringErrorOutput, GetOTPPushDeviceErrorProvider {
    public var codeError: OTPPushDeviceErrorType
    
    public init(_ codeError: OTPPushDeviceErrorType, _ errorDesc: String? = "") {
        self.codeError = codeError
        super.init(errorDesc)
    }
}
