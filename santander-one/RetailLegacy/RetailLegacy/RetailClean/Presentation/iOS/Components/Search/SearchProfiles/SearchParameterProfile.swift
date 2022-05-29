import Foundation
import CoreFoundationLib

/// Defines the search criteria
///
/// - none: nothing to search
/// - byTerm: search by term
/// - byCaracteristics: search by characteristic
/// - custom: represents a custom criteria defined in the target type
enum SearchCriteria {
    case none
    case byTerm
    case byCharacteristics
    case custom
}

protocol SearchParameterConfigurationProvider {
    var parameters: [TableModelViewSection] { get }
    var searchInputProvider: SearchInputProvider? { get set }
    var searchHeaderCreatable: ViewCreatable.Type { get }
    var searchHeaderViewModel: HeaderViewModelType { get }
    func saveTemporalData(_ value: Bool)
    func searchWithCriteria(_ criteria: SearchCriteria)
}

protocol SearchParameterCapable: SearchParameterConfigurationProvider, TrackerScreenProtocol, DateRangeDescriptionCapable {
    var isPFMRequired: Bool { get }
    var isFiltered: Bool { get }
    var filterDescription: LocalizedStylableText? { get }
    var searchCriteriaDelegate: SearchCriteriaDelegate? { get set }
    var shouldHideDefaultSearchButton: Bool { get }
    var errorDisplayer: ErrorDisplayer? { get set }
    func useCaseForTransactions<Input, Response, Error: StringErrorOutput>(product: GenericProduct, pagination: PaginationDO?) -> UseCase<Input, Response, Error>?
    func clear()
}

protocol DateRangeDescriptionCapable { }

extension DateRangeDescriptionCapable {
    
    func dateRangeDescription(dateFrom: Date?, dateTo: Date?, timeManager: TimeManager, stringLoader: StringLoader) -> String? {
        let dates = (dateFrom, dateTo)
        switch dates {
        case let (nil, to?):
            guard let toText = timeManager.toString(date: to, outputFormat: .d_MMM_yyyy) else {
                return nil
            }
            return stringLoader.getString("search_text_untilDate", [StringPlaceholder(.date, toText)]).text
        case let (from?, nil):
            guard let fromText = timeManager.toString(date: from, outputFormat: .d_MMM_yyyy) else {
                return nil
            }
            return stringLoader.getString("search_text_sinceDate", [StringPlaceholder(.date, fromText)]).text
        case let (from?, to?):
            guard let fromText = timeManager.toString(date: from, outputFormat: .d_MMM_yyyy),
                let toText = timeManager.toString(date: to, outputFormat: .d_MMM_yyyy) else {
                    return nil
            }
            return fromText + " - " + toText
        case (nil, nil):
            return stringLoader.getString("search_text_otherDate").text
        }
    }
    
}
