import Foundation
import CoreFoundationLib

struct DateRangeAndOrderTypeSearchParameter {
    var dateRange: DateRangeSearchParameters
    var orderSituation: OrderSituationFilter?
}

enum OrderSituationFilter {
    case all
    case pending
    case executed
    case cancelled
    case negotiated
    case rejected
    
    var descriptionKey: String {
        switch self {
        case .all:
            return "search_label_all"
        case .executed:
            return "search_label_executed"
        case .pending:
            return "search_label_pending"
        case .cancelled:
            return "search_label_cancel"
        case .negotiated:
            return "search_label_negotiated"
        case .rejected:
            return "search_label_turnDown"
        }
    }
}

class OrderSearchHandler: ProductSearchParametersHandler<StockAccount, DateRangeAndOrderTypeSearchParameter> {
    
    private var rawOptions: [OrderSituationFilter] = [.all, .pending, .executed, .cancelled, .negotiated, .rejected]
    
    var options: [String] {
        return rawOptions.map({dependencies.stringLoader.getString($0.descriptionKey).text})
    }
    
    override var parameters: [TableModelViewSection] {
        let section = TableModelViewSection()

        let dateRangeViewModel = SearchParameterDateRangeOneRowViewModel(dependencies: dependencies)
        dateRangeViewModel.searchInputProvider = searchInputProvider
        dateRangeViewModel.currentDateFrom = currentParameters.dateRange.dateFrom
        dateRangeViewModel.currentDateTo = currentParameters.dateRange.dateTo
        dateRangeViewModel.defaultDateFrom = Date().dateByAdding(months: -1)
        dateRangeViewModel.bottomSpace = 25
        dateRangeViewModel.enteredDateFrom = { [weak self] enteredDate in
            self?.temporalParameters.dateRange.dateFrom = enteredDate
        }
        dateRangeViewModel.enteredDateTo = { [weak self] enteredDate in
            self?.temporalParameters.dateRange.dateTo = enteredDate
        }
        section.add(item: dateRangeViewModel)
        var currentPosition = 0
        if let situation = currentParameters.orderSituation, let p = rawOptions.firstIndex(of: situation) {
            currentPosition = p
        }
        let orderTypeViewModel = SearchParameterFakePickerViewModel(options: options, currentPosition: currentPosition, dependencies: dependencies)
        orderTypeViewModel.searchInputProvider = searchInputProvider
        orderTypeViewModel.didSelectOption = { [weak self] position in
            self?.temporalParameters.orderSituation = self?.rawOptions[position ?? 0] ?? .all
        }
        section.add(item: orderTypeViewModel)
        
        return [section]
    }
    
    override var searchHeaderViewModel: HeaderViewModelType {
        return OrderSearchHeaderViewModel(stockAccount: product!, dependencies: dependencies)
    }
    
    override var searchHeaderCreatable: ViewCreatable.Type {
        return GenericOperativeHeaderOneLineView.self
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.OrdersSearch().page
    }

    // MARK: -

    init(currentProductProvider: CurrentProductProvider, dependencies: PresentationComponent) {
        let initialParameters = DateRangeAndOrderTypeSearchParameter(dateRange: DateRangeSearchParameters(dateFrom: nil, dateTo: nil), orderSituation: .all)
        super.init(currentProductProvider: currentProductProvider, initialParameters: initialParameters, dependencies: dependencies)
    }

    override func properDateFilter(from dateFrom: Date?, to dateTo: Date?) -> DateFilterDO? {
        if isFiltered {
            return super.properDateFilter(from: dateFrom, to: dateTo)
        } else {
            return DateFilterDO.onMonthLess()
        }
    }
    
    override func useCaseForProductTransactions<Input, Response, Error>(product: StockAccount, pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        if searchCriteria == .byCharacteristics {
            let dateFilter = properDateFilter(from: currentParameters.dateRange.dateFrom, to: currentParameters.dateRange.dateTo)
            let input = GetOrderListUseCaseInput(stockAccount: product, pagination: pagination, dateFilter: dateFilter, orderStatus: currentParameters.orderSituation)
            return dependencies.useCaseProvider.getOrderListFilteredUseCase(input: input) as? UseCase<Input, Response, Error>
        }
        let dateFilter = properDateFilter(from: currentParameters.dateRange.dateFrom, to: currentParameters.dateRange.dateTo)
        let input = GetOrderListUseCaseInput(stockAccount: product, pagination: pagination, dateFilter: dateFilter)
        return dependencies.useCaseProvider.getOrderListUseCase(input: input) as? UseCase<Input, Response, Error>
    }

    override var filterDescription: LocalizedStylableText? {
        let title =  dateRangeDescription(dateFrom: currentParameters.dateRange.dateFrom, dateTo: currentParameters.dateRange.dateTo, timeManager: dependencies.timeManager, stringLoader: dependencies.stringLoader)
        
        if isFiltered, let title = title {
            
            return LocalizedStylableText(text: title, styles: nil)
        }
        
        return nil        
    }
    
    override func clear() {
        super.clear()
        currentParameters.dateRange.dateFrom = nil
        currentParameters.dateRange.dateTo = nil
        currentParameters.orderSituation = .all
        temporalParameters = currentParameters
    }
}
