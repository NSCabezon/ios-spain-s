import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import Account

public protocol ValidateScaUseCaseProtocol: UseCase<ValidateScaUseCaseInput, ValidateScaUseCaseOkOutput, ValidateScaUseCaseErrorOutput> {}

class ValidateScaUseCase: UseCase<ValidateScaUseCaseInput, ValidateScaUseCaseOkOutput, ValidateScaUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    private let blackListErrorCode: String = "SUPPFP_000015"
    private let tempraryBlockErrorCode: String = "SUPPFP_000018"
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateScaUseCaseInput) throws -> UseCaseResponse<ValidateScaUseCaseOkOutput, ValidateScaUseCaseErrorOutput> {
        let operativeIndicator: ScaOperativeIndicator = requestValues.operativeIndicator
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<ValidateScaDTO> = try scaManager.validateSca(forwardIndicator: requestValues.forwardIndicator, foceSMS: requestValues.forceSMS, operativeIndicator: operativeIndicator.dto)
        guard response.isSuccess(), let validateScaDTO: ValidateScaDTO = try response.getResponseData() else {
            let errorCode: String = try response.getErrorCode()
            let errorDescription: String? = try response.getErrorMessage()
            let type: ValidateScaErrorType
            switch errorCode {
            case blackListErrorCode:
                type = .blacklist
            case tempraryBlockErrorCode:
                type = .serviceDefault
                switch operativeIndicator {
                case .login:
                    try scaManager.saveScaOtpLoginTemporaryBlock()
                case .accounts:
                    try scaManager.saveScaOtpAccountTemporaryBlock()
                }
            default:
                type = .serviceDefault
            }
            return UseCaseResponse.error(ValidateScaUseCaseErrorOutput(errorDescription, type))
        }
        
        let otpPushDevice: OTPPushDevice? = try? getOtpPushDevice()
        let validateSca: ValidateSca = ValidateSca(dto: validateScaDTO)
        return UseCaseResponse.ok(ValidateScaUseCaseOkOutput(validateSca: validateSca, otpPushDevice: otpPushDevice))
    }
    
    private func getOtpPushDevice() throws -> OTPPushDevice? {
        let response = try provider.getBsanOTPPushManager().requestDevice()
        guard response.isSuccess(), let deviceDto = try response.getResponseData() else { return nil }
        return OTPPushDevice(deviceDTO: deviceDto)
    }
}

extension ValidateScaUseCase: ValidateScaUseCaseProtocol {}

public struct ValidateScaUseCaseInput {
    let forwardIndicator: Bool
    let forceSMS: Bool
    public let operativeIndicator: ScaOperativeIndicator
    public var scaTransactionParams: SCATransactionParams?
}

public struct ValidateScaUseCaseOkOutput {
    public init(validateSca: ValidateSca, otpPushDevice: OTPPushDevice?) {
        self.validateSca = validateSca
        self.otpPushDevice = otpPushDevice
    }
    
    let validateSca: ValidateSca
    let otpPushDevice: OTPPushDevice?
}

public enum ValidateScaErrorType {
    case blacklist
    case serviceDefault
}

public class ValidateScaUseCaseErrorOutput: StringErrorOutput {
    let type: ValidateScaErrorType
    
    public init(_ errorDesc: String?, _ type: ValidateScaErrorType) {
        self.type = type
        super.init(errorDesc)
    }
}
