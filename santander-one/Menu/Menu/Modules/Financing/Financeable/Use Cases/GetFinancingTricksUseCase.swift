import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetFinancingTricksUseCase: UseCase<Void, GetFinancingTricksUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let globalPosition: GlobalPositionRepresentable
    private let appRepository: AppRepositoryProtocol
    private let trickRepository: TricksRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.trickRepository = self.dependenciesResolver.resolve(for: TricksRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinancingTricksUseCaseOkOutput, StringErrorOutput> {
        try self.loadFinancialTricks()
        guard let response = trickRepository.getTricks(), let financingTricks = response.financingTricks, !financingTricks.isEmpty else {
            return .error(StringErrorOutput(nil))
        }
        let tricks = financingTricks.map({ TrickEntity($0) })
        return .ok(GetFinancingTricksUseCaseOkOutput(financingTricks: tricks))
    }
    
    private func loadFinancialTricks() throws {
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            throw  NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let languageType: LanguageType
        if let response = try appRepository.getLanguage().getResponseData(), let type = response {
            languageType = type
        } else {
            let defaultLanguage = self.dependenciesResolver.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependenciesResolver.resolve(for: LocalAppConfig.self).languageList
            languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        self.trickRepository.loadTricks(with: urlBase, publicLanguage: languageType.getPublicLanguage)
     }
}

struct GetFinancingTricksUseCaseOkOutput {
    let financingTricks: [TrickEntity]
}
