import Foundation
import CoreFoundationLib

protocol CacheSearchParameterHandlerDelegate: class {
    func clear()
}

protocol ErrorDisplayer: class {
    func displayError(text: LocalizedStylableText)
}

protocol CurrentProductProvider: class {
    var currentProduct: GenericProduct { get }
}

protocol Clearable {
    func clear()
}

class ProductSearchParametersHandler<T: GenericProduct, X>: SearchParameterCapable {
    var shouldHideDefaultSearchButton: Bool {
        return false
    }

    var isPFMRequired: Bool {
        return false
    }
    
    var isFiltered: Bool {
        return searchCriteria != .none
    }

    var filterDescription: LocalizedStylableText? {
        return nil
    }
    
    var searchCriteria: SearchCriteria = .none
    var currentParameters: X
    var temporalParameters: X
    var parameters: [TableModelViewSection] {
        return [TableModelViewSection]()
    }
    var searchHeaderCreatable: ViewCreatable.Type {
        fatalError()
    }
    var searchHeaderViewModel: HeaderViewModelType {
        fatalError()
    }
    let dependencies: PresentationComponent
    var product: T? {
        return currentProductProvider?.currentProduct as? T
    }
    weak var currentProductProvider: CurrentProductProvider?
    weak var errorDisplayer: ErrorDisplayer?
    weak var searchCriteriaDelegate: SearchCriteriaDelegate?
    weak var cacheDelegate: CacheSearchParameterHandlerDelegate?
    weak var searchInputProvider: SearchInputProvider?

    // MARK: - TrackerScreenProtocol
    
    var screenId: String? {
        return nil
    }
    
    var emmaScreenToken: String? {
        return nil
    }
    
    func getTrackParameters() -> [String: String]? {
        return nil
    }

    // MARK: -

    private var criteriaFields = Set<ClearableSearchSection>()

    func saveTemporalData(_ value: Bool) {
        if value {
            currentParameters = temporalParameters
        }
        criteriaFields.removeAll()
    }
    
    func useCaseForTransactions<Input, Response, Error>(product: GenericProduct, pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        guard let p = product as? T else {
            return nil
        }
        
        return useCaseForProductTransactions(product: p, pagination: pagination)
    }
    
    func useCaseForProductTransactions<Input, Response, Error>(product: T, pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        fatalError()
    }
    
    private func properDateFromWith(_ userDate: Date?) -> Date? {
        guard isFiltered else {
            return nil
        }
        
        return userDate ?? Date(timeIntervalSince1970: 0)
    }
    
    func properDateFilter(from dateFrom: Date?, to dateTo: Date?) -> DateFilterDO? {
        guard isFiltered else {
            return nil
        }
        
        return DateFilterDO.formDate(properDateFromWith(dateFrom), to: dateTo)
    }
    
    func searchWithCriteria(_ criteria: SearchCriteria) {
        saveTemporalData(true)
        searchCriteria = criteria
        cacheDelegate?.clear()
    }
    
    func clear() {
        searchCriteria = .none
        cacheDelegate?.clear()
    }
    
    init(currentProductProvider: CurrentProductProvider, initialParameters: X, dependencies: PresentationComponent) {
        self.currentParameters = initialParameters
        self.temporalParameters = initialParameters
        self.currentProductProvider = currentProductProvider
        self.dependencies = dependencies
    }
    
    // MARK: Clearable Sections
    
    func clearFieldsForAllBut(_ criteria: SearchCriteria) {
        for s in criteriaFields {
            if s.criteria == criteria {
                continue
            }
            s.clearAll()
        }
    }
    
    func addClearableSection(_ section: Clearable, forCriteria criteria: SearchCriteria) {
        if let oldSection = criteriaFields.first(where: { (s) -> Bool in
            s.criteria == criteria
        }) {
            oldSection.addClearableSection(section)
        } else {
            criteriaFields.insert(ClearableSearchSection(criteria: criteria, sections: [section]))
        }
    }
    
}
