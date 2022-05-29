import CoreFoundationLib
import UIKit
import Foundation
import CoreDomain

class FundProfile: BaseProductHomeProfile<Fund, DateRangeSearchParameters, GetFundTransactionsUseCaseInput, GetFundTransactionsUseCaseOkOutput, GetFundTransactionsUseCaseErrorOutput, FundTransaction>, ProductProfile {
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().fundsHome
    }

    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }

    func product(at position: Int) -> GenericProduct {
        return productList[position]
    }

    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_funds")
    }

    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("productHome_label_moves").uppercased()
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
        return TrackerPagePrivate.Funds().page
    }

    // MARK: -

    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var options = [ProductOption]()

    override init(selectedProduct: GenericProduct?,
                  dependencies: PresentationComponent,
                  errorHandler: GenericPresenterErrorHandler,
                  delegate: ProductHomeProfileDelegate,
                  shareDelegate: ShowShareType?) {
        self.navigator = dependencies.navigatorProvider.fundProfileNavigator
        super.init(selectedProduct: selectedProduct,
                   dependencies: dependencies,
                   errorHandler: errorHandler,
                   delegate: delegate,
                   shareDelegate: shareDelegate)
        getLocations()
    }

    override func convertToProductHeader(element: Fund, position: Int) -> CarouselItem {
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
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }

    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Fund] {
        return globalPosition.funds.get(ordered: true, visibles: true)
    }

    override func paginationFrom(response: GetFundTransactionsUseCaseOkOutput) -> PaginationDO? {
        return response.transactionList.pagination
    }

    override func transactionsFrom(response: GetFundTransactionsUseCaseOkOutput) -> [FundTransaction]? {
        return response.transactionList.transactions
    }

    override func convertToDateProvider(from transaction: FundTransaction) -> DateProvider {
        return FundTransactionModelView(transaction, false, dependencies)
    }

    //=================================
    // MARK: - MenuOptions
    //=================================
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        var isAllianz = false
        if let currentPosition = currentPosition, productList.count > currentPosition {
            let product = productList[currentPosition]
            isAllianz = product.isAllianz
        }
        
        let isBySubscriptionUserConditions = productConfig.fundOperationsSubcriptionNativeMode == true && (!isAllianz && (productConfig.isPB == false || productConfig.isDemo == true))
        let isByTransferUserConditions = productConfig.fundOperationsTransferNativeMode == true && (!isAllianz && (productConfig.isPB == false || productConfig.isDemo == true))        
        let isBySubcriptionNativeMode = productConfig.fundOperationsSubcriptionNativeMode == false && presenterOffers[.FONDO_SUSCRIPCION] != nil
        let isByTransferNativeMode = productConfig.fundOperationsTransferNativeMode == false && presenterOffers[.FONDO_TRASPASO] != nil
        let isTransferEnabled = productList.filter { !$0.isAllianz }.count > 1
        
        if isBySubcriptionNativeMode || isBySubscriptionUserConditions {
            options.append(FundOptionsHandler.buildSubscription(dependencies))
        }
        
        if isTransferEnabled && ( isByTransferNativeMode || isByTransferUserConditions ) {
            options.append(FundOptionsHandler.buildTransfer(dependencies))
        }
        
        options.append(FundOptionsHandler.buildDetail(dependencies))
        if presenterOffers[.CONTRATAR_FONDOS] != nil {
            options.append(FundOptionsHandler.buildPurchaseFund(dependencies))
        }
        
        completionOptions?(options)
    }

     func optionDidSelected(at index: Int) {
        if let funds = ProductsOptions.FundOptions(rawValue: index) {
            switch funds {
            case .subscription:
                subscriptionOperative()
            case .transfer:
                transferOperative()
            case .detail:
                goToDetail()
            case .purchaseFund:
                goToPurchaseFund()
            }
        }
    }

    func goToDetail() {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToDetail(product: product, productDetail: nil, productHome: .funds)
        }
    }
    
    func goToPurchaseFund() {
        guard let offer = presenterOffers[.CONTRATAR_FONDOS],
              let action = offer.action
        else {
            return
        }
        delegate?.executePullOfferAction(
            action: action,
            offerId: offer.id,
            location: .CONTRATAR_FONDOS
        )
    }
    
    private func didSelectBanner(location: PullOfferLocation) {
        guard let offer = presenterOffers[location], let action = offer.action else {
            return
        }
        delegate?.executePullOfferAction(action: action, offerId: offer.id, location: location)
    }
    
    func subscriptionOperative() {
        if productConfig?.fundOperationsSubcriptionNativeMode == false {
            didSelectBanner(location: .FONDO_SUSCRIPCION)
        } else {
            guard let current = currentPosition else {
                return
            }
            let fund = productList[current]
            guard let delegate = delegate else {
                return
            }
            showFundSubscription(fund: fund, delegate: delegate)
        }
    }
    
    func transferOperative() {
        if productConfig?.fundOperationsTransferNativeMode == false {
            didSelectBanner(location: .FONDO_TRASPASO)
        } else {
            guard let current = currentPosition else {
                return
            }
            let fund = productList[current]
            launchTransfer(forFund: fund, withProductList: productList, withDelegate: self)
        }
    }
    
    func transactionDidSelected(at index: Int) {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToTransactionDetail(product: product, transactions: transactionList, selectedPosition: index, productHome: .funds)
        }
    }
    
    func showInfo() {
        delegate?.showCoachmark(true)
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        guard let info = product.getDetailUI() else {
            return nil
        }
        
        return info
    }
    
    override func makeSearchProfile() -> ProductSearchParametersHandler<Fund, DateRangeSearchParameters>? {
        let profile = FundSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.searchInputProvider = searchInputProvider
        profile.cacheDelegate = self
        profile.currentProductProvider = self
        return profile
    }
    
}

extension FundProfile: ProductLauncherPresentationDelegate {
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

extension FundProfile: FundOperativeLauncher, FundOperativeDeepLinkLauncher {}

extension FundProfile: LocationsResolver {
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

extension FundProfile: CoachmarkProfile {
    
    var coachmarkToInsertInFirstSeparator: CoachmarkIdentifier? {
        return .fundsHomeOperate
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
        output[.fundsHomeOperate] = dependencies.stringLoader.getString("coachmarks_label_funds").text
        return output
    }
    
    var headerIdentifiers: [CoachmarkIdentifier] {
        return []
    }
    
    var transactionIdentifiers: [CoachmarkIdentifier] {
        return [.fundsHomeOperate]
    }
}

extension FundProfile {
    func actionData() -> ProductWebviewParameters? {
        guard let current = currentPosition else {
            return nil
        }
        return productList[current]
    }
}
