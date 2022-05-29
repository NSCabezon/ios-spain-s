//
//  AnalysisAreaViewModel.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum AnalysisAreaHomeState: State {
    case idle
    case loadingCompanies(Bool)
    case loadingStatus(Bool)
    case loadingSummary(Bool)
    case showDataOutdatedAlert
    case showNetworkErrorAlert
    case statusInfoReceived(FinancialHealthProductsStatusRepresentable)
    case summaryReceived([AnalysisAreaSummaryItemRepresentable])
    case productsInfoReceived(TotalizatorRepresentable)
    case intervalTimeInfoReceived(UserDataAnalysisAreaRepresentable)
    case showGenericError
    case updateFooter(showAddOtherBank: Bool)
    case showMoreThan90daysPeriod
}

final class AnalysisAreaViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaHomeDependenciesResolver
    private let stateSubject = CurrentValueSubject<AnalysisAreaHomeState, Never>(.idle)
    var state: AnyPublisher<AnalysisAreaHomeState, Never>
    private let locations: [PullOfferLocationRepresentable] = PullOffersLocationsFactoryEntity().analysisArea
    private var offers: [AnalysisAreaCandidateOffer] = [] {
        didSet {
            let otherBanksOffer = getOfferForLocation(AnalysisAreaConstants.addOtherBanks)
            stateSubject.send(.updateFooter(showAddOtherBank: otherBanksOffer != nil))
        }
    }
    private let timeSelectorOutsider = DefaultTimeSelectorOutsider()
    private let updateCompaniesOutsider = DefaultUpdateCompaniesOutsider()
    private var timeSelectorSelected: TimeSelectorRepresentable = DefatultTimeSelectorModel()
    private var periodSelected: PeriodSelectorRepresentable?
    private var companiesWithProductsInfo: [FinancialHealthCompanyRepresentable] = []
    private var selectedProducts: [FinancialHealthProductRepresentable] = []
    private var productsStatus: FinancialHealthProductsStatusRepresentable?
    private var showUpdateError = false
    private var showNetworkError = false
    private var summaryTimer: Timer?
    private let savePeriodSelectedSubject = PassthroughSubject<UserDataAnalysisAreaRepresentable, Never>()
    private let getSummarySubject = PassthroughSubject<GetFinancialHealthSummaryRepresentable, Never>()
    private let getUpdateProductStatusSubject = PassthroughSubject<String, Never>()
    private let getCompaniesProductsStatusAndSummarySubject = PassthroughSubject<(dateFrom: Date, dateTo: Date), Never>()
    private lazy var getCompaniesProductsStatusAndSummaryUseCase: DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase = {
        dependencies.external.resolve()
    }()
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        trackScreen()
        enableLoaders()
        subscribeOffers()
        subscribeTimeSelectorOutsider()
        subscribeUpdateCompaniesOutsider()
        subscribeSummary()
        subscribeCompaniesProductsStatusAndSummary()
        subscribeUpdateProductStatus()
        subscribeGetPeriodSelected()
        subscribeSavePeriodSelected()
        getCompaniesProductsStatusAndSummarySubject.send((dateFrom: periodSelected?.startPeriod ?? Date(),
                                                          dateTo: periodSelected?.endPeriod ?? Date()))
    }
    
    var dataBinding: DataBinding {
        dependencies.resolve()
    }
}

extension AnalysisAreaViewModel {
    func goBack() {
        coordinator.back()
        trackEvent(.clickBack)
        getCompaniesProductsStatusAndSummaryUseCase.productsStatusTimer?.invalidate()
    }
    
    func openPrivateMenu() {
        coordinator.openPrivateMenu()
        trackEvent(.clickPrivateMenu, parameters: [:])
    }
    
    func openSearchView() {
        coordinator.openSearchView()
    }
    
    func didTapToolTip(_ message: (title: LocalizedStylableText, subtitle: LocalizedStylableText)) {
        coordinator.openTooltip(title: message.title, subtitle: message.subtitle)
    }
    
    func didSelectOneFilterSegment(_ index: Int) {
        trackExpenseAnalysisAndSaving(index)
    }
    
    func didTapChangeIntervalTime() {
        coordinator.openChangeIntervalTime(timeSelected: timeSelectorSelected, timeOutsider: timeSelectorOutsider)
        trackEvent(.clickChangeView, parameters: ["data_view": timeSelectorSelected.timeViewSelected.trackValue])
    }
    
    func didTapExpenseView() {
        trackEvent(.clickExpenseView)
    }
    
    func didTapIncomeView() {
        trackEvent(.clickIncomeView)
    }
    
    func didSelectCategory(_ category: CategoryRepresentable) {
        // trackEvent(.selectContent, parameters: ["item_id": data.itemID, "product_category": "financial_health", "content_type": data.type.value])
        let categoryDetailParameters = CategoryDetailParameters(timeSelectorSelected: timeSelectorSelected,
                                                                periodSelected: periodSelected,
                                                                categorySelected: category,
                                                                companiesWithProductsInfo: companiesWithProductsInfo,
                                                                productsSelected: selectedProducts)
        coordinator.openCategoryDetail(categoryDetailParameters: categoryDetailParameters)
    }
    
    func didSelectChartType(_ chartType: ExpensesIncomeCategoriesChartType) {
        switch chartType {
        case .expenses: break
            // stateSubject.send(.summaryReceived(CategoriesListModel(type: .expenses, info: mockExpensesCategories)))
        case .payments: break
            // stateSubject.send(.summaryReceived(CategoriesListModel(type: .payments, info: mockBuyingsCategories)))
        case .incomes: break
            // stateSubject.send(.summaryReceived(CategoriesListModel(type: .income, info: mockIncomesCategories)))
        }
    }
    
    func didTapOpenConfiguration() {
        let info = FromHomeToProductsConfigurationInfo(companies: companiesWithProductsInfo,
                                                       showUpdateError: showUpdateError,
                                                       showNetworkError: showNetworkError,
                                                       productsStatus: productsStatus,
                                                       summaryInput: GetSummary(dateFrom: periodSelected?.startPeriod ?? Date(),
                                                                                dateTo: periodSelected?.endPeriod ?? Date(),
                                                                                products: selectedProducts),
                                                       updateCompaniesOutsider: updateCompaniesOutsider,
                                                       addOtherBanksOffer: getOfferForLocation(AnalysisAreaConstants.addOtherBanks),
                                                       manageOtherBanksOffer: getOfferForLocation(AnalysisAreaConstants.manageOtherBanks))
        coordinator.showProductsConfiguration(info: info)
        trackEvent(.clickConfiguration)
    }
    
    func didTapAddNewBank() {
        guard let offer = getOfferForLocation(AnalysisAreaConstants.addOtherBanks) else { return }
        didSelectOffer(offer)
        trackEvent(.clickAddBank)
    }
    
    func didChangePeriodSelected(_ period: PeriodSelectorRepresentable) {
        summaryTimer?.invalidate()
        periodSelected = period
        let userDataPeriodSelected = UserDataPeriodSelected(periodSelector: periodSelected, timeSelector: timeSelectorSelected)
        savePeriodSelectedSubject.send(userDataPeriodSelected)
        stateSubject.send(.loadingSummary(true))
        if !companiesWithProductsInfo.isEmpty {
            summaryTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
                timer.invalidate()
                self?.getSummary()
            }
        }
    }
    
    func didTapUpdateInfoStatus(_ action: UpdateButtonErrorAction) {
        switch action {
        case .updateProducts(let entitiesCodes):
            entitiesCodes.forEach {
                getUpdateProductStatusSubject.send($0)
            }
        case .updateStatus:
            enableLoaders()
            showUpdateError = false
            getCompaniesProductsStatusAndSummaryUseCase.productsAreUpdated = true
        case .none: return
        }
    }
}

private extension AnalysisAreaViewModel {
    var coordinator: AnalysisAreaCoordinator {
        return dependencies.resolve()
    }
    
    func enableLoaders() {
        stateSubject.send(.loadingCompanies(true))
        stateSubject.send(.loadingStatus(true))
        stateSubject.send(.loadingSummary(true))
    }
    
    func sendTotalizatorData(companiesWithProductsSelected: [FinancialHealthCompanyRepresentable], accountsSelected: Int, cardsSelected: Int) {
        let banksImages: [BankImageRepresentable] = getCompaniesImagesUrls(companiesWithProductsSelected)
        stateSubject.send(.productsInfoReceived(TotalizatorModel(productsInfo: (accountsSelected, cardsSelected),
                                                                 banksImages: banksImages)))
    }
    
    func getCompaniesImagesUrls(_ companies: [FinancialHealthCompanyRepresentable]) -> [BankImageRepresentable] {
        let baseUrlProvider: BaseURLProvider = dependencies.external.resolve()
        let banksImages: [BankImageRepresentable] = companies.compactMap {
            BankImageModel(urlImage: (baseUrlProvider.baseURL ?? "") + ($0.bankImageUrlPath ?? ""),
                           accessibilityLabelKey: "voiceover_bankLogo_es_\($0.companyName?.lowercased() ?? "")")
        }
        return banksImages
    }
    
    func trackExpenseAnalysisAndSaving(_ index: Int) {
        switch index {
        case 0:  trackEvent(.clickExpenseAnalysis)
        case 1:  trackEvent(.clickSaving)
        default: return
        }
    }
    
    func getSummary() {
        stateSubject.send(.loadingSummary(true))
        let startPeriod = periodSelected?.startPeriod ?? Date()
        let endPeriod = periodSelected?.endPeriod ?? Date()
        let summaryInput = GetSummary(dateFrom: startPeriod, dateTo: endPeriod, products: selectedProducts)
        getSummarySubject.send(summaryInput)
    }
    
    func printDataFromProductsConfiguration(_ data: GetUpdateCompaniesOutsiderRepresentable) {
        selectedProducts.removeAll()
        selectedProducts = data.selectedProducts
        companiesWithProductsInfo = data.companies
        sendTotalizatorData(companiesWithProductsSelected: data.companiesWithProductsSelected,
                            accountsSelected: data.accountsSelected,
                            cardsSelected: data.cardsSelected)
        productsStatus = data.productsStatus
        showUpdateError = data.showUpdateError
        showNetworkError = data.showNetworkError
        if let productsStatus = data.productsStatus {
            stateSubject.send(.statusInfoReceived(productsStatus))
        }
        let list = data.summary
            .map { AnalysisAreaSummaryItemRepresentable(itemCode: $0.code, itemMovements: $0.transactions, itemAmount: $0.total, itemPercentage: $0.percentage, itemCurrency: $0.currency, itemTtype: $0.type) }
        stateSubject.send(.summaryReceived(list))
    }
    
    func getOfferForLocation(_ stringTag: String) -> OfferRepresentable? {
        let offerLocation = locations.first { $0.stringTag == stringTag }
        guard let offer = (offers.first { $0.location.stringTag == offerLocation?.stringTag }) else {
            return nil
        }
        return offer.offer
    }
    
    func didSelectOffer(_ offer: OfferRepresentable) {
        coordinator.executeOffer(offer)
    }
}

// MARK: Subscriptions
private extension AnalysisAreaViewModel {
    var offersUseCase: GetAnalysisAreaOffersUseCase {
        return dependencies.resolve()
    }
    
    var getSummaryUseCase: GetAnalysisAreaSummaryUseCase {
        return dependencies.resolve()
    }
    
    var managePeriodSelectedUsecase: ManagePeriodSelectedAnalysisAreaUseCase {
        return dependencies.resolve()
    }
    
    var getUpdateProductStatusUseCase: GetAnalysisAreaUpdateProductStatusUseCase {
        return dependencies.resolve()
    }
    
    func subscribeOffers() {
        offersPublisher()
            .assign(to: \.offers, on: self)
            .store(in: &anySubscriptions)
    }
    
    func subscribeTimeSelectorOutsider() {
        timeSelectorOutsider.publisher
            .sink { [unowned self] timeSelected in
                self.timeSelectorSelected = timeSelected
                let userDataPeriod = UserDataPeriodSelected(periodSelector: nil, timeSelector: timeSelectorSelected)
                stateSubject.send(.intervalTimeInfoReceived(userDataPeriod))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeUpdateCompaniesOutsider() {
        updateCompaniesOutsider.publisher
            .sink { [unowned self] output in
                guard case .data(let data) = output else { return }
                printDataFromProductsConfiguration(data)
            }.store(in: &anySubscriptions)
    }
    
    func subscribeSummary() {
        summaryPublisher()
            .sink(receiveCompletion: { [unowned self] completion in
                guard case .failure = completion else { return }
                showGenericError()
            }, receiveValue: { [unowned self] summary in
                let list = summary
                    .map { AnalysisAreaSummaryItemRepresentable(itemCode: $0.code, itemMovements: $0.transactions, itemAmount: $0.total, itemPercentage: $0.percentage, itemCurrency: $0.currency, itemTtype: $0.type) }
                stateSubject.send(.loadingSummary(false))
                stateSubject.send(.summaryReceived(list))
            }).store(in: &anySubscriptions)
    }
    
    func subscribeSavePeriodSelected() {
        savePeriodSelectedPublisher()
            .sink { _ in }
            .store(in: &anySubscriptions)
    }
    
    func subscribeGetPeriodSelected() {
        getPeriodSelectedPublisher()
            .sink { [unowned self] userDataPeriodSelected in
                if let periodSelected = userDataPeriodSelected?.periodSelector,
                   let timeSelected = userDataPeriodSelected?.timeSelector {
                    self.periodSelected = periodSelected
                    self.timeSelectorSelected = timeSelected
                }
                let userDataPeriod = UserDataPeriodSelected(periodSelector: self.periodSelected, timeSelector: timeSelectorSelected)
                stateSubject.send(.intervalTimeInfoReceived(userDataPeriod))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeUpdateProductStatus() {
        updateProductStatusPublisher()
            .sink { _ in }
            .store(in: &anySubscriptions)
    }
    
    func subscribeCompaniesProductsStatusAndSummary() {
        getCompaniesProductsStatusAndSummaryPublisher()
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else { return }
                self.showGenericError()
            }, receiveValue: { [unowned self] state in
                switch state {
                case .finishedCompanies(let selectedProducts,
                                        let companies,
                                        let companiesWithProductsSelected,
                                        let accountsSelected,
                                        let cardsSelected):
                    stateSubject.send(.loadingCompanies(false))
                    self.selectedProducts = selectedProducts
                    companiesWithProductsInfo = companies
                    sendTotalizatorData(companiesWithProductsSelected: companiesWithProductsSelected,
                                        accountsSelected: accountsSelected,
                                        cardsSelected: cardsSelected)
                    
                case .finishedCompaniesWithUnselectedProducts:
                    showGenericError()
                    
                case .finishedCompaniesWithError:
                    showGenericError()
                    
                case .finishedProductsStatusOK(let productsStatus):
                    stateSubject.send(.loadingStatus(false))
                    showNetworkError = false
                    self.productsStatus = productsStatus
                    stateSubject.send(.statusInfoReceived(productsStatus))
                    
                case .finishedProductsStatusWithError:
                    showNetworkError = true
                    stateSubject.send(.showNetworkErrorAlert)
                    
                case .finishedProductsStatusWithOutdatedAlert:
                    showNetworkError = false
                    showUpdateError = true
                    stateSubject.send(.showDataOutdatedAlert)
                    
                case .finishedSummary(let summary):
                    stateSubject.send(.loadingSummary(false))
                    let list = summary
                        .map { AnalysisAreaSummaryItemRepresentable(itemCode: $0.code, itemMovements: $0.transactions, itemAmount: $0.total, itemPercentage: $0.percentage, itemCurrency: $0.currency, itemTtype: $0.type) }
                    stateSubject.send(.summaryReceived(list))
                    
                case .finishedSummaryWithError:
                    showGenericError()
                    
                default: break
                }
            }).store(in: &anySubscriptions)
    }
}

// MARK: Publishers
private extension AnalysisAreaViewModel {
    func offersPublisher() -> AnyPublisher<[AnalysisAreaCandidateOffer], Never> {
        return offersUseCase
            .fetchCandidateOffersPublisher(locations)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func summaryPublisher() -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        return getSummarySubject
            .map { [unowned self] in
                self.getSummaryUseCase.fechFinancialSummaryPublisher(products: $0)
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func savePeriodSelectedPublisher() -> AnyPublisher<Void, Never> {
        return savePeriodSelectedSubject
            .flatMap { [unowned self] period in
                managePeriodSelectedUsecase
                    .savePeriodSelectorPublisher(userDataAnalysisArea: period)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func getPeriodSelectedPublisher() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never> {
        return managePeriodSelectedUsecase
            .getPeriodSelectorPublisher()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func getCompaniesProductsStatusAndSummaryPublisher() -> AnyPublisher<CompaniesProductsStatusAndSummaryUseCaseState, Error> {
        return getCompaniesProductsStatusAndSummarySubject
            .map { [unowned self] (dateFrom, dateTo) in
                getCompaniesProductsStatusAndSummaryUseCase
                    .fetchFinancialCompaniesProductsStatusAndSummaryPublisher(dateFromSummaryInput: dateFrom, dateToSummaryInput: dateTo)
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
        
    }
    
    func updateProductStatusPublisher() -> AnyPublisher<FinancialHealthProductsStatusRepresentable?, Never> {
        return getUpdateProductStatusSubject
            .flatMap { [unowned self] productCode in
                getUpdateProductStatusUseCase
                    .fechFinancialUpdateProductStatusPublisher(productCode: productCode)
                    .map { $0 }
            }.receive(on: Schedulers.main)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func showGenericError() {
        stateSubject.send(.showGenericError)
    }
}

// MARK: TrackerManager
extension AnalysisAreaViewModel: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: AnalysisAreaFinancialHealthPage {
        return AnalysisAreaFinancialHealthPage()
    }
}

// MARK: Object for summary service
struct GetSummary: GetFinancialHealthSummaryRepresentable {
    var dateFrom: Date
    var dateTo: Date
    var products: [FinancialHealthProductRepresentable]?
}

struct Product: FinancialHealthProductRepresentable {
    var productType: String?
    var productId: String?
}

// MARK: Object to save selected period
struct UserDataPeriodSelected: UserDataAnalysisAreaRepresentable {
    var periodSelector: PeriodSelectorRepresentable?
    var timeSelector: TimeSelectorRepresentable?
}

enum ProductType: String {
    case account = "accounts"
    case creditCard = "creditCards"
}

// MARK: Object to pass info to ProductsConfiguration
struct FromHomeToProductsConfigurationInfo {
    let companies: [FinancialHealthCompanyRepresentable]
    let showUpdateError: Bool
    let showNetworkError: Bool
    let productsStatus: FinancialHealthProductsStatusRepresentable?
    let summaryInput: GetFinancialHealthSummaryRepresentable?
    let updateCompaniesOutsider: UpdateCompaniesOutsider
    let addOtherBanksOffer: OfferRepresentable?
    let manageOtherBanksOffer: OfferRepresentable?
}
