//
//  CategoryDetailFilterViewModel.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 9/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib

final class CategoryDetailFilterViewModel {
    private var detailFilter: DetailFilter
    private var buildedTags: [TagMetaData] = []
    private var tagsWithEntity: [TagMetaData: ActiveFilters] = [:]
    var filtersCount: Int {
        return detailFilter.actives().count
    }
    var subcategory: String? {
        return self.detailFilter.getSubcategory()
    }
    var timeFilter: TimePeriodTotalAmountFilterViewModel? {
        return self.detailFilter.getTimeFilter()
    }
    var filter: DetailFilter {
        return self.detailFilter
    }

    init(_ detailFilter: DetailFilter) {
        self.detailFilter = detailFilter
    }
    
    func buildTags() -> [TagMetaData] {
        var tagsMetadataArray = [TagMetaData]()
        var tagMetaData: TagMetaData?
        self.detailFilter.actives().forEach { filter in
            if case .byDescriptions(let literal) = filter {
                let searchTerm = LocalizedStylableText(text: literal, styles: .none)
                tagMetaData = TagMetaData(withLocalized: searchTerm, accessibilityId: filter.accessibilityIdentifier())
            } else if case .byConceptType(let conceptType) = filter {
                tagMetaData = TagMetaData(withLocalized: localized(conceptType.descriptionKey), accessibilityId: filter.accessibilityIdentifier())
            } else if case .byAmount(let from, let limit) = filter {
                tagMetaData = self.buildAmountMetadata(fromAmount: from, toAmount: limit, filter: filter)
            }
            if let tagMetaData = tagMetaData {
                tagsMetadataArray.append(tagMetaData)
                self.tagsWithEntity.updateValue(filter, forKey: tagMetaData)
            }
        }
        self.buildedTags = tagsMetadataArray
        return tagsMetadataArray
    }
    
    func filterActivesFrom(remainingFilters: [TagMetaData]) -> ActiveFilters? {
        let previous = Set(self.tagsWithEntity.keys.compactMap { $0 })
        guard let tag = previous.subtracting(Set(remainingFilters)).first else { return nil }
        return self.tagsWithEntity[tag]
    }
}

private extension CategoryDetailFilterViewModel {
    func buildAmountMetadata(fromAmount: String?, toAmount: String?, filter: ActiveFilters) -> TagMetaData? {
        var localizedText: LocalizedStylableText?
        var tagMetaData: TagMetaData?
        if let fromStr = fromAmount, let toStr = toAmount {
            let fromString = StringPlaceholder(.value, fromStr.amountAndCurrency())
            let toString = StringPlaceholder(.value, toStr.amountAndCurrency())
            localizedText = localized(filter.literal(), [fromString, toString])
        } else if let fromStr = fromAmount, toAmount == nil {
            let fromString = StringPlaceholder(.value, fromStr.amountAndCurrency())
            localizedText = localized(filter.literal(), [fromString])
        } else if let toStr = toAmount {
            let limitString = StringPlaceholder(.value, toStr.amountAndCurrency())
            localizedText = localized(filter.literal(), [limitString])
        }
        if let optionalLocalizedText = localizedText {
            tagMetaData = TagMetaData(withLocalized: optionalLocalizedText, accessibilityId: filter.accessibilityIdentifier())
        }
        return tagMetaData
    }
}
