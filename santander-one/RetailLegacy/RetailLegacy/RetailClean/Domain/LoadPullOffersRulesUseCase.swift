import CoreFoundationLib

class LoadPullOffersRulesUseCase: UseCase<Void, Void, LoadPullOffersRulesErrorOutput> {
    private let dependencies: DependenciesResolver
    private let rulesRepository: RulesRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver, rulesRepository: RulesRepository, appRepository: AppRepository) {
        self.dependencies = dependencies
        self.rulesRepository = rulesRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadPullOffersRulesErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.rulesRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadPullOffersRulesErrorOutput: StringErrorOutput {
}
