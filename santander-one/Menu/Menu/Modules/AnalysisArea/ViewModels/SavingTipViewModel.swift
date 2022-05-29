//
//  SavingTipViewModel.swift
//  Menu
//
//  Created by Tania Castellano Brasero on 29/04/2020.
//

import CoreFoundationLib

public struct SavingTipViewModel {
    let entity: TrickEntity
    let dependenciesResolver: DependenciesResolver
    
    public init(entity: TrickEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var textButton: String {
        return entity.textButton
    }
    
    var title: String {
        return entity.title
    }
    
    var description: String {
        return self.entity.description
    }
    
    var imageUrl: String? {
        guard let baseUrl = self.baseUrlProvider.baseURL else { return nil }
        return String(format: "%@%@", baseUrl, self.entity.icon)
    }
}
