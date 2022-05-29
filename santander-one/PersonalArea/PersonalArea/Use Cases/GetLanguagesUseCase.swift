//
//  GetLanguagesUseCase.swift
//  PersonalArea
//
//  Created by alvola on 26/11/2019.
//

import CoreFoundationLib

final class GetLanguagesUseCase: UseCase<Void, GetLanguagesUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let currentLanguage = appRepositoryProtocol.getCurrentLanguage()
        let localAppConfig = self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        return UseCaseResponse.ok(GetLanguagesUseCaseOkOutput(
            languages: localAppConfig.languageList,
            currentLanguage: currentLanguage
        ))
    }
}

struct GetLanguagesUseCaseOkOutput {
    let languages: [LanguageType]?
    let currentLanguage: LanguageType?
}
