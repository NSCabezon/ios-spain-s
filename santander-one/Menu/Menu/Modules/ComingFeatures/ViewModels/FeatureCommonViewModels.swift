//
//  FeatureCommonViewModels.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 10/03/2020.
//

import Foundation
import CoreFoundationLib

struct FeaturesViewModel {
    let comingFeatureViewModels: [ComingFeatureViewModel]
    let implementedFeatureViewModels: [ImplementedFeatureViewModel]
    
    func updating(comingFeatureViewModel: ComingFeatureViewModel) -> FeaturesViewModel {
        return FeaturesViewModel(
            comingFeatureViewModels: self.comingFeatureViewModels.map {
                guard $0.entity.identifier == comingFeatureViewModel.entity.identifier else { return $0 }
                return comingFeatureViewModel
            },
            implementedFeatureViewModels: self.implementedFeatureViewModels
        )
    }
    
    func updating(implementedFeatureViewModel: ImplementedFeatureViewModel) -> FeaturesViewModel {
        return FeaturesViewModel(
            comingFeatureViewModels: self.comingFeatureViewModels,
            implementedFeatureViewModels: self.implementedFeatureViewModels.map {
                guard $0.entity.identifier == implementedFeatureViewModel.entity.identifier else { return $0 }
                return implementedFeatureViewModel
            }
        )
    }
}

enum FeatureViewModelState {
    case initial
    case withoutOffer
    case offerLoaded(ratio: Float)
}

protocol FeatureViewModelProtocol {
    var state: FeatureViewModelState { get }
    var offer: FeatureOfferViewModel? { get }
}

struct FeatureOfferViewModel {
    private var dependenciesResolver: DependenciesResolver
    var entity: OfferEntity
    var payload: OfferPayLoad
    private var baseUrl: String?
    
    init(offerEntity: OfferEntity, payload: OfferPayLoad, dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.entity = offerEntity
        self.payload = payload
    }
    
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var previewImageUrl: String? {
        guard let baseUrl = self.baseUrlProvider.baseURL else { return nil }
        return String(format: "%@%@", baseUrl, self.payload.preview)
    }
}

struct ComingFeatureVoteViewModel {
    let entity: ComingFeatureEntity
    
    init(entity: ComingFeatureEntity) {
        self.entity = entity
    }
}
