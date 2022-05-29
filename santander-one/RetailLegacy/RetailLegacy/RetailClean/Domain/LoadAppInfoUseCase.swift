//

import Foundation
import CoreFoundationLib

class LoadAppInfoUseCase: UseCase<Void, Void, LoadAppInfoErrorOutput> {
    private let dependencies: DependenciesResolver
    private let appInfoRepository: AppInfoRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver, appInfoRepository: AppInfoRepository, appRepository: AppRepository) {
        self.dependencies = dependencies
        self.appInfoRepository = appInfoRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadAppInfoErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.appInfoRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadAppInfoErrorOutput: StringErrorOutput {
}
