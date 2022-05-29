import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public enum ExtensionLoginCase {
    case unknown
    case widget
    case siri
}

public enum ExtensionsLoginUseCaseOkOutput {
    case login(isPb: Bool, username: String, loginType: String)
    case notTokenForLogin
}

open class ExtensionsLoginUseCase: UseCase<Void, ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
    public let bsanManagersProvider: BSANManagersProvider
    public var loginCase: ExtensionLoginCase = .unknown
    
    private let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    
    public init(bsanManagersProvider: BSANManagersProvider, daoSharedPersistedUser: DAOSharedPersistedUserProtocol) {
        self.bsanManagersProvider = bsanManagersProvider
        self.daoSharedPersistedUser = daoSharedPersistedUser
        super.init()
    }
    
    open override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        fatalError()
    }
    
    public func executeLogin(touchIdAccount: String, widgetAccount: String, service: String, accessGroup: String, requestValues: Void = ()) throws -> UseCaseResponse<ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        guard loginCase != .unknown else {
            fatalError("Must set login case")
        }
        guard
            let localAuthData = getLocalAuthData(account: touchIdAccount, service: service, accessGroup: accessGroup),
            (loginCase != .widget || getLocalWidgetEnabled(account: widgetAccount, service: service, accessGroup: accessGroup)) else {
            return UseCaseResponse.ok(ExtensionsLoginUseCaseOkOutput.notTokenForLogin)
        }
        guard let persistedUser = daoSharedPersistedUser.get(),
              let loginType = UserLoginType(rawValue: persistedUser.loginType),
              let channelFrame = persistedUser.channelFrame else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        _ = bsanManagersProvider.getBsanEnvironmentsManager().setEnvironment(bsanEnvironmentName: persistedUser.environmentName)
        let usernameFormatted = persistedUser.login
        let isDemo = false
        let isPb = persistedUser.isPb
        let authenticateResponse = try bsanManagersProvider.getBsanAuthManager().loginTouchId(footPrint: localAuthData.footprint, deviceToken: localAuthData.deviceMagicPhrase, login: usernameFormatted, channelFrame: channelFrame, userType: loginType, isDemo: isDemo, isPb: isPb)
        guard authenticateResponse.isSuccess() else {
            let error = try authenticateResponse.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return UseCaseResponse.ok(ExtensionsLoginUseCaseOkOutput.login(isPb: isPb, username: usernameFormatted, loginType: loginType.rawValue))
    }
    
}

private extension ExtensionsLoginUseCase {
    func getLocalWidgetEnabled(account: String, service: String, accessGroup: String) -> Bool {
        let query = KeychainQuery(service: service,
                                  account: account,
                                  accessGroup: accessGroup)
        do {
            let passwordObject = try KeychainWrapper().fetch(query: query)
            if let object = passwordObject, let data = object as? NSNumber {
                return data.boolValue
            }
        } catch {
            return false
        }
        return false
    }
    
    func getLocalAuthData(account: String, service: String, accessGroup: String) -> TouchIdData? {
        let query = KeychainQuery(service: service,
                                  account: account,
                                  accessGroup: accessGroup)
        return KeychainWrapper().fetch(query: query,
                                     className: "TouchIdData")
    }
}
