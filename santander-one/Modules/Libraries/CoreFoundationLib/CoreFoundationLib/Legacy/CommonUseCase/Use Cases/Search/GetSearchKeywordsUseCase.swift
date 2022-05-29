//
//  GetSearchKeywordsUseCase.swift
//  GlobalSearch
//
//  Created by César González Palomino on 25/07/2020.
//


public class GetSearchKeywordsUseCase: UseCase<Void, GetSearchKeywordsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSearchKeywordsUseCaseOkOutput, StringErrorOutput> {
        let keywordsRepository: SearchKeywordsRepositoryProtocol = self.dependenciesResolver.resolve(for: SearchKeywordsRepositoryProtocol.self)
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let languageType = appRepository.getCurrentLanguage()
        keywordsRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        let searchKeywordListDTO = keywordsRepository.getKeywords()
        let keywords = searchKeywordListDTO?.searchKeywords?.compactMap { SearchKeywordEntity($0) } ?? []
        let globalAppKeywords = searchKeywordListDTO?.globalAppKeywords?.compactMap { GlobalAppKeywordsEntity($0) } ?? []
        let operativesOnShorcutsAppKeywords = searchKeywordListDTO?.operativesOnShorcutsAppKeywords?.compactMap { OperativeOnShortcutsKeywordsEntity($0) } ?? []
        let actionOnShorcutsAppKeywords = searchKeywordListDTO?.actionOnShorcutsAppKeywords?.compactMap { GlobalAppKeywordsEntity($0) } ?? []
        return UseCaseResponse.ok(
            GetSearchKeywordsUseCaseOkOutput(
                keywords: keywords,
                globalAppKeywords: globalAppKeywords,
                operativesOnShorcutsAppKeywords: operativesOnShorcutsAppKeywords,
                actionOnShorcutsAppKeywords: actionOnShorcutsAppKeywords
            )
        )
    }
}

public struct GetSearchKeywordsUseCaseOkOutput {
    public let keywords: [SearchKeywordEntity]
    public let globalAppKeywords: [GlobalAppKeywordsEntity]
    public let operativesOnShorcutsAppKeywords: [OperativeOnShortcutsKeywordsEntity]
    public let actionOnShorcutsAppKeywords: [GlobalAppKeywordsEntity]
}
