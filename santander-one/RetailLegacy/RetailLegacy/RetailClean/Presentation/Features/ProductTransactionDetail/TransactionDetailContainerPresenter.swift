import Foundation
import CoreFoundationLib
import CoreDomain

protocol TransactionDetailNavigatorProtocol: ProductDetailNavigatorProtocol, OperativesNavigatorProtocol {
    func goToPdfViewer(pdfData: Data, pdfSource: PdfSource)
}

class TransactionDetailContainerPresenter: PrivatePresenter<TransactionDetailContainerViewController, TransactionDetailNavigatorProtocol, TransactionDetailContainerPresenterProtocol> {
    var product: GenericProductProtocol?
    var transactions: [GenericTransactionProtocol]?
    var selectedPosition: Int!
    var productHome: PrivateMenuProductHome!
    weak var optionsDelegate: ProductOptionsDelegate?
    var isSideMenuAvailable: Bool {
        return true
    }
    private weak var pullOfferActionPresenter: PullOfferActionsPresenter?

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return nil
    }

    // MARK: -

    override func loadViewData() {
        setTransactionDetailViews()
    }
    
    private func setTransactionDetailViews() {
        if let transactionDetailViewControllers = transactions?.map({ (GenericTransactionProtocol) -> TransactionDetailViewController? in
            let transactionDetailProfileFactory = TransactionDetailProfileFactory(product: product,
                                                                                  transaction: GenericTransactionProtocol,
                                                                                  productHome: productHome,
                                                                                  errorHandler: genericErrorHandler,
                                                                                  dependencies: dependencies,
                                                                                  transactionDetailManager: self)
            guard var transactionDetailProfile = transactionDetailProfileFactory.makeTransactionDetailProfile() else { return nil }

            transactionDetailProfile.optionsDelegate = optionsDelegate
            let transactionDetailPresenter = navigator.presenterProvider.transactionDetailPresenter(with: transactionDetailProfile)
            transactionDetailProfile.delegate = transactionDetailPresenter
            pullOfferActionPresenter = transactionDetailPresenter
            view.styledTitle = stringLoader.getString(transactionDetailProfile.navigationTitleKey)
            return transactionDetailPresenter.view
        }) {
            if let transactionDetailViewControllers = transactionDetailViewControllers as? [TransactionDetailViewController] {
                view.addPages(pages: transactionDetailViewControllers, selectedPosition: selectedPosition)
            }
        }
    }

    func executePullOfferAction(action: OfferActionRepresentable, offerId: String?, location: PullOfferLocation?) {
        pullOfferActionPresenter?.executeOffer(action: action, offerId: offerId, location: location)
    }
    
}

extension TransactionDetailContainerPresenter: TransactionDetailContainerPresenterProtocol {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
}

extension TransactionDetailContainerPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
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

extension TransactionDetailContainerPresenter: ProductLauncherOptionsPresentationDelegate {
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
    
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        self.showError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
    
    func startLoading() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
    func showAlert(title: LocalizedStylableText?,
                   body message: LocalizedStylableText,
                   withAcceptComponent accept: DialogButtonComponents,
                   withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, showsCloseButton: false, source: view)
    }
    
    func goToDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, productHome: PrivateMenuProductHome) {
        navigator.goToProductDetail(product: product, productDetail: productDetail, productHome)
    }
    
    func showBillInsuranceEmitterPrompt(onAction: @escaping (() -> Void)) {
        //track view
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.InsuranceEmittersPage().page, extraParameters: [:])
        view.showInsuranceBillEmitterDialog(onAction: onAction) {
            self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.InsuranceEmittersPage().page,
                                                        eventId: TrackerPagePrivate.InsuranceEmittersPage.Action.end.rawValue,
                                                        extraParameters: [:])
        }
    }

    func goToMonthsSelection(months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]? = nil) {}
}
