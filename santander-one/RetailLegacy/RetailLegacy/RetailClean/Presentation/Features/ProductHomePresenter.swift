import Foundation
import CoreFoundationLib
import Account
import CoreDomain

protocol SyncProductHomeDelegate: class {
    func syncWithProduct(at index: Int) 
}

enum TransactionsBackgroundColor {
    case white
    case gray
}

protocol ProductHomeNavigatorProtocol: MenuNavigator, PullOffersActionsNavigatorProtocol, OperativesNavigatorProtocol {
    func goToProductHomeDialog(withOptions options: [ProductOption], delegate: ProductHomeViewDelegate)
    func goToProductDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, _ productHome: PrivateMenuProductHome)
    func goToTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome, syncDelegate: SyncProductHomeDelegate?, optionsDelegate: ProductOptionsDelegate?)
    func goToLiquidation(product: GenericProductProtocol)
    func goToStockSearch(useCase: LoadStockSuperUseCase?)
    func goToOrderDetail(product: Order, stock: StockAccount)
    func goToStockDetail(stock: Stock, stockAccount: StockAccount)
    func goToTransactionSearch(parameterSetup: SearchParameterCapable, filterChangeDelegate: FilterChangeDelegate)
    func goToMonthsSelection(card: Card, months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]?)
    func goToPdf(with data: Data, pdfSource: PdfSource, toolbarTitleKey: String)
    func showListDialog(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType)
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate)
    func goToLisboaAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams)
    func goToLisboaAccountsOTP(delegate: OtpScaAccountPresenterDelegate)
    func dismiss()
}

extension ProductHomeNavigatorProtocol {

    func goToPdf(with data: Data, pdfSource: PdfSource) {
        goToPdf(with: data, pdfSource: pdfSource, toolbarTitleKey: "toolbar_title_pdfExtract")
    }
    
    func dismiss() {
        _ = (drawer.currentRootViewController as? NavigationController)?.popViewController(animated: true)
    }
}

protocol ProductHomeCoachmarkPresenter {
    var coachmarksInfo: ProductHomeCoachmarksInfo { get }
    func headerCoachmarksDidFinishLoad()
    func transactionCoachmarksDidFinishLoad()
}

class ProductHomeCoachmarksInfo {
    
    var areHeaderCoachmarksLoaded: Bool = false
    var areTransactionCoachmarksLoaded: Bool = false
    
    var areAllCoachmarksLoaded: Bool {
        get {
            return areHeaderCoachmarksLoaded && areTransactionCoachmarksLoaded
        }
        set {
            areHeaderCoachmarksLoaded = newValue
            areTransactionCoachmarksLoaded = newValue
        }
    }
}

class ProductHomePresenter: PrivatePresenter<ProductHomeViewController, ProductHomeNavigatorProtocol, ProductHomePresenterProtocol> {
    weak var syncDelegate: SyncProductHomeDelegate?

    let productHeader: (ProductHomeHeaderPresenter & ProductProfileSeteable)
    let productTransactions: (ProductHomeTransactionsPresenter & ProductProfileSeteable)
    var productProfile: ProductProfile?
    var productHome: PrivateMenuProductHome!
    var coachmarksToBeSet = [CoachmarkIdentifier]()
    private var _viewPositions = [CoachmarkIdentifier: IntermediateRect]()
    private var isLoading: Bool = false
    var coachmarksInfo = ProductHomeCoachmarksInfo()
    var isTutorialOfferPresented: Bool = true

    var selectedProduct: GenericProduct? {
        didSet {
            let productProfileFactory = ProductProfileFactory(selectedProduct: selectedProduct, productHome: productHome,
                                                errorHandler: genericErrorHandler, dependencies: dependencies,
                                                profileDelegate: self, shareDelegate: self)
            if let productProfile = productProfileFactory.makeProfile() {
                productTransactions.productProfile = productProfile
                productTransactions.reloadContent(request: false)
                self.productProfile = productProfile
                productHeader.productProfile = productProfile
                let productTitle = productProfile.productTitle
                if productProfile.showNavigationInfo {
                    view.setInfoTitle(productTitle)
                } else {
                    view.styledTitle = productTitle
                }
            }
        }
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return productProfile?.screenId
    }
    
    override func getTrackParameters() -> [String: String]? {
        return productProfile?.getTrackParameters()
    }

    init(header: ProductHomeHeaderPresenter & ProductProfileSeteable, detail: ProductHomeTransactionsPresenter & ProductProfileSeteable, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: ProductHomeNavigatorProtocol) {
        self.productHeader = header
        self.productTransactions = detail
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        productHeader.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePullOfferTutorial), name: TutorialPullOfferNotifications.closePullOffer, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: TutorialPullOfferNotifications.closePullOffer, object: nil)
    }
    
    @objc private func closePullOfferTutorial() {
        productProfile?.delegate?.showCoachmark(false)
    }
    
    override func viewShown() {
        super.viewShown()
        productProfile?.handleCandidateOffers()
        isTutorialOfferPresented = true
    }
    
    override func updateAliasDidReload() {
        super.updateAliasDidReload()
        selectedProduct = productProfile?.currentProduct
        productHeader.productProfile = productProfile
        productHeader.view.reloadData()
        productTransactions.reloadContent(request: true)
    }
    
    override func globalPositionDidReload() {
        super.globalPositionDidReload()
        selectedProduct = productProfile?.currentProduct
        productTransactions.reloadContent(request: true)
        productHeader.productProfile = productProfile
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        guard let currentPage = productHeader.currentPage else {
            return
        }
        syncDelegate?.syncWithProduct(at: currentPage)
        
    }
}

extension ProductHomePresenter: SyncProductHomeDelegate {
    func syncWithProduct(at index: Int) {
        productHeader.syncWithProduct(at: index)
    }
}

extension ProductHomePresenter: Presenter {
}

extension ProductHomePresenter: GlobalPositionConditionedPresenter {
}

extension ProductHomePresenter: UpdateAliasConditionedPresenter {
    
}

extension ProductHomePresenter: ProductHomePresenterProtocol {

    var header: ViewControllerProxy {
        return productHeader.view
    }

    var detail: ViewControllerProxy {
        return productTransactions.view
    }
    
    var getMenuOption: PrivateMenuOptions? {
        return productProfile?.menuOptionSelected
    }

    func showInfo() {
        productProfile?.showInfo()
    }

    func dismiss() {
        navigator.dismiss()
    }
}

extension ProductHomePresenter: SideMenuCapable {

    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }

    var isSideMenuAvailable: Bool {
        return !isLoading
    }

}

extension ProductHomePresenter: ProductSelectionDelegate {

    func didSelect(itemAt position: Int) {
        productTransactions.didChange(toProductIndex: position)
    }

}

extension ProductHomePresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        isLoading = true
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        isLoading = false
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}

extension ProductHomePresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension ProductHomePresenter: ProductHomeProfileDelegate {
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
    
    func executePullOfferAction(action: OfferActionRepresentable, offerId: String?, location: PullOfferLocation?) {
        executeOffer(action: action, offerId: offerId, location: location)
    }
        
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }    
    
    func addExtraRequestResponse(using data: [DateProvider]) {
        productTransactions.addReceivedData(data)
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
    func goToDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, productHome: PrivateMenuProductHome) {
        self.navigator.goToProductDetail(product: product, productDetail: productDetail, productHome)
    }
    
    func startLoading() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)

        showLoading(info: info)
    }
    
    func goToTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome) {
        if productHome != .productProfileTransaction {
            self.navigator.goToTransactionDetail(product: product, transactions: transactions, selectedPosition: selectedPosition, productHome: productHome, syncDelegate: self, optionsDelegate: productProfile)
        }
    }
    
    func showAlert(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType) {
        navigator.showListDialog(title: title, items: items, type: type)
    }
    
    func goToLiquidation(product: GenericProductProtocol) {
        self.navigator.goToLiquidation(product: product)
    }
    
    func updateIndex (index: Int) {
        productTransactions.updateIndex(index: index)
    }
    
    func updateAllIndex() {
        productTransactions.updateAllIndex()
    }
    
    func reloadAllIndex(request: Bool) {
        productTransactions.reloadContent(request: request)
    }
    
    func clearFilter() {
        productTransactions.clearFilter()
    }

    func updateProductHeader (product: CarouselItem, currentIndex: Int) {
        productHeader.updateProduct(product: product, currentIndex: currentIndex)
    }
    
    func goToSearchStocks(usecase: LoadStockSuperUseCase?) {
        navigator.goToStockSearch(useCase: usecase)
    }
    
    func goStocksDetail(stock: Stock, stockAccount: StockAccount) {
        navigator.goToStockDetail(stock: stock, stockAccount: stockAccount)
    }
    
    func goToOrderDetail(with order: Order, stock: StockAccount) {
        navigator.goToOrderDetail(product: order, stock: stock)
    }
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {
        navigator.goToAccountsOTP(delegate: delegate)
    }
    
    func goToTransactionsPdf(with data: Data, pdfSource: PdfSource, toolbarTitleKey: String) {
        navigator.goToPdf(with: data, pdfSource: pdfSource, toolbarTitleKey: toolbarTitleKey)
    }
    
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, showsCloseButton: false, source: view)
    }
    
    func showAlertInfo(title: LocalizedStylableText?, body message: LocalizedStylableText) {
         Dialog.alert(title: title, body: message, source: view)
    }
    
    func showCoachmark(_ isForced: Bool = true) {
        view.findCoachmarks(neededIds: self.neededIdentifiers) { [weak self] (coachmarks) in
            self?.setCoachmarks(coachmarks: coachmarks, isForcedCoachmark: isForced)
        }
    }
    
    func showBillInsuranceEmitterPrompt(onAction: @escaping (() -> Void)) {}

}

extension ProductHomePresenter: CoachmarkPresenter {
    
    var viewPositions: [CoachmarkIdentifier: IntermediateRect] {
        get {
            return self._viewPositions
        }
        set {
            if newValue.count == 0 {
                self._viewPositions = [CoachmarkIdentifier: IntermediateRect]()
            } else {
                for (key, value) in newValue {
                    self._viewPositions[key] = value
                }
            }
        }
    }
    
    func resetCoachmarks() {
        self.viewPositions = [CoachmarkIdentifier: IntermediateRect]()
        self.coachmarksToBeSet = [CoachmarkIdentifier]()
    }
    
    func setCoachmarks(coachmarks: [CoachmarkIdentifier: IntermediateRect], isForcedCoachmark: Bool) {
        
        let callback: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewPositions.count == strongSelf.neededIdentifiers.count && strongSelf.viewPositions.filter({$0.value != IntermediateRect.zero}).count > 0 {
                UseCaseWrapper(with: strongSelf.useCaseProvider.setCoachmarkSeen(input: SetCoachmarkSeenInput(coachmarkIds: strongSelf.coachmarksToBeSet)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler)
                Coachmark.present(source: strongSelf.view, presenter: strongSelf)
                strongSelf.resetCoachmarks()
            }
        }
        
        if isForcedCoachmark {
            for coachmark in coachmarks where coachmark.value != IntermediateRect.zero {
                if !coachmarksToBeSet.contains(coachmark.key) {
                    self.coachmarksToBeSet.append(coachmark.key)
                }
                self.viewPositions[coachmark.key] = coachmark.value
            }
            if coachmarksToBeSet.count > 0 {
                Coachmark.present(source: self.view, presenter: self)
            }
            return
        }
        
        if coachmarks.count > 0 {
            for coachmark in coachmarks {
                UseCaseWrapper(with: useCaseProvider.isCoachmarkSeen(input: GetCoachmarkStatusUseCaseInput(coachmarkId: coachmark.key)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    if !result.status && coachmark.value != IntermediateRect.zero {
                        //NO SE HA PINTADO
                        if !strongSelf.coachmarksToBeSet.contains(coachmark.key) {
                            strongSelf.coachmarksToBeSet.append(coachmark.key)
                        }
                        strongSelf.viewPositions[coachmark.key] = coachmark.value
                    } else {
                        strongSelf.viewPositions[coachmark.key] = IntermediateRect.zero
                    }
                    callback()
                })
            }
        } else {
            callback()
        }
        
    }
    
    var neededIdentifiers: [CoachmarkIdentifier] {
        var output = [CoachmarkIdentifier]()
        
        if let profile = self.productProfile as? CoachmarkProfile {
            output.append(contentsOf: profile.headerIdentifiers)
            output.append(contentsOf: profile.transactionIdentifiers)
        }
        
        return output
    }
    
    var texts: [CoachmarkIdentifier: String] {
        var output = [CoachmarkIdentifier: String]()
        
        if let profile = self.productProfile as? CoachmarkProfile {
            output = profile.texts
        }
        
        return output
    }
}

extension ProductHomePresenter {
    func actionData() -> ProductWebviewParameters? {
        return productProfile?.actionData()
    }
}

extension ProductHomePresenter: ProductHomeCoachmarkPresenter {
    
    func headerCoachmarksDidFinishLoad() {
        coachmarksInfo.areHeaderCoachmarksLoaded = true
        showCoachmarksIfAllAreLoaded()
    }
    
    func transactionCoachmarksDidFinishLoad() {
        coachmarksInfo.areTransactionCoachmarksLoaded = true
        showCoachmarksIfAllAreLoaded()
    }
    
    func showCoachmarksIfAllAreLoaded() {
        if coachmarksInfo.areAllCoachmarksLoaded && isTutorialOfferPresented {
            view.findCoachmarks(neededIds: self.neededIdentifiers) { [weak self] (coachmarks) in
                self?.setCoachmarks(coachmarks: coachmarks, isForcedCoachmark: false)
                self?.coachmarksInfo.areAllCoachmarksLoaded = false
            }
        }
    }
}
