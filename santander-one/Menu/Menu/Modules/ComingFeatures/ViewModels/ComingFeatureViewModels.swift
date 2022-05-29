//
//  ComingFeaturesViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/02/2020.
//

import Foundation
import CoreFoundationLib

struct ComingFeatureViewModel: FeatureViewModelProtocol {
    
    let entity: ComingFeatureEntity
    let offer: FeatureOfferViewModel?
    let description: ComingFeatureDescriptionViewModel
    let vote: ComingFeatureVoteViewModel
    let state: FeatureViewModelState

    init(entity: ComingFeatureEntity, offer: FeatureOfferViewModel?, description: ComingFeatureDescriptionViewModel, vote: ComingFeatureVoteViewModel, state: FeatureViewModelState) {
        self.entity = entity
        self.offer = offer
        self.description = description
        self.vote = vote
        self.state = state
    }
    
    init(from viewModel: ComingFeatureViewModel, updating state: FeatureViewModelState) {
        self.init(entity: viewModel.entity, offer: viewModel.offer, description: viewModel.description, vote: viewModel.vote, state: state)
    }
}

struct ComingFeatureDescriptionViewModel {
    let entity: ComingFeatureEntity
    let dependenciesResolver: DependenciesResolver
    
    init(entity: ComingFeatureEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var title: String {
        return entity.title
    }
    
    var description: String {
        return self.entity.description
    }
    
    var owner: NSAttributedString {
        return self.ownerAttributedString()
    }
    
    var logoURL: String? {
        guard let baseUrl = self.baseUrlProvider.baseURL else { return nil }
        return String(format: "%@%@", baseUrl, self.entity.logo)
    }
    
    var date: String? {
        return self.formattedDate()
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
        guard let months = Calendar.current.dateComponents(
            [.month], from: Date().startOfMonth() ?? Date(), to: entity.date).month else { return nil }
        if months > 1 {
            return localized("generic_label_monthsLeft_other",
                             [StringPlaceholder(.number, "\(months)")]).text
        } else if months < 0 {
            return ""
            
        } else {
            return localized("generic_label_monthsLeft_one")
        }
    }
}
