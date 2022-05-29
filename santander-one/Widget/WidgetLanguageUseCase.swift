import Foundation
import CoreFoundationLib
import RetailLegacy

final class WidgetLanguageUseCase: LocalAuthLoginDataUseCase<Void, WidgetLanguageUseCaseOkOutput, StringErrorOutput> {
    private let localAppConfig: LocalAppConfig
    private let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    private let daoLanguage: DAOLanguage
    
    init(localAppConfig: LocalAppConfig, daoSharedPersistedUser: DAOSharedPersistedUserProtocol, daoLanguage: DAOLanguage) {
        self.localAppConfig = localAppConfig
        self.daoSharedPersistedUser = daoSharedPersistedUser
        self.daoLanguage = daoLanguage
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<WidgetLanguageUseCaseOkOutput, StringErrorOutput> {
        let isPb: Bool
        if let persistedUser = daoSharedPersistedUser.get() {
            isPb = persistedUser.isPb
        } else {
            isPb = false
        }
        let current: Language
        if let language = daoLanguage.get() {
            current = Language.createFromType(languageType: language, isPb: isPb)
        } else {
            current = Language.createDefault(isPb: isPb, defaultLanguage: localAppConfig.language)
        }
        return UseCaseResponse.ok(WidgetLanguageUseCaseOkOutput(current: current))
    }
}

struct WidgetLanguageUseCaseOkOutput {
    let current: Language
}
