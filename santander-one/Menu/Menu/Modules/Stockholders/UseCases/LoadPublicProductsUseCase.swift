//
//  LoadPublicProductsUseCase.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/2/20.
//

import Foundation
import CoreFoundationLib

class LoadPublicProductsUseCase: UseCase<Void, LoadPublicProductsUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let productsRepository: PublicProductsRepositoryProtocol
    private let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.productsRepository = dependenciesResolver.resolve(for: PublicProductsRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadPublicProductsUseCaseOutput, StringErrorOutput> {
        try self.loadProduct()
        guard let response = productsRepository.getPublicProducts() else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(LoadPublicProductsUseCaseOutput(publicProducts: response))
    }
    
    private func loadProduct() throws {
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
        self.productsRepository.loadProduct(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
    }
}

struct LoadPublicProductsUseCaseOutput {
    let publicProducts: PublicProductsDTO?
}
