import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetDefaultNGOsUseCase: UseCase<Void, GetDefaultNGOsUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let appRepository: AppRepositoryProtocol
    let repository: BizumDefaultNGOsRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.repository = self.dependenciesResolver.resolve(for: BizumDefaultNGOsRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetDefaultNGOsUseCaseOkOutput, StringErrorOutput> {
        try self.loadDefaultNGOs()
        let bizumNGOs = self.repository.getDefaultNGOs()?.defaultNGOs ?? []
        let bizumNGOList = bizumNGOs.map({ BizumDefaultNGOEntity($0) })
        return .ok(GetDefaultNGOsUseCaseOkOutput(bizumNGOs: bizumNGOList))
    }
}

private extension GetDefaultNGOsUseCase {
    func loadDefaultNGOs() throws {
        guard let baseUrl = try self.appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            throw NSError(domain: "AppRepositoryProtocol", code: 0, userInfo: nil)
        }
        let language = try self.getLanguageType().getPublicLanguage
        self.repository.load(baseUrl: baseUrl, language: language)
    }
    
    func getLanguageType() throws -> LanguageType {
        guard let response = try appRepository.getLanguage().getResponseData(),
              let languageType = response else {
            let defaultLanguage = self.dependenciesResolver.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependenciesResolver.resolve(for: LocalAppConfig.self).languageList
            return Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        return languageType
    }
}

struct GetDefaultNGOsUseCaseOkOutput {
    let bizumNGOs: [BizumDefaultNGOEntity]
}
