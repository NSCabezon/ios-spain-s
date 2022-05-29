import Foundation
import CoreFoundationLib

public protocol PrevalidateChangePasswordUseCaseProtocol: UseCase<ValidateChangePasswordUseCaseInput, Void, ValidateChangePasswordUseCaseErrorOutput> { }

final class PrevalidateChangePasswordUseCase: UseCase<ValidateChangePasswordUseCaseInput, Void, ValidateChangePasswordUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateChangePasswordUseCaseInput) throws -> UseCaseResponse<Void, ValidateChangePasswordUseCaseErrorOutput> {
        guard 2...8 ~= requestValues.oldPassword.count else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .differentThanNCharacters))
        }
        guard self.isNumeric(string: requestValues.oldPassword) else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .notnumeric))
        }
        guard requestValues.newPassword.elementsEqual(requestValues.confirmPassword) else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .different))
        }
        guard requestValues.newPassword.count == 8 else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .differentThanNCharacters))
        }
        guard isNumeric(string: requestValues.newPassword) else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .notnumeric))
        }
        guard !requestValues.newPassword.elementsEqual(requestValues.oldPassword) else {
            return .error(ValidateChangePasswordUseCaseErrorOutput(errorPass: .charactersValidated))
        }
        return .ok()
    }
}

private extension PrevalidateChangePasswordUseCase {
    func isNumeric(string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil {
            return true
        }
        return false
    }
}

extension PrevalidateChangePasswordUseCase: PrevalidateChangePasswordUseCaseProtocol {}
