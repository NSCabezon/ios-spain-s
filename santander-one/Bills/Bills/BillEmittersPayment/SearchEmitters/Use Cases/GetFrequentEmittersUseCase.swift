import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class GetFrequentEmittersUseCase: UseCase<Void, GetFrequentEmittersUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let appRepository: AppRepositoryProtocol
    let repository: FrequentEmittersRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.repository = self.dependenciesResolver.resolve(for: FrequentEmittersRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFrequentEmittersUseCaseOkOutput, StringErrorOutput> {
        try loadFrequentEmitters()
        let frecuentEmitterDTOs = self.repository.getFrequentEmitters()?.frequentEmitters ?? []
        let emitterList = frecuentEmitterDTOs.map({ EmitterEntity($0) })
        return .ok(GetFrequentEmittersUseCaseOkOutput(emitters: emitterList))
    }
    
    private func loadFrequentEmitters() throws {
        guard let baseUrl = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            throw NSError(domain: "AppRepositoryProtocol", code: 0, userInfo: nil)
        }
        let language = try self.getLanguageType().getPublicLanguage
        self.repository.loadEmitter(baseUrl: baseUrl, language: language)
    }
    
    private func getLanguageType() throws -> LanguageType {
        guard let response = try appRepository.getLanguage().getResponseData(),
              let languageType = response else {
            let defaultLanguage = self.dependenciesResolver.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependenciesResolver.resolve(for: LocalAppConfig.self).languageList
            return Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        return languageType
    }
}

struct GetFrequentEmittersUseCaseOkOutput {
    let emitters: [EmitterEntity]
}
