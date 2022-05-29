import Foundation
import CoreFoundationLib


class LoadServicesForYouUseCase: UseCase<Void, Void, LoadServicesForYouErrorOutput> {
    private let dependencies: DependenciesResolver
    private let servicesForYouRepository: ServicesForYouRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver,
         servicesForYouRepository: ServicesForYouRepository,
         appRepository: AppRepository) {
        self.dependencies = dependencies
        self.servicesForYouRepository = servicesForYouRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadServicesForYouErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.servicesForYouRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadServicesForYouErrorOutput: StringErrorOutput {
}
