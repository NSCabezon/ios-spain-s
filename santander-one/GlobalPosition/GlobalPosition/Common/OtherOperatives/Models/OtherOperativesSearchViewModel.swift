//
//  OtherOperativesSearchViewModel.swift
//  GlobalPosition
//
//  Created by alvola on 25/08/2020.
//

import UI
import CoreFoundationLib

final class OtherOperativesSearchViewModel {
    let homeTips: [HelpCenterTipViewModel]
    let help: [TripFaqViewModel]
    let needHelpFor: [TripFaqViewModel]
    let searchTerm: String
    var actions: [GlobalSearchActionViewModel]
    
    var totalResult: Int {
        return help.count
            + needHelpFor.count
            + homeTips.count
            + actions.count
    }
    
    var isEmpty: Bool {
        return help.isEmpty
            && needHelpFor.isEmpty
            && homeTips.isEmpty
            && actions.isEmpty
    }
    
    init(
        homeTips: [HelpCenterTipViewModel],
        help: [TripFaqViewModel],
        needHelpFor: [TripFaqViewModel],
        searchTerm: String,
        actions: [GlobalSearchActionViewModel]
    ) {
        self.help = help
        self.needHelpFor = needHelpFor
        self.searchTerm = searchTerm
        self.homeTips = homeTips
        self.actions = actions
    }
    
    convenience init(
        from usecase: GlobalSearchUseCaseOkOutput,
        baseURL: String,
        searchedTerm: String,
        actionOnShorcutsAppKeywords: [GlobalAppKeywordsEntity]
    ) {
        let helpFAQs = usecase.faqs.map {
            TripFaqViewModel(
                iconName: ($0.icon ?? ""),
                titleKey: $0.question,
                descriptionKey: $0.answer,
                highlightedDescriptionKey: searchedTerm,
                baseURL: baseURL
            )
        }
        
        let needHelpFAQs = usecase.globalFAQs.map {
            TripFaqViewModel(
                iconName: ($0.icon ?? ""),
                titleKey: $0.question,
                descriptionKey: $0.answer,
                highlightedDescriptionKey: searchedTerm,
                baseURL: baseURL
            )
        }
        
        let homeTips = usecase.homeTips?.compactMap({
            HelpCenterTipViewModel(
                $0,
                baseUrl: baseURL,
                highlightedDescriptionKey: searchedTerm
            )
        }) ?? []
        
        let deepLinks = actionOnShorcutsAppKeywords
            .filter({ keyword in
                for key in keyword.keywords {
                    if key.lowercased().contains(searchedTerm.lowercased()) {
                        return true
                    }
                }
                return false
            })
            .map({
                GlobalSearchActionViewModel(
                    iconName: $0.icon,
                    titleKey: $0.title,
                    descriptionKey: "",
                    highlightedDescriptionKey: searchedTerm,
                    baseURL: baseURL,
                    identifier: $0.deepLinkIdentifier,
                    type: .deepLink
                )
            })
        
        self.init(
            homeTips: homeTips,
            help: helpFAQs,
            needHelpFor: needHelpFAQs,
            searchTerm: searchedTerm,
            actions: deepLinks
        )
    }
}
