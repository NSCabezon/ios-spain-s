//
//  GetPublicProductsUseCase.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 6/3/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

class GetPublicProductsUseCase: UseCase<Void, GetPublicProductsUseCaseOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    private let productsRepository: PublicProductsRepository
    private let appRepository: AppRepository
    
    init(dependencies: DependenciesResolver, productsRepository: PublicProductsRepository, appRepository: AppRepository) {
        self.dependencies = dependencies
        self.appRepository = appRepository
        self.productsRepository = productsRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPublicProductsUseCaseOutput, StringErrorOutput> {
        try self.loadProduct()
        guard let response = productsRepository.getPublicProducts() else {
            return .error(StringErrorOutput(nil))
        }
        
        let productList = response.publicProducts.map({ PublicProductItem(product: $0)})
        return .ok(GetPublicProductsUseCaseOutput(publicProducts: productList))
    }
    
    private func loadProduct() throws {
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            throw  NSError(domain: "", code: 0, userInfo: nil)
        }
   
        let languageType: LanguageType
        if let response = try appRepository.getLanguage().getResponseData(), let type = response {
            languageType = type
        } else {
            let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
            languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        self.productsRepository.loadProduct(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
    }
}

struct GetPublicProductsUseCaseOutput {
    let publicProducts: [PublicProductItem]
}
