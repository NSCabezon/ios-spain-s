import CoreFoundationLib
import UI
import CoreDomain

protocol BillHomePresenterProtocol: MenuTextWrapperProtocol {
    var view: BillHomeViewProtocol? { get set }
    func viewDidLoad()
    func openMenu()
    func doSearch()
    func trackTooltip()
    func loadMoreBills()
    func didSelectPayment()
    func didSelectDomicile()
    func didSelectTimeLine()
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel)
    func dismissViewController()
    func didSelectLastBillViewModel(_ viewModel: LastBillViewModel)
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel)
    func didSelectSeePDF(_ viewModel: LastBillViewModel)
    func didSelectFilters()
    func didSelectRemoveFilter(_ remaining: [TagMetaData])
    func segmentedIndexChanged(_ index: Int)
    func nextBillsScrollViewDidEndDecelerating()
    func didTapInOfferBanner(_ offerViewModel: OfferBannerViewModel?)
}

final class BillHomePresenter {
    weak var view: BillHomeViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let viewModelGenerator: ViewModelGenerator
    private var lastBillList = LastBillList()
    private var billRequest = BillRequest()
    private var filters: BillFilter?
    private var lastBillFilterTagAdapter: LastBillFilterTagAdapter?
    private var accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]]?
    private var isBillEmitterPaymentEnable: Bool = false
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.viewModelGenerator = ViewModelGenerator(dependenciesResolver: self.dependenciesResolver)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBills), name: .billOperativeDidFinish, object: nil)
    }
    
    var globalPositionV2UseCase: GetGlobalPositionV2UseCase {
        return dependenciesResolver.resolve(for: GetGlobalPositionV2UseCase.self)
    }
    
    lazy var getFutureBillSuperUseCase: GetFutureBillSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetFutureBillSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    lazy var getLastBillSuperUseCase: GetLastBillSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetLastBillSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    var billConfiguration: BillConfiguration {
        return self.dependenciesResolver.resolve(for: BillConfiguration.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var getAppConfigurationUseCase: GetAppConfigurationUseCase {
        return self.dependenciesResolver.resolve(for: GetAppConfigurationUseCase.self)
    }
    
    var getBillDetailUseCase: GetDetailBillUseCase {
        return self.dependenciesResolver.resolve(for: GetDetailBillUseCase.self)
    }
    
    var getBillPdfDocumentUseCase: GetBillPdfDocumentUseCase {
        return self.dependenciesResolver.resolve(for: GetBillPdfDocumentUseCase.self)
    }
    
    var coordinator: BillHomeCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BillHomeCoordinatorProtocol.self)
    }
    
    var useCaseHandle: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
}

extension BillHomePresenter: BillHomePresenterProtocol {
    func viewDidLoad() {
        self.loadAppConfiguration { [weak self] (isTimeLineEnable, isFutureBillEnable, isGlobalSearchEnabled, isBillEmitterPaymentEnable) in
            guard let strongSelf = self else { return }
            strongSelf.view?.isSearchEnabled = isGlobalSearchEnabled
            strongSelf.setTimeLineConfiguration(isTimeLineEnable)
            strongSelf.setFutureBillConfiguration(isFutureBillEnable)
            strongSelf.loadBills(isFutureBillEnabled: isFutureBillEnable)
            strongSelf.isBillEmitterPaymentEnable = isBillEmitterPaymentEnable
            strongSelf.loadOffer()
        }
        self.trackScreen()
    }

    @objc func updateBills() {
        Async.after(seconds: 0.5) {
           self.removeAllFilters()
        }
    }
    
    func loadMoreBills() {
        guard self.billRequest.isNotWaitingForResponse() else { return }
        guard self.billRequest.allowMoreRequests() else { return }
        self.view?.showPageLoading()
        self.billRequest.addRequest()
        self.getLastBillSuperUseCase.setToDate(self.lastBillList.fromDate)
        self.getLastBillSuperUseCase.execute()
    }
    
    func didSelectLastBillViewModel(_ viewModel: LastBillViewModel) {
        let billsSorted = self.allBillsSortedByDate()
        let detail = LastBillDetail(bill: viewModel.bill, account: viewModel.account)
        let detailList = billsSorted.map { LastBillDetail(bill: $0.bill, account: $0.account) }
        self.coordinator.didSelectLastBill(detail: detail, detailList: detailList)
    }
    
    func dismissViewController() {
        self.coordinator.didSelectDismiss()
    }
    
    func openMenu() {
        self.coordinator.didSelectMenu()
    }
    
    func doSearch() {
        self.coordinator.didSelectSearch()
    }
    
    func didSelectTimeLine() {
        trackEvent(.financial, parameters: [:])
        self.coordinator.didSelectTimeLine()
    }
    
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel) {
        self.coordinator.goToFutureBill(futureBillViewModel.representable,
                                        in: self.allFutureBillsSortedByDate(),
                                        for: futureBillViewModel.account)
    }
    
    func didSelectPayment() {
        trackEvent(.doPayment, parameters: [:])
        self.coordinator.goToPayment(isBillEmitterPaymentEnable)
    }
    
    func didSelectDomicile() {
        trackEvent(.domicile, parameters: [:])
        self.coordinator.goToDirectDebit(with: self.billConfiguration.account)
    }
    
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel) {
        self.view?.showLoadingView({
            self.loadLastBillDetailEntity(viewModel)
        })
    }
    
    func didSelectSeePDF(_ viewModel: LastBillViewModel) {
        self.view?.showLoadingView({
            self.loadBillDocumentPDF(viewModel)
        })
    }
    
    func didSelectFilters() {
        trackEvent(.filter, parameters: [:])
        self.coordinator.goToFilters(filter: filters)
    }
    
    func trackTooltip() {
        self.trackEvent(.tooltip, parameters: [:])
    }
    
    func didSelectRemoveFilter(_ tagsRemaining: [TagMetaData]) {
        if tagsRemaining.isEmpty {
            self.removeAllFilters()
        } else {
            self.removeBillFilter(from: tagsRemaining)
            self.applyBillFilter()
        }
    }
    
    func segmentedIndexChanged(_ index: Int) {
        var billType = ""
        switch index {
        case 0:
            billType = "fecha"
        case 1:
            billType = "emisor"
        case 2:
            billType = "producto"
        default:
            break
        }
        trackEvent(.billType, parameters: [.billType: billType])
    }
    
    func nextBillsScrollViewDidEndDecelerating() {
        trackEvent(.swipe, parameters: [:])
    }
    
    func didTapInOfferBanner(_ offerViewModel: OfferBannerViewModel?) {
        guard let offerEntity = offerViewModel?.offer else {
            return
        }
        coordinator.goToBillFinancing(offerEntity)
    }
}

private extension BillHomePresenter {
    
    func setTimeLineConfiguration(_ isTimeLineEnable: Bool) {
        guard isTimeLineEnable else {
            self.view?.disableTimeLine()
            return
        }
    }
    
    func setFutureBillConfiguration(_ isFutureBillEnable: Bool) {
        guard !isFutureBillEnable else { return }
        self.view?.setFutureBillsHidden()
    }
    
    func loadBills(isFutureBillEnabled: Bool) {
        self.loadGlobalPositionV2 { [weak self] in
            self?.loadLastBills()
            self?.loadFutureBills(isFutureBillEnabled)
        }
    }
    
    func loadFutureBills(_ isFutureBillEnable: Bool) {
        guard isFutureBillEnable else { return }
        self.getFutureBillSuperUseCase.execute()
    }
    
    func loadLastBills() {
        self.getLastBillSuperUseCase.execute()
    }
    
    func loadLastBillsWithFilters() {
        guard self.filters != nil else { return }
        self.lastBillList = LastBillList()
        self.billRequest = BillRequest()
        self.billRequest.setAllowMoreRequest(false)
        self.view?.setMonthsHidden()
        self.view?.showLastBillsLoading()
        self.view?.hideFiltersButton()
        self.getLastBillSuperUseCase.setFilters(filters)
        self.getLastBillSuperUseCase.execute()
    }
    
    func allBillsSortedByDate() ->[(account: AccountEntity, bill: LastBillEntity)] {
        let allBills: [[(account: AccountEntity, bill: LastBillEntity)]]
            = self.lastBillList.bills.map { account, bills in
                return bills.map { (account, $0) }
        }
        return allBills
            .flatMap({ $0 })
            .sorted(by: { $0.bill.expirationDate > $1.bill.expirationDate })
    }
    
    func allFutureBillsSortedByDate() -> [AccountFutureBillRepresentable] {
        return self.accountFutureBills?.values
            .flatMap({ $0 })
            .sorted {
                guard let firstDate = $0.billDateExpiry, let secondDate = $1.billDateExpiry else { return false }
                return firstDate < secondDate
            } ?? []
    }
    
    func setLastBillViewModels() {
        let viewModels = self.viewModelGenerator.lastBillsViewModels(for: self.lastBillList.bills)
        defer {
            self.view?.showFiltersButton()
        }
        if viewModels.isEmpty {
            self.view?.showLastBillsEmpty()
        } else {
            self.view?.showMonths(self.lastBillList.months)
            self.view?.showLastBills(viewModels)
        }
    }
    
    func applyBillFilter() {
        self.setLastBillFilterTags()
        self.loadLastBillsWithFilters()
    }
    
    func setLastBillFilterTags() {
        guard let tagsMetaData = self.lastBillFilterTagAdapter?.getTags() else { return }
        guard !tagsMetaData.isEmpty else { return }
        self.view?.setTagsOnHeader(tagsMetaData)
    }
    
    func removeAllFilters() {
        self.filters = nil
        self.lastBillList = LastBillList()
        self.billRequest = BillRequest()
        self.billRequest.setAllowMoreRequest(false)
        self.view?.removeTagsContainer()
        self.view?.showMonths()
        self.view?.showLastBillsLoading()
        self.view?.hideFiltersButton()
        self.getLastBillSuperUseCase.setToDate(Date())
        self.getLastBillSuperUseCase.setFilters(filters)
        self.getLastBillSuperUseCase.execute()
    }
    
    func removeBillFilter(from tagsRemaining: [TagMetaData]) {
        guard let newFilter = self.lastBillFilterTagAdapter?.getNewFilter(from: tagsRemaining) else { return }
        self.filters = newFilter
    }
    
    // MARK: - Location Banner
    func loadOffer() {
        let location: [PullOfferLocation] = PullOffersLocationsFactoryEntity().billLocation
        Scenario(useCase: getPullOffersCandidatesUseCase,
                 input: GetPullOffersUseCaseInput(locations: location))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.view?.hideLoadingView(nil)
                strongSelf.pullOfferCandidates = result.pullOfferCandidates
                strongSelf.checkBannerLocation()
            }
            .onError { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.view?.hideLoadingView(nil)
            }
    }
    
    func checkBannerLocation() {
        guard let offer = self.pullOfferCandidates?.location(key: BillPullOffers.billPullOffer) else {
            // Update without banner
            self.view?.setOfferBannerLocation(nil)
            return
        }
        let viewModel = OfferBannerViewModel(entity: offer.offer)
        self.view?.setOfferBannerLocation(viewModel)
    }
}

extension BillHomePresenter: GetLastBillSuperUseCaseDelegateDelegate {
    func didFinishLastBillSuccessfully(with response: LastBillResponse) {
        self.lastBillList.set(fromDate: response.fromDate)
        self.lastBillList.set(months: response.months)
        self.lastBillList.append(content: response.accountBills)
        self.view?.hidePageLoading()
        self.setLastBillViewModels()
        self.billRequest.removeRequest()
        if self.filters != nil {
            self.billRequest.setAllowMoreRequest(false)
        } else {
            self.billRequest.setAllowMoreRequest(response.allowMoreRequest)
        }
    }
    
    func didFinishLastBillWithError(_ error: String?) {
        self.billRequest.removeRequest()
        self.billRequest.setAllowMoreRequest(false)
        self.view?.hidePageLoading()
        self.view?.showLastBillsEmpty()
    }
}

extension BillHomePresenter: GetFutureBillSuperUseCaseDelegateDelegate {
    func didFinishFutureBillSuccessfully(with accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]]) {
        self.accountFutureBills = accountFutureBills
        let viewModels = self.viewModelGenerator.futureBillsViewModels(for: accountFutureBills)
        if viewModels.isEmpty {
            self.view?.showFutureBillsEmpty()
        } else {
            self.view?.showFutureBills(viewModels)
        }
    }
    
    func didFinishFutureBillWithError(_ error: String?) {
        self.view?.showFutureBillsEmpty()
    }
}

extension BillHomePresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BillHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.billAndTaxesEventID
        return BillHomePage(emmaToken: emmaToken)
    }
}

extension BillHomePresenter: BillSearchFiltersDelegate {
    func didSelectFilters(_ filter: BillFilter) {
        self.filters = filter
        self.lastBillFilterTagAdapter = LastBillFilterTagAdapter(filter)
        self.applyBillFilter()
    }
}
