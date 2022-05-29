import CoreFoundationLib
import UIKit
import CoreDomain

enum PortfolioProductType {
    case transactionFunds
    case transactionPlans
}

final class PortfolioProductProfile: BaseProductHomeProfile<PortfolioProduct, DateRangeSearchParameters, GetPortfolioProductTransactionsUseCaseInput, GetPortfolioProductTransactionsUseCaseOkOutput, GetPortfolioProductTransactionsUseCaseErrorOutput, PortfolioProductTransaction>, ProductProfile {

    var menuOptionSelected: PrivateMenuOptions? {
        return .sofiaInvestments
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().portfoliosHome
    }
    
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var options = [ProductOption]()
    let type: PortfolioProductType
    let productsProfile: [PortfolioProduct]

    init(type: PortfolioProductType, productsProfile: [PortfolioProduct], selectedProduct: GenericProduct? = nil, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.productsProfile = productsProfile
        self.type = type
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
        getLocations()
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }
    
    func product(at position: Int) -> GenericProduct {
        return productList[position]
    }
    
    var productTitle: LocalizedStylableText {
        switch type {
        case .transactionFunds:
            return dependencies.stringLoader.getString("toolbar_title_funds")
        case .transactionPlans:
            return dependencies.stringLoader.getString("toolbar_title_plans")
        }
    }
        
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("productHome_label_moves").uppercased()
    }
    
    var isFilterIconVisible: Bool {
        return true
    }
    
    var showNavigationInfo: Bool {
        return false
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    override func convertToProductHeader(element: PortfolioProduct, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI() ?? "",
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [PortfolioProduct] {
        return productsProfile
    }
    
    override func paginationFrom(response: GetPortfolioProductTransactionsUseCaseOkOutput) -> PaginationDO? {
        return response.transactionList.pagination
    }
    
    override func transactionsFrom(response: GetPortfolioProductTransactionsUseCaseOkOutput) -> [PortfolioProductTransaction]? {
        return response.transactionList.transactions
    }
    
    override func convertToDateProvider(from transaction: PortfolioProductTransaction) -> DateProvider {
        return ProductProfileTransactionModelView(transaction, false, dependencies)
    }
    
    //=================================
    // MARK: - MenuOptions
    //=================================
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        switch type {
        case .transactionFunds:
            if presenterOffers[.FONDO_CARTERA_SUSCRIPCION] != nil {
                options.append(FundOptionsHandler.buildSubscription(dependencies))
            }
            if presenterOffers[.FONDO_CARTERA_TRASPASO] != nil {
                options.append(FundOptionsHandler.buildTransfer(dependencies))
            }
            options.append(FundOptionsHandler.buildDetail(dependencies))
        case .transactionPlans:
            if presenterOffers[.PLAN_CARTERA_APORTACION_EXTRA] != nil {
                options.append(PensionOptionsHandler.buildExtraInput(dependencies))
            }
            if presenterOffers[.PLAN_CARTERA_ALTA_APORTACION] != nil {
                options.append(PensionOptionsHandler.buildPeriodicInput(dependencies))
            }
            options.append(PensionOptionsHandler.buildDetail(dependencies))
        }
        completionOptions?(options)
    }
    
    func optionDidSelected(at index: Int) {
        switch type {
        case .transactionFunds:
            if let funds = ProductsOptions.FundOptions(rawValue: index) {
                switch funds {
                case .detail:
                    goToDetail()
                case .subscription:
                    subscriptionOperative()
                case .transfer:
                    transferOperative()
                case .purchaseFund:
                    // Do nothing
                    break
                }
            }
        case .transactionPlans:
            if let plans = ProductsOptions.PensionOptions(rawValue: index) {
                switch plans {
                case .detail:
                    goToDetail()
                case .contribution:
                    goToExtraordinaryContribution()
                case .periodicInput:
                    goToPeriodicContribution()
                case .purchasePension:
                    // Do nothing
                    break
                }
            }
        }
    }
    
    private func didSelectBanner(location: PullOfferLocation) {
        guard let offer = presenterOffers[location], let action = offer.action else {
            return
        }
        delegate?.executePullOfferAction(action: action, offerId: offer.id, location: location)
    }
    
    func goToPeriodicContribution() {
        didSelectBanner(location: .PLAN_CARTERA_ALTA_APORTACION)
    }
    
    func goToExtraordinaryContribution() {
        didSelectBanner(location: .PLAN_CARTERA_APORTACION_EXTRA)
    }
    
    func subscriptionOperative() {
        didSelectBanner(location: .FONDO_CARTERA_SUSCRIPCION)
    }
    
    func transferOperative() {
        didSelectBanner(location: .FONDO_CARTERA_TRASPASO)
    }
    
    func goToDetail() {
        if let position = currentPosition {
            let portfolioProduct = productList[position]
            delegate?.goToDetail(product: portfolioProduct, productDetail: nil, productHome: .portfolioProductDetail)
        }
    }
    
    func transactionDidSelected(at index: Int) {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToTransactionDetail(product: product, transactions: transactionList, selectedPosition: index, productHome: .portfolioProductTransactionDetail)
        }
    }
    
    func showInfo() {
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        guard let info = product.getDetailUI() else {
            return nil
        }

        return info
    }
    
    override func makeSearchProfile() -> ProductSearchParametersHandler<PortfolioProduct, DateRangeSearchParameters>? {
        let profile = PortfolioProductSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.cacheDelegate = self
        profile.searchInputProvider = searchInputProvider
        return profile
    }
}

extension PortfolioProductProfile: LocationsResolver {
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

extension PortfolioProductProfile {
    func actionData() -> ProductWebviewParameters? {
        guard let current = currentPosition else {
            return nil
        }
        return productsProfile[current]
    }
}
