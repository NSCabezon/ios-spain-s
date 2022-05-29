import Foundation
import CoreFoundationLib
import SANLibraryV3
import ESCommons

final class QuickBalanceLoginUseCase: UseCase<Void, QuickBalanceLoginUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<QuickBalanceLoginUseCaseOkOutput, StringErrorOutput> {
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let localAuth: LocalAuthenticationPermissionsManagerProtocol = self.dependenciesResolver.resolve()
        guard let deviceToken = localAuth.deviceToken,
            let footprint = localAuth.footprint,
            isBiometryAvailable,
            getLocalQuickBalanceEnabled() else {
                return UseCaseResponse.ok(QuickBalanceLoginUseCaseOkOutput.notTokenForLogin)
        }
        guard let persistedUser = appRepository.getSharedPersistedUser(), let loginType = UserLoginType(rawValue: persistedUser.loginType), let channelFrame = persistedUser.channelFrame else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        _ = provider.getBsanEnvironmentsManager().setEnvironment(bsanEnvironmentName: persistedUser.environmentName)
        let usernameFormatted = persistedUser.login
        var isDemo: Bool = false
        let isDemoResponse = try provider.getBsanSessionManager().isDemo()
        if isDemoResponse.isSuccess(), let demoResponseData = try isDemoResponse.getResponseData() {
            isDemo = demoResponseData
        }
        let isPb = persistedUser.isPb
        let authenticateResponse = try provider.getBsanAuthManager().loginTouchId(footPrint: footprint, deviceToken: deviceToken, login: usernameFormatted, channelFrame: channelFrame, userType: loginType, isDemo: isDemo, isPb: isPb)
        guard authenticateResponse.isSuccess() else {
            let error = try authenticateResponse.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return UseCaseResponse.ok(QuickBalanceLoginUseCaseOkOutput.login(isPb: isPb, username: usernameFormatted, loginType: loginType.rawValue))
    }
    
    private var isBiometryAvailable: Bool {
        let localAuth: LocalAuthenticationPermissionsManagerProtocol = self.dependenciesResolver.resolve()
        switch localAuth.biometryTypeAvailable {
        case .error, .none:
            return false
        case .touchId, .faceId:
            return true
        }
    }
    
    private func getLocalQuickBalanceEnabled() -> Bool {
        let compilation: SpainCompilationProtocol = self.dependenciesResolver.resolve()
        let query = KeychainQuery(service: compilation.service,
                                      account: compilation.quickbalance,
                                      accessGroup: compilation.sharedTokenAccessGroup)
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
}

enum QuickBalanceLoginUseCaseOkOutput {
    case login(isPb: Bool, username: String, loginType: String)
    case notTokenForLogin
}
