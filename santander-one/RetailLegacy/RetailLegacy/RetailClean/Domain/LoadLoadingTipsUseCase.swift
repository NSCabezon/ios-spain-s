//
//  LoadLoadingTipsUseCase.swift
//  RetailClean
//
//  Created by Luis Escámez Sánchez on 30/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

class LoadLoadingTipsUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    private let loadingTipsRepository: LoadingTipsRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver,
        loadingTipsRepository: LoadingTipsRepository,
        appRepository: AppRepository) {
        self.dependencies = dependencies
        self.loadingTipsRepository = loadingTipsRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.loadingTipsRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        return UseCaseResponse.ok()
    }
}
