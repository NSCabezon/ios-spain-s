//
//  GetAllTricksUseCase.swift
//  Menu
//
//  Created by Tania Castellano Brasero on 28/04/2020.
//

import CoreFoundationLib

final class GetAllTricksUseCase: UseCase<Void, GetAllTricksUseCaseOkOutput, StringErrorOutput> {    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAllTricksUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let tricksRepository = dependenciesResolver.resolve(for: TricksRepositoryProtocol.self)
        
        if let urlBase = try appRepositoryProtocol.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepositoryProtocol.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependenciesResolver.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependenciesResolver.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            tricksRepository.loadTricks(with: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        
        guard let response = tricksRepository.getTricks(), let tricksDTOs = response.tricks else {
            return .error(StringErrorOutput(nil))
        }
        let tricks = tricksDTOs.map { trickDTO in
            TrickEntity(trickDTO)
        }
        return .ok(GetAllTricksUseCaseOkOutput(tricks: tricks))
    }
}

struct GetAllTricksUseCaseOkOutput {
    let tricks: [TrickEntity]
}
