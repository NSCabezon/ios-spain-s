//

import CoreFoundationLib

class LoadPullOffersOffersUseCase: UseCase<Void, Void, LoadPullOffersOffersErrorOutput> {
    private let dependencies: DependenciesResolver
    private let offersRepository: OffersRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver,
        offersRepository: OffersRepository,
        appRepository: AppRepository) {
        self.dependencies = dependencies
        self.offersRepository = offersRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadPullOffersOffersErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.offersRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadPullOffersOffersErrorOutput: StringErrorOutput {
}
