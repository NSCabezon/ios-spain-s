import Foundation
import CoreFoundationLib

class LoadUserSegmentsUseCase: UseCase<Void, Void, LoadUserSegmentsErrorOutput> {
    private let dependencies: DependenciesResolver
    private let segmentedUserRepository: SegmentedUserRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver,
         segmentedUserRepository: SegmentedUserRepository,
         appRepository: AppRepository) {
        self.dependencies = dependencies
        self.segmentedUserRepository = segmentedUserRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadUserSegmentsErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.segmentedUserRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadUserSegmentsErrorOutput: StringErrorOutput {
}
