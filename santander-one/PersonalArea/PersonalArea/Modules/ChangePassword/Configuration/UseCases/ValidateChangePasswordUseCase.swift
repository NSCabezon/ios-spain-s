import Foundation
import SANLegacyLibrary
import CoreFoundationLib

public protocol ValidateChangePasswordUseCaseProtocol: UseCase<ValidateChangePasswordUseCaseInput, Void, ValidateChangePasswordUseCaseErrorOutput> { }

final class ValidateChangePasswordUseCase: UseCase<ValidateChangePasswordUseCaseInput, Void, ValidateChangePasswordUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    public override func executeUseCase(requestValues: ValidateChangePasswordUseCaseInput) throws -> UseCaseResponse<Void, ValidateChangePasswordUseCaseErrorOutput> {
        let response = try self.provider.getBsanSignatureManager().changePassword(oldPassword: requestValues.oldPassword, newPassword: requestValues.newPassword)
        if response.isSuccess() {
            return .ok()
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return .error(ValidateChangePasswordUseCaseErrorOutput(errorDesc: errorDescription, errorCode: errorCode, errorPass: ChangePasswordCodError.other))
    }
}

public struct ValidateChangePasswordUseCaseInput {
    public let oldPassword: String
    public let newPassword: String
    public let confirmPassword: String
    
    public init(oldPassword: String, newPassword: String, confirmPassword: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.confirmPassword = confirmPassword
    }
}

public final class ValidateChangePasswordUseCaseErrorOutput: StringErrorOutput {
    public let errorDesc: String?
    public let errorCode: String?
    public let errorPass: ChangePasswordCodError
    
    public init(errorDesc: String? = nil, errorCode: String? = nil, errorPass: ChangePasswordCodError) {
        self.errorDesc = errorDesc
        self.errorCode = errorCode
        self.errorPass = errorPass
        super.init(errorDesc)
    }
}

extension ValidateChangePasswordUseCase: ValidateChangePasswordUseCaseProtocol { }
