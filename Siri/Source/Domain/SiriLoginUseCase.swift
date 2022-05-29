import CoreFoundationLib
import SANLegacyLibrary
import CommonAppExtensions

final class SiriLoginUseCase: ExtensionsLoginUseCase {
    override init(bsanManagersProvider: BSANManagersProvider, daoSharedPersistedUser: DAOSharedPersistedUserProtocol) {
        super.init(bsanManagersProvider: bsanManagersProvider, daoSharedPersistedUser: daoSharedPersistedUser)
        loginCase = .siri
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        let touchIdAccount = Compilation.Keychain.Account.touchId
        let widgetAccount = Compilation.Keychain.Account.widget
        let service = Compilation.Keychain.service
        let accessGroup = Compilation.Keychain.sharedTokenAccessGroup
        let loginResponse = try executeLogin(touchIdAccount: touchIdAccount, widgetAccount: widgetAccount, service: service, accessGroup: accessGroup)
        switch try loginResponse.getOkResult() {
        case .login(let isPb, _, _):
            let bsanResponse = try bsanManagersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
            guard bsanResponse.isSuccess() else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
        case .notTokenForLogin:
            break
        }
        return loginResponse
    }
}
