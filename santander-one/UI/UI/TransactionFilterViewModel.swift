//
//  TransactionFilterViewModel.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 02/03/2020.
//

import CoreFoundationLib
import CoreDomain

final public class TransactionFilterViewModel {
    private var accountFiltersEntity: TransactionFiltersEntity
       
    public var filtersCount: Int {
           return accountFiltersEntity.actives().count
    }
    private var buildedTags: [TagMetaData] = [TagMetaData]()
    private var tagsWithEntity: [TagMetaData: ActiveFilters] = [TagMetaData: ActiveFilters]()
   
    public init(_ filterEntity: TransactionFiltersEntity) {
           self.accountFiltersEntity = filterEntity
    }
    
    public init?(_ transactionFilters: TransactionFiltersRepresentable) {
        guard let transactionFiltersEntity = transactionFilters as? TransactionFiltersEntity else {
            return nil
        }
        self.accountFiltersEntity = transactionFiltersEntity
    }
       
    public func buildTags() -> [TagMetaData] {
        var tagsMetadataArray = [TagMetaData]()
        var tagMetaData: TagMetaData!
        accountFiltersEntity.actives().forEach { filter in
            if case .byDescriptions(let literal) = filter {
                let searchTerm = LocalizedStylableText(text: literal, styles: .none)
                tagMetaData = TagMetaData(withLocalized: searchTerm, accessibilityId: filter.accessibilityIdentifier())
            } else if case .byConceptType(let movementType) = filter {
                tagMetaData = TagMetaData(withLocalized: localized(movementType.descriptionKey), accessibilityId: filter.accessibilityIdentifier())
            } else if case .byCardOperationType(let cardOperationType) = filter {
                tagMetaData = TagMetaData(withLocalized: localized(cardOperationType.descriptionKey), accessibilityId: filter.accessibilityIdentifier())
            } else if case .byAmount(let from, let limit) = filter {
                tagMetaData = self.buildAmountMetadata(fromAmount: from, toAmount: limit, filter: filter)
            } else if case .byTransactionType(let operationType) = filter {
                tagMetaData = TagMetaData(withLocalized: localized(operationType.descriptionKey), accessibilityId: filter.accessibilityIdentifier())
            } else if case .byDateRange(let dateRange) = filter {
                tagMetaData = self.buildDatesMetadata(dateRange.fromDate, toDate: dateRange.toDate, filter: filter)
            } else if case .custome(let option) = filter {
                tagMetaData = TagMetaData(withLocalized: localized(option.literal), accessibilityId: option.accessibilityIdentifier)
            }
            tagsMetadataArray.append(tagMetaData)
            tagsWithEntity.updateValue(filter, forKey: tagMetaData)
        }
        buildedTags = tagsMetadataArray
        return tagsMetadataArray
    }
    
    private func buildedTagsDifference(respectTo tagsArray: [TagMetaData]) -> [TagMetaData] {
        let difference = self.buildedTags.filter({tagsArray.contains($0)})
        return difference
    }
    
    /// return an ActiveFilter referenced by TagMetadata, its like a bridge between metadata (view) and FilterEntity ( model )
    /// - Parameter metadata: the metadata of the view
    public func activeFilter(from metadata: TagMetaData? = nil, remainings: [TagMetaData]) -> ActiveFilters? {
        // compare after being removed from metadata
        let differenceRespectRemainings = self.buildedTags.filter({remainings.contains($0)})
        let current = self.tagsWithEntity.keys.compactMap({$0})
        
        let toBeDeleted = differenceRespectRemainings.diff(from: current)
        guard let removedTag = toBeDeleted.first else {
            return nil
        }
        let entity = self.tagsWithEntity.filter { (key, _) -> Bool in
            return key == removedTag
        }
        let object = entity.first?.value
        return object
    }
}

extension TransactionFilterViewModel {
    private func buildAmountMetadata(fromAmount: String?, toAmount: String?, filter: ActiveFilters) -> TagMetaData {
        var localizedText: LocalizedStylableText?
        var tagMetaData: TagMetaData!

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
   
    private func buildDatesMetadata(_ fromDate: Date?, toDate: Date?, filter: ActiveFilters) -> TagMetaData {
        let key = filter.literal()
        var tagMetaData: TagMetaData!
        
        let fromStr = dateToString(date: fromDate, outputFormat: .dd_MMM_yyyy)
        let toStr = dateToString(date: toDate, outputFormat: .dd_MMM_yyyy)
        
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

extension Array where Element: Hashable {
    func diff(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
