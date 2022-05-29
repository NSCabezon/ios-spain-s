import Foundation
import CoreFoundationLib
import SANLibraryV3
import RetailLegacy

final class WidgetUserUseCase: LocalAuthLoginDataUseCase<WidgetUserUseCaseInput, WidgetUserUseCaseOkOutput, StringErrorOutput> {
    private let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    init(daoSharedPersistedUser: DAOSharedPersistedUserProtocol) {
        self.daoSharedPersistedUser = daoSharedPersistedUser
        super.init()
    }
    
    override func executeUseCase(requestValues: WidgetUserUseCaseInput) throws -> UseCaseResponse<WidgetUserUseCaseOkOutput, StringErrorOutput> {
        guard let _ = getLocalAuthData(requestValues: requestValues) else {
            return UseCaseResponse.ok(WidgetUserUseCaseOkOutput.notUserToken)
        }
        guard let persistedUser = daoSharedPersistedUser.get() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        if persistedUser.loginType == requestValues.loginType && persistedUser.login == requestValues.username {
            return UseCaseResponse.ok(WidgetUserUseCaseOkOutput.okUser)
        } else {
            return UseCaseResponse.ok(WidgetUserUseCaseOkOutput.notTokenForLogin)
        }
    }
}

struct WidgetUserUseCaseInput {
    let username: String
    let loginType: String
}

enum WidgetUserUseCaseOkOutput {
    case okUser
    case notUserToken
    case notTokenForLogin
}
