import CoreFoundationLib
import UIKit
import CoreDomain

class PensionProfile: BaseProductHomeProfile<Pension, DateRangeSearchParameters, GetPensionTransactionsUseCaseInput, GetPensionTransactionsUseCaseOkOutput, GetPensionTransactionsUseCaseErrorOutput, PensionTransaction>, ProductProfile {
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }

    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().plansHome
    }
    
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var options = [ProductOption]()
    
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("productHome_label_moves").uppercased()
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }

    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_plans")
    }
    
    var isFilterIconVisible: Bool {
        return true
    }
    
    var showNavigationInfo: Bool {
        return true
    }
    
    var navigator: OperativesNavigatorProtocol

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.Pension().page
    }

    override init(selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.navigator = dependencies.navigatorProvider.loanProfileNavigator
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
        getLocations()
    }
    
    override func convertToProductHeader(element: Pension, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI(),
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }

    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Pension] {
        return globalPosition.pensions.get(ordered: true, visibles: true)
    }

    override func paginationFrom(response: GetPensionTransactionsUseCaseOkOutput) -> PaginationDO? {
        return response.transactionList.pagination
    }

    override func transactionsFrom(response: GetPensionTransactionsUseCaseOkOutput) -> [PensionTransaction]? {
        return response.transactionList.transactions
    }

    override func convertToDateProvider(from transaction: PensionTransaction) -> DateProvider {
        return PensionPlanTransactionModelView(transaction, false, dependencies)
    }

    //=================================
    // MARK: - MenuOptions
    //=================================
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        var isAllianz = false
        if let currentPosition = currentPosition, productList.count > currentPosition {
            let product = productList[currentPosition]
            isAllianz = product.isAllianz(filterWith: productConfig.allianzProducts)
        }
        if productConfig.enabledPensionOperations == true && !isAllianz {
            options.append(PensionOptionsHandler.buildExtraInput(dependencies))
            options.append(PensionOptionsHandler.buildPeriodicInput(dependencies))
        }
        options.append(PensionOptionsHandler.buildDetail(dependencies))
        
        if presenterOffers[.CONTRATAR_PLANES] != nil {
            options.append(PensionOptionsHandler.buildPurchasePension(dependencies))
        }
        
        completionOptions?(options)
    }
    
    func product(at position: Int) -> GenericProduct {
        return productList[position]
    }
    
    func optionDidSelected(at index: Int) {
        if let pensions = ProductsOptions.PensionOptions(rawValue: index) {
            switch pensions {
            case .contribution:
                goToExtraordinaryContribution()
            case .periodicInput:
                goToPeriodicContribution()
            case .detail:
                goToDetail()
            case .purchasePension:
                goToPurchasePension()
            }
        }
    }
    
    func goToPeriodicContribution() {
        guard let current = currentPosition else {
            return
        }
        let pension = productList[current]
        launch(forPension: pension, withDelegate: self)
    }

    func goToExtraordinaryContribution() {
        guard let current = currentPosition, let delegate = delegate else {
            return
        }
        let pension = productList[current]
        launchExtraordinaryContribution(pension: pension, delegate: delegate)
    }
    
    func goToDetail() {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToDetail(product: product, productDetail: nil, productHome: .pensions)
        }
    }
    
    func goToPurchasePension() {
        guard let offer = presenterOffers[.CONTRATAR_PLANES],
              let action = offer.action
        else {
            return
        }
        delegate?.executePullOfferAction(
            action: action,
            offerId: offer.id,
            location: .CONTRATAR_PLANES
        )
    }
    
    func transactionDidSelected(at index: Int) {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToTransactionDetail(product: product, transactions: transactionList, selectedPosition: index, productHome: .pensions)
        }
    }

    func showInfo() {
        delegate?.showCoachmark(true)
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        let info = product.getDetailUI()

        return info
    }
    
    override func makeSearchProfile() -> ProductSearchParametersHandler<Pension, DateRangeSearchParameters>? {
        let profile = PensionSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.cacheDelegate = self
        profile.currentProductProvider = self
        profile.searchInputProvider = searchInputProvider
        return profile
    }
}

extension PensionProfile: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
}

extension PensionProfile: ProductLauncherPresentationDelegate {
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        delegate?.showAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
    
    func startLoading() {
        delegate?.startLoading()
    }
    
    func endLoading(completion: (() -> Void)?) {
        delegate?.endLoading(completion: completion)
    }
    
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        delegate?.showAlert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel)
    }
}

extension PensionProfile: PeriodicalContributionLauncher, ExtraordinaryContributionLauncher {
    var navigatorOperative: OperativesNavigatorProtocol {
        return navigator
    }
}

extension PensionProfile: CoachmarkProfile {
    
    var coachmarkToInsertInFirstSeparator: CoachmarkIdentifier? {
        var isAllianz = false
        if let currentPosition = currentPosition, productList.count > currentPosition {
            let product = productList[currentPosition]
            isAllianz = product.isAllianz(filterWith: productConfig?.allianzProducts ?? [])
        }
        return productConfig?.enabledPensionOperations == true && !isAllianz ? .plansHomeContribute : nil
    }
    
    var coachmarkToInsertInSecondSeparator: CoachmarkIdentifier? {
        return nil
    }
    
    var coachmarkToInsertInSearchButton: CoachmarkIdentifier? {
        return nil
    }
    
    func setNextProduct(index: Int) {
    }
    
    var texts: [CoachmarkIdentifier: String] {
        var output = [CoachmarkIdentifier: String]()
        output[.plansHomeContribute] = dependencies.stringLoader.getString("coachmarks_label_plans").text
        return output
    }
    
    var headerIdentifiers: [CoachmarkIdentifier] {
        return []
    }
    
    var transactionIdentifiers: [CoachmarkIdentifier] {
        return [.plansHomeContribute]
    }
}
