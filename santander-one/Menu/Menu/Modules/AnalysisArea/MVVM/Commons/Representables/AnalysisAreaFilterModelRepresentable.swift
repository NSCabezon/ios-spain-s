//
//  AnalysisAreaFilterModelRepresentable.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 19/4/22.
//

import CoreFoundationLib

protocol AnalysisAreaFilterModelRepresentable {
    var filtersCount: Int { get }
    var filter: AnalysisAreaFilterRepresentable { get }
    func buildTags() -> [TagMetaData]
    func filterActivesFrom(remainingFilters: [TagMetaData]) -> ActivedFilters?
}

final class DefatultAnalysisAreaFilterModel: AnalysisAreaFilterModelRepresentable {
    private var detailFilter: AnalysisAreaFilterRepresentable
    private var buildedTags: [TagMetaData] = []
    private var tagsWithEntity: [TagMetaData: ActivedFilters] = [:]
    var filtersCount: Int {
        return detailFilter.actives().count
    }
    
    var filter: AnalysisAreaFilterRepresentable {
        return self.detailFilter
    }
    
    init(_ detailFilter: AnalysisAreaFilterRepresentable) {
        self.detailFilter = detailFilter
    }
    
    func buildTags() -> [TagMetaData] {
        var tagsMetadataArray = [TagMetaData]()
        var tagMetaData: TagMetaData?
        self.detailFilter.actives().forEach { filter in
            if case .byDescriptions(let literal) = filter {
                let searchTerm = LocalizedStylableText(text: literal, styles: .none)
                tagMetaData = TagMetaData(withLocalized: searchTerm, accessibilityId: filter.accessibilityIdentifier())
            } else if case .byDateRange(let fromDate, let toDate) = filter {
                tagMetaData = self.buildDatesMetadata(fromDate, toDate: toDate, filter: filter)
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
    
    func filterActivesFrom(remainingFilters: [TagMetaData]) -> ActivedFilters? {
        let previous = Set(self.tagsWithEntity.keys.compactMap { $0 })
        guard let tag = previous.subtracting(Set(remainingFilters)).first else { return nil }
        let filterActive = self.tagsWithEntity[tag]
        self.tagsWithEntity.removeValue(forKey: tag)
        return filterActive
    }
}

private extension DefatultAnalysisAreaFilterModel {
    func buildAmountMetadata(fromAmount: String?, toAmount: String?, filter: ActivedFilters) -> TagMetaData? {
        var localizedText: LocalizedStylableText?
        var tagMetaData: TagMetaData?
        if let fromStr = fromAmount, let toStr = toAmount {
            let fromString = StringPlaceholder(.value, fromStr.amountAndCurrencyWithDecimals())
            let toString = StringPlaceholder(.value, toStr.amountAndCurrencyWithDecimals())
            localizedText = localized(filter.literal(), [fromString, toString])
        } else if let fromStr = fromAmount, toAmount == nil {
            let fromString = StringPlaceholder(.value, fromStr.amountAndCurrencyWithDecimals())
            localizedText = localized(filter.literal(), [fromString])
        } else if let toStr = toAmount {
            let limitString = StringPlaceholder(.value, toStr.amountAndCurrencyWithDecimals())
            localizedText = localized(filter.literal(), [limitString])
        }
        if let optionalLocalizedText = localizedText {
            tagMetaData = TagMetaData(withLocalized: optionalLocalizedText, accessibilityId: filter.accessibilityIdentifier())
        }
        return tagMetaData
    }
    
    private func buildDatesMetadata(_ fromDate: Date?, toDate: Date?, filter: ActivedFilters) -> TagMetaData {
        let key = filter.literal()
        var tagMetaData: TagMetaData!
        
        let fromStr = fromDate?.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        let toStr = toDate?.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        
        if let optionalFromStr = fromStr, let optionalToStr = toStr {
            let dateF = StringPlaceholder(.date, optionalFromStr)
            let dateT = StringPlaceholder(.date, optionalToStr)
            tagMetaData = TagMetaData(withLocalized: localized(key, [dateF, dateT]), accessibilityId: filter.accessibilityIdentifier() )
        } else if let optionalFromStr = fromStr, toStr == nil {
            let dateF = StringPlaceholder(.date, optionalFromStr)
            tagMetaData = TagMetaData(withLocalized: localized(key, [dateF]), accessibilityId: filter.accessibilityIdentifier() )
        } else if let optionalToStr = toStr, fromStr == nil {
            let dateT = StringPlaceholder(.date, optionalToStr)
            tagMetaData = TagMetaData(withLocalized: localized(key, [dateT]), accessibilityId: filter.accessibilityIdentifier() )
        }
        return tagMetaData
    }
}

enum ActivedFilters {
    case byAmount(from: String?, limit: String?)
    case byDateRange(fromDate: Date?, toDate: Date?)
    case byDescriptions(String)
    
    func literal() -> String {
        switch self {
        case .byAmount(let from, let limit):
            if from != nil && limit != nil {
                return "generic_label_valueRangeFilter"
            } else if from != nil && limit == nil {
                return "generic_label_filterFrom"
            }
            return "generic_label_filterTo"
        case .byDateRange(let fromDate, let toDate):
            return "generic_label_dateFilter"
        case .byDescriptions(let descr):
            return descr
        }
    }
    
    func accessibilityIdentifier() -> String {
        switch self {
        case .byAmount:
            return "btnValueRange"
        case .byDateRange(let fromDate, let toDate):
            return "analysisTagFilterViewDate"
        case .byDescriptions(let descr):
            return descr
        }
    }
}

extension ActivedFilters: Equatable {
    public static func == (lhs: ActivedFilters, rhs: ActivedFilters) -> Bool {
        switch (lhs, rhs) {
        case (.byAmount(let fromLhs, let limitLhs), byAmount(let fromRhs, let limitRhs)):
            return fromLhs == fromRhs && limitLhs == limitRhs
        case (.byDateRange(let fromLhs, let limitLhs), .byDateRange(let fromRhs, let limitRhs)):
            return fromLhs == fromRhs && limitLhs == limitRhs
        case (.byDescriptions(let lhs), .byDescriptions(let rhs)):
            return lhs == rhs
        default: return false
        }
    }
}
