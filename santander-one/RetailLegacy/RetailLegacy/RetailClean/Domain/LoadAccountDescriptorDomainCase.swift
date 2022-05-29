//

import Foundation
import CoreFoundationLib


class LoadAccountDescriptorDomainCase: UseCase<Void, Void, LoadAccountDescriptorDomainCaseErrorOutput> {
    private let dependencies: DependenciesResolver
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let appRepository: AppRepository

    init(dependencies: DependenciesResolver, accountDescriptorRepository: AccountDescriptorRepository, appRepository: AppRepository) {
        self.dependencies = dependencies
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appRepository = appRepository
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadAccountDescriptorDomainCaseErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.accountDescriptorRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}

class LoadAccountDescriptorDomainCaseErrorOutput: StringErrorOutput {
}
