import Foundation
import CoreFoundationLib

class PensionSearchHandler: ProductSearchParametersHandler<Pension, DateRangeSearchParameters> {
    
    override var parameters: [TableModelViewSection] {
        let section = TableModelViewSection()
        let dateRange = SearchParameterDateViewModel(dependencies: dependencies)
        
        dateRange.currentDateFrom = currentParameters.dateFrom
        dateRange.currentDateTo = currentParameters.dateTo
        dateRange.searchInputProvider = searchInputProvider
        dateRange.defaultDateFrom = Date().dateByAdding(years: -1)
        dateRange.enteredDateTo = { [weak self] enteredDate in
            self?.temporalParameters.dateTo = enteredDate
        }
        dateRange.enteredDateFrom = { [weak self] enteredDate in
            self?.temporalParameters.dateFrom = enteredDate
        }
        section.add(item: dateRange)
        
        return [section]
    }
    
    override var searchHeaderViewModel: HeaderViewModelType {
        return PensionSearchHeaderViewModel(pension: product!, dependencies: dependencies)
    }
    
    override var searchHeaderCreatable: ViewCreatable.Type {
        return GenericOperativeHeaderOneLineView.self
    }
    
    override func useCaseForProductTransactions<Input, Response, Error>(product: Pension, pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        let dateFilter = properDateFilter(from: currentParameters.dateFrom, to: currentParameters.dateTo)
        
        let input = GetPensionTransactionsUseCaseInput(pension: product, dateFilter: dateFilter, pagination: pagination)
        return dependencies.useCaseProvider.getPensionTransactionsUseCase(input: input) as? UseCase<Input, Response, Error>
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.PensionsSearch().page
    }

    // MARK: -

    init(currentProductProvider: CurrentProductProvider, dependencies: PresentationComponent) {
        let initialParameters = DateRangeSearchParameters(dateFrom: nil, dateTo: nil)
        super.init(currentProductProvider: currentProductProvider, initialParameters: initialParameters, dependencies: dependencies)
    }
    
    override var filterDescription: LocalizedStylableText? {
        let text =  dateRangeDescription(dateFrom: currentParameters.dateFrom, dateTo: currentParameters.dateTo, timeManager: dependencies.timeManager, stringLoader: dependencies.stringLoader)
        
        if isFiltered, let title = text {
            
            return LocalizedStylableText(text: title, styles: nil)
        }
        
        return nil
    }
    
    override func clear() {
        super.clear()
        currentParameters.dateFrom = nil
        currentParameters.dateTo = nil
        temporalParameters = currentParameters
    }
}
