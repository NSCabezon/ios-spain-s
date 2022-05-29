import CoreFoundationLib
import Foundation
import Login
import RetailLegacy

struct ForcedPasswordChangeAdapter: ForcedPasswordChangeAdapterProtocol {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigRepository: AppConfigRepositoryProtocol

    var isForcedPasswordChange: Bool = false

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
        self.appConfigRepository = dependenciesResolver.resolve()
        self.isForcedPasswordChange = checkForcedPassword()
    }

    private func checkForcedPassword() -> Bool {
        let needUpdatePasswordConfiguration = dependenciesResolver.resolve(forOptionalType: SetNeedUpdatePasswordConfiguration.self)
        let appConfigNeedUpdatePassword = appConfigRepository.getBool(DomainConstant.forceUpdateKeys) ?? false
        return appConfigNeedUpdatePassword && (needUpdatePasswordConfiguration?.forceToUpdatePassword ?? false)
    }
}
