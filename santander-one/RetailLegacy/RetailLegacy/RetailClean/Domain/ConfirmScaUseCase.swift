import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import Account

public protocol ConfirmScaUseCaseProtocol: UseCase<ConfirmScaUseCaseInput, ConfirmScaUseCaseOkOutput, ConfirmScaUseCaseErrorOutput> {}
public protocol CleanSCAInfoUseCaseProtocol: UseCase<Void, Bool, StringErrorOutput> {}

class ConfirmScaUseCase: UseCase<ConfirmScaUseCaseInput, ConfirmScaUseCaseOkOutput, ConfirmScaUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmScaUseCaseInput) throws -> UseCaseResponse<ConfirmScaUseCaseOkOutput, ConfirmScaUseCaseErrorOutput> {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let validateScaDto: ValidateScaDTO = requestValues.validateSca.dto
        let operativeIndicator: ScaOperativeIndicator = requestValues.operativeIndicator
        let response: BSANResponse<ConfirmScaDTO> = try scaManager.confirmSca(tokenOTP: validateScaDto.tokenOTP, ticketOTP: validateScaDto.ticket, codeOTP: requestValues.codeOTP, operativeIndicator: operativeIndicator.dto)
        guard response.isSuccess(), let confirmScaDTO: ConfirmScaDTO = try response.getResponseData() else {
            let error: String? = try response.getErrorMessage()
            let errorCode: String = try response.getErrorCode()
            let otpType: ConfirmScaErrorType = getOTPError(errorMessage: error)
            return .error(ConfirmScaUseCaseErrorOutput(error, otpType, errorCode))
        }
        switch (confirmScaDTO.otpValIndicator, confirmScaDTO.penalizeScaIndicator) {
        case ("0", _):
            let confirmSca: ConfirmSca = ConfirmSca(dto: confirmScaDTO)
            return UseCaseResponse.ok(ConfirmScaUseCaseOkOutput(confirmSca: confirmSca))
        case (_, "S"):
            switch operativeIndicator {
            case .login:
                try scaManager.saveScaOtpLoginTemporaryBlock()
            case .accounts:
                try scaManager.saveScaOtpAccountTemporaryBlock()
            }
            return .error(ConfirmScaUseCaseErrorOutput(nil, ConfirmScaErrorType.penalize, nil))
        case ("2", _):
            return .error(ConfirmScaUseCaseErrorOutput(nil, ConfirmScaErrorType.timeoutOTP, nil))
        default://Este caso se corresponde con confirmScaDTO.otpValIndicator == "1" y los no previstos en el WF
            return .error(ConfirmScaUseCaseErrorOutput(nil, ConfirmScaErrorType.wrongOTP, nil))
        }
    }
    
    func getOTPError(errorMessage: String?) -> ConfirmScaErrorType {
        guard let errorMessage = errorMessage else {
            return .otherError
        }
        let lowerCaseErrorMessage: String = errorMessage.lowercased().deleteAccent()
        guard lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed1)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed2)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed3)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed4)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed5)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed6)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed7) else {
            return .serviceDefault
        }
        return .wrongOTP
    }
}

extension ConfirmScaUseCase: ConfirmScaUseCaseProtocol {}

public struct ConfirmScaUseCaseInput {
    public let operativeIndicator: ScaOperativeIndicator
    let validateSca: ValidateSca
    public let codeOTP: String
    public var scaTransactionParams: SCATransactionParams?
}

public struct ConfirmScaUseCaseOkOutput {
    public let confirmSca: ConfirmSca
    
    public init(confirmSca: ConfirmSca) {
        self.confirmSca = confirmSca
    }
}

public enum ConfirmScaErrorType {
    case wrongOTP
    case timeoutOTP
    case serviceDefault
    case otherError
    case penalize
}

public class ConfirmScaUseCaseErrorOutput: StringErrorOutput {
    let otpResult: ConfirmScaErrorType
    let errorCode: String?
    
    public init(_ errorDesc: String?, _ otpResultType: ConfirmScaErrorType, _ errorCode: String?) {
        self.otpResult = otpResultType
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}
