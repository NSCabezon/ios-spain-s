//
//  AnalysisAreaCategoryDetailViewModel.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 29/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum AnalysisAreaCategoryDetailState: State {
    case idle
    case updateTransactions([FHTransactionListRepresentable])
    case updateNumberOfTransactions(Int)
    case updateCategoryInfoTitle(String)
    case showFullTransactionLoader
    case didUpdateGraphData(BarsGraphViewRepresentable)
    case updateTotalizatorAndSubcategoriesFilter(FHCategoryDetailTotalizatorRepresentable)
    case didRequestedPrior90daysMovement
    case filters(AnalysisAreaFilterModelRepresentable)
    case isFilterApplied(Bool)
    case isPaginationLoading(Bool)
    case showLoading
}

private enum Constants {
    static let SantanderId: String = "0049"
    static let accounts: String = "accounts"
    static let creditCards: String = "creditCards"
}

final class AnalysisAreaCategoryDetailViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaCategoryDetailDependenciesResolver
    private let stateSubject = CurrentValueSubject<AnalysisAreaCategoryDetailState, Never>(.idle)
    var state: AnyPublisher<AnalysisAreaCategoryDetailState, Never>
    private let filterOutsider = DefaultAnalysisAreaFilterOutsider()
    private let getCategorySubject = PassthroughSubject<GetFinancialHealthCategoryInputRepresentable, Never>()
    private let getTransactionsSubject = PassthroughSubject<GetFinancialHealthTransactionsInputRepresentable, Never>()
    @BindingOptional fileprivate var categoryDetailParameters: CategoryDetailParameters?
    private var categoryDetailInfo: [GetFinancialHealthSubcategoryRepresentable] = []
    private var currentOrderedPeriods: [SubcategoryPeriod] = []
    private var currentOrderedColumnsData: [ColumnDataRepresentable]?
    private var currentPeriodSelected: PeriodSelectorRepresentable? {
        didSet {
            // didSelectCurrentPeriod()
            if oldValue != nil {
                createGetTransactions()
            }
            updateTotalizatorAndSubcategoriesInfo()
        }
    }
    private var checkedSubcategories: [FinancialHealthSubcategoryType] = [] {
        didSet {
//            if oldValue.isNotEmpty {
//                createGetTransactions()
//            }
            sendGraphRepresentableWithCheckedSubcategories()
        }
    }
    private var transactionsList: TransactionList?
    private var originScene: AnalysisAreaScene = .home
    private struct TransactionList {
        let transactions: [Date: [GetFinancialHealthTransactionRepresentable]]
    }
    private var filters: AnalysisAreaFilterRepresentable?
    private var nextPage: Bool = false
    private var currentPage: Int = 1
    
    init(dependencies: AnalysisAreaCategoryDetailDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        updateCurrentSelectedPeriod(categoryDetailParameters?.periodSelected)
        configureCategoryInfo()
        subscribeCategoryDetailInfo()
        subscribeTransactions()
        getCategoryDetailFromHomePeriod()
        subscribeFilterOutsider()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

extension AnalysisAreaCategoryDetailViewModel {
    func didTapPDF() {
        coordinator.openViewPDF()
    }
    
    func didTapFilters() {
        coordinator.openFilters(filterOutsider: filterOutsider, filtersApplied: filters)
    }
    
    func didTapMenu() {
        coordinator.openPrivateMenu()
    }
    
    func didTapSearch() {
        coordinator.openSearchView()
    }
    
    func getCategoryDetailFromPeriod(dateFrom: Date?, dateTo: Date?) {
        getCategoryDetail(dateFrom: dateFrom ?? Date(), dateTo: dateTo ?? Date())
    }
    
    func didUpdateCheckedSubcategories(subcategories: [FinancialHealthSubcategoryType]) {
        self.checkedSubcategories = subcategories
    }
    
    func didSelectGraphPeriod(index: Int) {
        let period = currentOrderedPeriods[index]
        let periodRepresentable = PeriodSelectorModel(startPeriod: period.dateFrom ?? Date(),
                                                      endPeriod: period.dateTo ?? Date(),
                                                      indexSelected: 0)
        updateCurrentSelectedPeriod(periodRepresentable)
    }
    
    func showSCAProcess() {
        coordinator.showSCA(delegate: self)
    }
    
    func didCloseSCABottomSheet() {
        goBackToOriginScene()
    }
    
    func removeAllFilters() {
        filters = nil
        transactionsList = nil
        stateSubject.send(.updateNumberOfTransactions(0))
        currentPage = 1
        checkVisiblesViews()
        stateSubject.send(.showFullTransactionLoader)
        getCategoryTransactions()
    }
    
    func removeFilter(_ filter: ActivedFilters?) {
        transactionsList = nil
        stateSubject.send(.updateNumberOfTransactions(0))
        currentPage = 1
        if let removedFilter = filter {
            filters?.removeFilter(removedFilter)
        }
        checkVisiblesViews()
        stateSubject.send(.showFullTransactionLoader)
        getCategoryTransactions()
    }
    
    func loadMoreTransactions() {
        if nextPage {
            stateSubject.send(.isPaginationLoading(true))
            self.currentPage += 1
            getCategoryTransactions(nextPage: self.currentPage)
        }
    }
}

// MARK: - Private Methods
private extension AnalysisAreaCategoryDetailViewModel {
    var coordinator: AnalysisAreaCategoryDetailCoordinator {
        return dependencies.resolve()
    }

    var categoryDetailInfoProducts: [GetCategoryDetailInfoProductInput]? {
        categoryDetailParameters?.productsSelected?.map {
            GetCategoryDetailInfoProductInput(productType: $0.productType,
                                              productId: $0.productId)
        }
    }

    var categoryType: AnalysisAreaCategoryType {
        self.categoryDetailParameters?.categorySelected?.type ?? .otherExpenses
    }
    
    var categorization: AnalysisAreaCategorization {
        return categoryDetailParameters?.categorySelected?.categorization ?? .expenses
    }
    
    var selectedPeriodType: TimeViewOptions {
        categoryDetailParameters?.timeSelectorSelected?.timeViewSelected ?? .mounthly
    }
    
    func configureCategoryInfo() {
        guard let category = categoryDetailParameters?.categorySelected else { return }
        let categoryTitle = category.type.key
        stateSubject.send(.updateCategoryInfoTitle(categoryTitle))
    }
    
    func createGetTransactions() {
        transactionsList = nil
        stateSubject.send(.updateNumberOfTransactions(0))
        currentPage = 1
        stateSubject.send(.showFullTransactionLoader)
        getCategoryTransactions()
    }
    
    func transactionsLoaded(_ transactionsLoaded: [GetFinancialHealthTransactionRepresentable]) {
        stateSubject.send(.isPaginationLoading(false))
        managePagination(numberOfTransactionsLoaded: transactionsLoaded.count)
        let transactionsByDate: [Date: [GetFinancialHealthTransactionRepresentable]] = transactionsLoaded.reduce([:], groupTransactionsByDate)
        let transactionsByDateMerged = transactionsByDate.merging(transactionsList?.transactions ?? [:], uniquingKeysWith: { $0 + $1 })
        transactionsList = TransactionList(transactions: transactionsByDateMerged)
        var transactions: [FHTransactionList] = transactionsByDateMerged.map {
            var transactionList = FHTransactionList()
            transactionList.date = $0.key
            transactionList.items = getTransactionItemsRepresentable(transactions: $0.value)
            return transactionList
        }
        transactions = defaultSorting(transactions)
        let numberOfTransactions = getNumberOfTransactions(transactionList: transactions)
        stateSubject.send(.updateNumberOfTransactions(numberOfTransactions))
        stateSubject.send(.updateTransactions(transactions))
    }
    
    func managePagination(numberOfTransactionsLoaded: Int) {
        nextPage = numberOfTransactionsLoaded == 30
    }
    
    func getNumberOfTransactions(transactionList: [FHTransactionList]) -> Int {
        return transactionList.compactMap { $0.items.count }.reduce(0, +)
    }
    
    func groupTransactionsByDate(_ groupedTransactions: [Date: [GetFinancialHealthTransactionRepresentable]], transaction: GetFinancialHealthTransactionRepresentable) -> [Date: [GetFinancialHealthTransactionRepresentable]] {
        var groupedTransactions = groupedTransactions
        guard let operationDate = transaction.transactionDate else { return groupedTransactions }
        guard
            let dateByDay = groupedTransactions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let transactionsByDate = groupedTransactions[dateByDay]
        else {
            groupedTransactions[operationDate.startOfDay()] = [transaction]
            return groupedTransactions
        }
        groupedTransactions[dateByDay] = transactionsByDate + [transaction]
        return groupedTransactions
    }

    private func defaultSorting(_ transactions: [FHTransactionList]) -> [FHTransactionList] {
        return transactions.sorted(by: { $0.date > $1.date })
    }
    
    func getTransactionItemsRepresentable(transactions: [GetFinancialHealthTransactionRepresentable]) -> [FHTransactionListItemRepresentable] {
        var items: [FHTransactionListItemRepresentable] = []
        transactions.forEach { transaction in
            let productNumber = getProductNumber(productId: transaction.transactionParentId)
            let images = getImages(productId: transaction.transactionParentId)
            let item = FHTransactionListItem(title: transaction.transactionDescription ?? "",
                                             description: localized(transaction.transactionSubCategory?.literalKey ?? ""),
                                             moreInfo: productNumber,
                                             defatultImageName: images.0,
                                             urlImage: images.1,
                                             amount: transaction.transactionTotal ?? AmountEntity(value: 0, currencyCode: "EUR"))
            items.append(item)
        }
        return items
    }
    
    func getProductNumber(productId: String?) -> String {
        var productNumberFormatted = ""
        guard let companyAndProducts = categoryDetailParameters?.companiesWithProductsInfo else { return "" }
        companyAndProducts.forEach {
            $0.companyProducts?.forEach { productInfo in
                productInfo.productData?.forEach { product in
                    if product.id == productId {
                        switch productInfo.productTypeData {
                        case Constants.accounts:
                            productNumberFormatted = getProductNumberFormatted(productNumber: product.iban)
                        case Constants.creditCards:
                            productNumberFormatted = getProductNumberFormatted(productNumber: product.cardNumber)
                        default:
                            productNumberFormatted = ""
                        }
                    }
                }
            }
        }
        return productNumberFormatted
    }
    
    func getImages(productId: String?) -> (String?, String?) {
        var defaultImage: String?
        var urlImage: String?
        guard let companyAndProducts = categoryDetailParameters?.companiesWithProductsInfo else { return (nil, nil) }
        companyAndProducts.forEach { companyInfo in
            companyInfo.companyProducts?.forEach { productInfo in
                productInfo.productData?.forEach { product in
                    if product.id == productId {
                        switch productInfo.productTypeData {
                        case Constants.accounts:
                            defaultImage = "oneIcnBankGenericLogo"
                            urlImage = getUrlImage(urlPath: companyInfo.bankImageUrlPath)
                        case Constants.creditCards:
                            defaultImage = companyInfo.company == Constants.SantanderId ? "oneDefaultCard" : "oneIcnBankGenericCard"
                            urlImage = getUrlImage(urlPath: companyInfo.cardImageUrlPath)
                        default:
                            break
                        }
                    }
                }
            }
        }
        return (defaultImage, urlImage)
    }
    
    func getUrlImage(urlPath: String?) -> String {
        let baseUrlProvider: BaseURLProvider = self.dependencies.external.resolve()
        let baseUrl = baseUrlProvider.baseURL ?? ""
        return baseUrl + (urlPath ?? "")
    }
    
    func getProductNumberFormatted(productNumber: String?) -> String {
        guard let number = productNumber else { return "" }
        return "*" + (number.substring(number.count - 4) ?? "*")
    }
    
    func getCategoryTransactions(nextPage: Int = 1) {
        guard let categorySeleted = categoryDetailParameters?.categorySelected,
              let categoryType = categoryDetailParameters?.categorySelected?.type,
              let currentPeriodSelected = currentPeriodSelected else { return }
        let dateFrom = filters?.fromDate ?? currentPeriodSelected.startPeriod
        let dateTo = filters?.toDate ?? currentPeriodSelected.endPeriod
        let fromAmout: Int? = ((filters?.fromAmount ?? 0.0) as NSDecimalNumber).intValue
        let toAmout: Int? = ((filters?.toAmount ?? 99999999999999999.0) as NSDecimalNumber).intValue
        let textFilter = filters?.transactionDescription
        var scale = categoryDetailParameters?.timeSelectorSelected?.timeViewSelected ?? .mounthly
        let transactionsInput = TransactionsInput(dateFrom: dateFrom,
                                                  dateTo: dateTo,
                                                  page: "\(nextPage)",
                                                  scale: scale,
                                                  category: categorySeleted.type,
                                                  subCategory: checkedSubcategories,
                                                  type: categorySeleted.categorization,
                                                  rangeFrom: fromAmout,
                                                  rangeTo: toAmout,
                                                  text: textFilter,
                                                  products: categoryDetailInfoProducts ?? [])
        self.getTransactionsSubject.send(transactionsInput)        
    }
    
    func getCategoryDetail(dateFrom: Date, dateTo: Date) {
        let category: GetCategoryDetailInfoInput = GetCategoryDetailInfoInput(
            dateFrom: dateFrom,
            dateTo: dateTo,
            scale: selectedPeriodType,
            category: self.categoryType,
            subcategory: checkedSubcategories,
            type: self.categoryDetailParameters?.categorySelected?.categorization ?? .expenses,
            products: categoryDetailInfoProducts)
        getCategorySubject.send(category)
        stateSubject.send(.showLoading)
    }
    
    func getCategoryDetailFromHomePeriod() {
        checkedSubcategories = categoryType.subcategories
        var minDate = Date(timeIntervalSince1970: 1567296000)
        var lastDate = Date(timeIntervalSinceNow: 0)
        if categoryDetailParameters?.timeSelectorSelected?.timeViewSelected == .customized {
            if let startDate = currentPeriodSelected?.startPeriod, let endDate = currentPeriodSelected?.endPeriod {
                minDate = startDate
                lastDate = endDate
            }
        }
        getCategoryDetail(dateFrom: minDate, dateTo: lastDate)
    }
    
    func sendGraphRepresentableWithCheckedSubcategories() {
        guard !categoryDetailInfo.isEmpty else { return }
        var categoryData = getDetailInfoForCheckedSubcategories()
        var periods = categoryData.flatMap { $0.periods }
        let columnDataBars: [GetFinancialHealthSubcategoryPeriodRepresentable] = periods.flatMap { $0 }
        var orderedPeriods = columnDataBars.sorted { ($0.periodDateFrom ?? Date()).compare($1.periodDateFrom ?? Date()) == .orderedAscending }
        var uniqueOrderedPeriods: [SubcategoryPeriod] = getUnqiquePeriods(periods: orderedPeriods)
        var orderedColumnData: [ColumnData] = uniqueOrderedPeriods.enumerated().map {
            var totalAmount: Double = 0
            var secondAmount: Double? = 0
            var expectedAmount: Double = 0
            for period in orderedPeriods {
                if $0.element.dateFrom == period.periodDateFrom && $0.element.dateTo == period.periodDateTo {
                    totalAmount += period.periodAmount?.value?.doubleValue ?? 0
                    expectedAmount += period.periodAmountExpected?.value?.doubleValue ?? 0
                }
            }
            if $0.offset == uniqueOrderedPeriods.count - 1, self.selectedPeriodType == .mounthly {
                secondAmount = expectedAmount
            } else {
                secondAmount = nil
            }
            totalAmount = setZeroIfNeeded(totalAmount: totalAmount)
            return ColumnData(amount: totalAmount, secondAmount: secondAmount,
                              text: getTextFromPeriod(dateFrom: $0.element.dateFrom, dateTo: $0.element.dateTo),
                              index: $0.offset)
        }
        
        currentOrderedPeriods = uniqueOrderedPeriods
        currentOrderedColumnsData = orderedColumnData
        let data = BarsGraphViewData(normalColor: categoryType.color, boldColor: categoryType.darkColor, dataList: orderedColumnData)
        stateSubject.send(.didUpdateGraphData(data))
    }
    
    func getTextFromPeriod(dateFrom: Date?, dateTo: Date?) -> String {
        guard let startDate = dateFrom, let endDate = dateTo else { return "" }
        let manager = PeriodTextManager(startPeriod: startDate, endPeriod: endDate)
        var startFormat = "MMM"
        switch categoryDetailParameters?.timeSelectorSelected?.timeViewSelected ?? .mounthly {
        case .mounthly:
            if startDate.month == 1 { startFormat = "MMM yy" }
            return manager.getMonthText(format: startFormat)
        case .quarterly:
            var endFormat = "MMM"
            if startDate.month == 1 { endFormat = "MMM yy" }
            return manager.getQuarterText("-", startDateFormat: startFormat, endDateFormat: endFormat)
        case .yearly:
            return manager.getAnualText()
        case .customized:
            return manager.getCustomDateText("-")
        }
    }
    
    func updateCheckedSubcategories(_ subcategories: [FinancialHealthSubcategoryType]) {
        self.checkedSubcategories = subcategories
    }
    
    func getDetailInfoForCheckedSubcategories() -> [GetFinancialHealthSubcategoryRepresentable] {
        var info = [GetFinancialHealthSubcategoryRepresentable]()
        categoryDetailInfo.forEach {
            if let subcategory = $0.subcategory, checkedSubcategories.contains(subcategory) {
                info.append($0)
            }
        }
        return info
    }
    
    func updateCurrentSelectedPeriod(_ period: PeriodSelectorRepresentable?) {
        self.currentPeriodSelected = period
    }
    
    func updateTotalizatorAndSubcategoriesInfo() {
        guard let categorySelected = categoryDetailParameters?.categorySelected else { return }
        let data = TotalizatorAndSubcategoriesRepresented(categoryName: categorySelected.type.literalKey,
                                                          categoryIcon: categorySelected.type.iconKey,
                                                          categorization: categorySelected.categorization,
                                                          periodSelected: currentPeriodSelected,
                                                          currency: categorySelected.amount.currency,
                                                          subcategories: categoryDetailInfo)
        stateSubject.send(.updateTotalizatorAndSubcategoriesFilter(data))
    }
    
    func getUnqiquePeriods(periods: [GetFinancialHealthSubcategoryPeriodRepresentable]) -> [SubcategoryPeriod] {
        var list: [SubcategoryPeriod] = periods.map { SubcategoryPeriod(dateFrom: $0.periodDateFrom ?? Date(),
                                                                    dateTo: $0.periodDateTo ?? Date()) }
        var newList = Array(Set(list)).sorted { ($0.dateFrom).compare($1.dateFrom) == .orderedAscending }
        return newList
    }
    
    func isPrior90Days(date: Date) -> Bool {
        guard let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day else { return false }
        return days >= 90
    }
    
    func didSelectCurrentPeriod() {
        if let dateFrom = currentPeriodSelected?.startPeriod,
           isPrior90Days(date: dateFrom) {
            // ** Step 1: Call useCase to get SCA state {
            // if wasPassed in Session {
            //    transactionsList = nil
            //    stateSubject.send(.updateNumberOfTransactions(0))
            //    getCategoryTransactions()
            // } else {
            //  stateSubject.send(.didRequestedPrior90daysMovement)
            // }
        } else {
            transactionsList = nil
            stateSubject.send(.updateNumberOfTransactions(0))
            currentPage = 1
            stateSubject.send(.showFullTransactionLoader)
            getCategoryTransactions()
        }
    }
    
    func goBackToOriginScene() {
        guard originScene == .home else {
            showFilters()
            return
        }
        coordinator.showHome()
    }
    
    func showFilters() {
        originScene = .categoryDetailFilter
    }
    
    func setZeroIfNeeded(totalAmount: Double) -> Double {
        switch categorization {
        case .expenses, .payments:
            if totalAmount >= 0 {
                return 0
            }
            return totalAmount
        case .incomes:
            if totalAmount <= 0 {
                return 0
            }
            return totalAmount
        }
    }
    
    func checkVisiblesViews() {
        if let filters = filters, filters.actives().isNotEmpty {
            stateSubject.send(.isFilterApplied(true))
        } else {
            stateSubject.send(.isFilterApplied(false))
        }
    }
}

// MARK: - Subscriptions

private extension AnalysisAreaCategoryDetailViewModel {
    var getCategoryUseCase: GetAnalysisAreaCategoryDetailInfoUseCase {
        return dependencies.resolve()
    }

    var getTransactionsUseCase: GetAnalysisAreaTransactionsUseCase {
        return dependencies.resolve()
    }
    
    func subscribeCategoryDetailInfo() {
        categoryDetailPublisher()
            .sink(
                receiveCompletion: { [unowned self] completion in
                    guard case .failure = completion else { return }
                    fatalError()
                },
                receiveValue: { [unowned self] detailInfo in
                    self.categoryDetailInfo = detailInfo
                    self.checkedSubcategories = detailInfo.flatMap { $0.subcategory }
                }
            ).store(in: &anySubscriptions)
    }

    func subscribeTransactions() {
        transactionsPublisher()
            .sink(
                receiveCompletion: { [unowned self] completion in
                    guard case .failure = completion else { return }
                    fatalError()
                },
                receiveValue: { [unowned self] transactions in
                    self.transactionsLoaded(transactions)
                }
            ).store(in: &anySubscriptions)
    }
    
    func subscribeFilterOutsider() {
        filterOutsider.publisher
            .sink { [unowned self] filters in
                self.filters = filters
                let filterModel = DefatultAnalysisAreaFilterModel(filters)
                self.stateSubject.send(.filters(filterModel))
                self.transactionsList = nil
                stateSubject.send(.updateNumberOfTransactions(0))
                self.currentPage = 1
                self.checkVisiblesViews()
                stateSubject.send(.showFullTransactionLoader)
                self.getCategoryTransactions()
            }.store(in: &anySubscriptions)
    }
}

// MARK: - Publishers
private extension AnalysisAreaCategoryDetailViewModel {
    func categoryDetailPublisher() -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Never> {
        return getCategorySubject
            .flatMap { [unowned self] category in
                getCategoryUseCase
                    .fetchFinancialCategoryPublisher(categories: category)
            }.receive(on: Schedulers.main)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func transactionsPublisher() -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Never> {
        return getTransactionsSubject
            .flatMap { [unowned self] category in
                getTransactionsUseCase
                    .fetchFinancialTransactionsPublisher(category: category)
            }.receive(on: Schedulers.main)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

extension AnalysisAreaCategoryDetailViewModel: OtpScaAccountPresenterDelegate {
    func otpDidFinishSuccessfully() {
        print("*** SUCCESS")
    }
}

struct SubcategoryPeriod: Hashable {
    let dateFrom: Date
    let dateTo: Date
}

enum AnalysisAreaScene {
    case home
    case categoryDetailFilter
}
