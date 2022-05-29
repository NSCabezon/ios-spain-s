//
//  ImplementedFeatureViewModels.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 26/02/2020.
//

import Foundation
import CoreFoundationLib

struct ImplementedFeatureViewModel: FeatureViewModelProtocol {
    
    let entity: ImplementedFeatureEntity
    let offer: FeatureOfferViewModel?
    let description: ImplementedFeatureDescriptionViewModel
    let state: FeatureViewModelState

    init(entity: ImplementedFeatureEntity, offer: FeatureOfferViewModel?, description: ImplementedFeatureDescriptionViewModel, state: FeatureViewModelState) {
        self.entity = entity
        self.offer = offer
        self.description = description
        self.state = state
    }
    
    init(from viewModel: ImplementedFeatureViewModel, updating state: FeatureViewModelState) {
        self.init(entity: viewModel.entity, offer: viewModel.offer, description: viewModel.description, state: state)
    }
}

struct ImplementedFeatureDescriptionViewModel {
    let entity: ImplementedFeatureEntity
    let dependenciesResolver: DependenciesResolver
    
    init(entity: ImplementedFeatureEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    var logoURL: String? {
        guard let baseUrl = self.baseUrlProvider.baseURL else { return nil }
        return String(format: "%@%@", baseUrl, self.entity.logo)
    }
    
    var date: String? {
        return self.formattedDate()
    }
    
    var title: String? {
        return self.entity.title
    }
    
    var description: String {
        return self.entity.description
    }
    
    var owner: NSAttributedString {
        return self.ownerAttributedString()
    }
    
    private func ownerAttributedString() -> NSAttributedString {
        let prefix: String = localized("shortly_label_author")
        let owner = entity.owner
        let ownerDescription: String = prefix + " " + owner
        let attrs = [
            NSAttributedString.Key.font: UIFont.santander(family: .text, type: .light, size: 13)
        ]
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 13)
        ]
        let attrStr = NSMutableAttributedString(string: ownerDescription, attributes: attrs)
        let range = NSRange(location: prefix.count + 1, length: owner.count)
        attrStr.setAttributes(boldAttribute, range: range)
        return attrStr
    }
    
    private func formattedDate() -> String? {
        let formattedDate = timeManager.toString(date: self.entity.date.getUtcDate(), outputFormat: .d_MMM_yyyy)
        return formattedDate
    }
}
