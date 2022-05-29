import Foundation
import CoreFoundationLib
import CoreDomain

class WithdrawMoneyHistoricalPresenter: OperativeStepPresenter<WithdrawMoneyHistoricalViewController, WithdrawMoneyHistoricalNavigatorProtocol, WithdrawMoneyHistoricalPresenterProtocol> {
    
    private lazy var data: WithdrawMoneyHistoricalOperativeData = {
        guard let container = container else {
            fatalError()
        }
        return containerParameter()
    }()
    
    let dispositionsPresenter: (ProductHomeTransactionsPresenter & ProductProfileSeteable)
    
    init(dispositionsPresenter: ProductHomeTransactionsPresenter & ProductProfileSeteable, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: WithdrawMoneyHistoricalNavigatorProtocol) {
        self.dispositionsPresenter = dispositionsPresenter
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let card = data.card else { return }
        
        view.headerViewModel = CardSearchHeaderViewModel(card: card, dependencies: dependencies)
        
        dispositionsPresenter.productProfile = buildProfile()
        dispositionsPresenter.productProfile?.productList(completion: { [weak self] _, _ in
            self?.view.installListPresenter()
            self?.dispositionsPresenter.reloadContent(request: true)
        })
        view.styledTitle = dispositionsPresenter.productProfile?.productTitle
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.HistoricCashWithdrawlCode().page
    }
    
    private func buildProfile() -> WithdrawMoneyHistoricalProfile {
        guard let container = container else {
            fatalError()
        }
        
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        
        return WithdrawMoneyHistoricalProfile(container: container, selectedProduct: data.card, cardDetail: data.cardDetail, signatureWithToken: signatureFilled.signature, dependencies: dependencies, errorHandler: genericErrorHandler, delegate: self, shareDelegate: self)
    }
}

extension WithdrawMoneyHistoricalPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: view, completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view, shouldTriggerHaptic: true)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}

extension WithdrawMoneyHistoricalPresenter: ProductHomeProfileDelegate {
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {}
    
    func showAlert(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType) {
        navigator.showListDialog(title: title, items: items, type: type)
    }
    
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
    
    func goToTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome) {
        guard let dispensation = transactions[selectedPosition] as? Dispensation, let card = data.card else {
            return
        }
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
        
        let input = GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput(card: card, cardDetail: data.cardDetail, dispensation: dispensation)
        
        let useCase = useCaseProvider.getConfirmHistoricalDetailWithdrawMoneyUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let self = self else { return }
            self.hideLoading(completion: {
                self.navigator.goToDetail(of: dispensation, card: card, detail: response.cardDetail, account: response.account, delegate: self)
            })
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.hideLoading(completion: {
                    self.showError(keyDesc: error?.getErrorDesc())
                })
        })
        
    }
    func showCoachmark() {}
    func showAlertInfo(title: LocalizedStylableText?, body message: LocalizedStylableText) {}
    func goToCardPdf(withData data: Data) {}
    func reloadAllIndex(request: Bool) {}
    func clearFilter() {}
    func goToDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, productHome: PrivateMenuProductHome) {}
    func goToMonthsSelection(months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]? = nil) {}
    func goToLiquidation(product: GenericProductProtocol) {}
    func updateIndex (index: Int) {}
    func updateAllIndex() {}
    func updateProductHeader (product: CarouselItem, currentIndex: Int) {}
    func goToSearchStocks(usecase: LoadStockSuperUseCase?) {}
    func goToOrderDetail(with order: Order, stock: StockAccount) {}
    func addExtraRequestResponse(using data: [DateProvider]) {}
    func goStocksDetail(stock: Stock, stockAccount: StockAccount) {}
    func startLoading() {}
    func goToTransactionsPdf(with data: Data, pdfSource: PdfSource, toolbarTitleKey: String) {} 
    func endLoading(completion: (() -> Void)?) {}
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {}
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {}
    func showBillInsuranceEmitterPrompt(onAction: @escaping (() -> Void)) {}
    
}

extension WithdrawMoneyHistoricalPresenter: WithdrawMoneyHistoricalPresenterProtocol {
    var listPresenter: ProductHomeTransactionsPresenter {
        return dispositionsPresenter
    }
    
    func selected(index: Int) {
        
    }
}

extension WithdrawMoneyHistoricalPresenter: HistoricalDispensationDetailPresenterDelegate {
    func userDidTouchCancel() {
        closeButtonTouched()
    }
}
