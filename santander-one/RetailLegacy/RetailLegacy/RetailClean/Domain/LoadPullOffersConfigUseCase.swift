import CoreFoundationLib

class LoadPullOffersConfigUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    private let pullOffersConfigRepository: PullOffersConfigRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver,
        pullOffersConfigRepository: PullOffersConfigRepository,
        appRepository: AppRepository) {
        self.dependencies = dependencies
        self.pullOffersConfigRepository = pullOffersConfigRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.pullOffersConfigRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}
