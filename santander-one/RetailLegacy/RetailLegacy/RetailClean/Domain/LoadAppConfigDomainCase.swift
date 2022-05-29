//

import Foundation
import CoreFoundationLib

class LoadAppConfigDomainCase: UseCase<Void, Void, LoadAppConfigDomainCaseErrorOutput> {
    private let dependencies: DependenciesResolver
    private let appConfigRepository: AppConfigRepository
    private let appRepository: AppRepository
    private let daoSharedAppConfig: DAOSharedAppConfig
    
    init(dependencies: DependenciesResolver,
         appConfigRepository: AppConfigRepository,
         appRepository: AppRepository,
         daoSharedAppConfig: DAOSharedAppConfig) {
        self.dependencies = dependencies
        self.appConfigRepository = appConfigRepository
        self.appRepository = appRepository
        self.daoSharedAppConfig = daoSharedAppConfig
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadAppConfigDomainCaseErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.appConfigRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
            var sharedAppConfig = daoSharedAppConfig.get()
            sharedAppConfig.isEnabledCounterValue = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCounterValueEnabled)
            sharedAppConfig.managersSantanderPersonal = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerSantanderPersonal)
            sharedAppConfig.isEnabledCheckSca = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCheckSca) 
            _ = daoSharedAppConfig.set(sharedAppConfig: sharedAppConfig)
        }
        return UseCaseResponse.ok()
    }
}

class LoadAppConfigDomainCaseErrorOutput: StringErrorOutput {
}
