import Foundation
import CoreFoundationLib
import Localization
import RetailLegacy

final class WidgetLanguageUseCase: UseCase<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
    private let localAppConfig: LocalAppConfig
    private let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    private let daoLanguage: DAOLanguage
    
    init(localAppConfig: LocalAppConfig, daoSharedPersistedUser: DAOSharedPersistedUserProtocol, daoLanguage: DAOLanguage) {
        self.localAppConfig = localAppConfig
        self.daoSharedPersistedUser = daoSharedPersistedUser
        self.daoLanguage = daoLanguage
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
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
            let defaultLanguage = localAppConfig.language
            let languageList = localAppConfig.languageList
            current = Language.createDefault(isPb: isPb, defaultLanguage: defaultLanguage, availableLanguageList: languageList)
        }
        return UseCaseResponse.ok(GetLanguagesSelectionUseCaseOkOutput(current: current))
    }
}

extension WidgetLanguageUseCase: GetLanguagesSelectionUseCaseProtocol {}
