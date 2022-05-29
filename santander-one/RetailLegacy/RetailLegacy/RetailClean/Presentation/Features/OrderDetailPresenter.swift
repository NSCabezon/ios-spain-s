import Foundation
import CoreFoundationLib

protocol OrderDetailNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol, UrlActionsCapable {}

class OrderDetailPresenter: PrivatePresenter<OrderDetailViewController, OrderDetailNavigatorProtocol, OrderDetailPresenterProtocol> {
    
    let order: Order
    let stock: StockAccount
    lazy var sections = [TableModelViewSection]()
    struct Constants {
        let moreInfoUrl: String = "https://infoproductos.bancosantander.es/cssa/StaticBS?blobcol=urldata&blobheadername1=content-type&blobheadername2=Content-Disposition&blobheadervalue1=application%2Fpdf&blobheadervalue2=inline%3B+filename%3Dmas_informacion_rmv.pdf&blobkey=id&blobtable=MungoBlobs&blobwhere=1320598028219&cachecontrol=immediate&ssbinary=true&maxage=3600"
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.OrderDetail().page
    }

    // MARK: -

    init(order: Order, stock: StockAccount, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: OrderDetailNavigatorProtocol) {
        self.order = order
        self.stock = stock
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.barButtons = [.menu]
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_ordersDetail")
        
        switch stock.getOriginFromType() {
        case StockAccountOrigin.rvManaged:
            view.hiddeCancelButton()
        case .rvNotManaged, .regular: break
        }
            
        getOrder()
    }
    
    private func getOrder() {
        let headerSection = TableModelViewSection()
        let headerViewModel = OrderHeaderDetailViewModel(order: order, dependencies: dependencies)
        headerSection.add(item: headerViewModel)
        sections.append(headerSection)
        
        let loadingSection = LoadingSection()
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        loadingSection.add(item: loading)
        sections.append(loadingSection)
        
        if order.situation != .pending {
           view.hiddeCancelButton()
        }
        
        view.reloadData()
        
        getOrderDetail(from: stock, order: order)
    }
    
    private func getOrderDetail(from stock: StockAccount, order: Order) {
        let input = GetOrderDetailUseCaseInput(stockAccount: stock, order: order)
        let uc = dependencies.useCaseProvider.getOrderDetailUseCase(input: input)
        
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
    
            guard let strongSelf = self else { return }
            strongSelf.removeLoading()
            
            let infoSections = TableModelViewSection()
            let titleViewModel = OrderDetailInfoViewModel(titleInfo: strongSelf.stringLoader.getString("ordersDetail_label_organizedTitles"),
                                                          detailInfo: response.orderDetail.orderShares,
                                                          dependencies: strongSelf.dependencies)
            infoSections.add(item: titleViewModel)
            
            let pendindViewModel = OrderDetailInfoViewModel(titleInfo: strongSelf.stringLoader.getString("ordersDetail_label_pendingTitles"),
                                                            detailInfo: response.orderDetail.pendingShares,
                                                            dependencies: strongSelf.dependencies)
            infoSections.add(item: pendindViewModel)
            
            let minCost = OrderDetailInfoViewModel(titleInfo: strongSelf.stringLoader.getString("ordersDetail_label_amount"),
                                                   detailInfo: response.orderDetail.exchange,
                                                   dependencies: strongSelf.dependencies)
            infoSections.add(item: minCost)
            
            let validDate = OrderDetailInfoViewModel(titleInfo: strongSelf.stringLoader.getString("ordersDetail_label_date"),
                                                     detailInfo: response.orderDetail.limitDate != nil ? strongSelf.dateToString(response.orderDetail.limitDate!) : "",
                                                     dependencies: strongSelf.dependencies)
            infoSections.add(item: validDate)
            
            strongSelf.sections.append(infoSections)
            strongSelf.view.reloadData()
            
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.removeLoading()
            strongSelf.view.reloadData()
        })
    }
    
    // MARK: - Privates
    private func removeLoading() {
        if sections.last is LoadingSection {
            sections.removeLast()
            view.dataSource.clearSections()
        }
    }
    
    private func dateToString(_ date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
}

extension OrderDetailPresenter: Presenter {}

extension OrderDetailPresenter: OrderDetailPresenterProtocol {
    var contentTitle: LocalizedStylableText {
        return stringLoader.getString(order.type.orderDescriptionKey)
    }
    
    var moreInfo: LocalizedStylableText {
        return stringLoader.getString("ordersDetail_text_info")
    }
    
    var cancelOrder: LocalizedStylableText {
        return stringLoader.getString("orderDetails_buton_cancelOrder")
    }
    
    func cancelOrderButtonTouched() {
        let useCaseInput = SetupCancelOrderUseCaseInput(stockAccount: stock, order: order)
        let useCase = dependencies.useCaseProvider.setupCancelOrderUseCase(input: useCaseInput)
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            
            guard let strongSelf = self else { return }
            guard let orderDetail = result.orderDetail, let signature = orderDetail.signature else {
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: nil)
                })
                return
                
            }
            strongSelf.hideLoading(completion: {
                let operative = CancelOrderOperative(dependencies: strongSelf.dependencies)
                let operativeData = CancelOrderOperativeData(stockAccount: strongSelf.stock, order: strongSelf.order, dialogTitle: strongSelf.stringLoader.getString("cancelOrder_title_confirm"), dialogMessage: strongSelf.stringLoader.getString("cancelOrder_text_confirm"), acceptTitle: strongSelf.stringLoader.getString("generic_button_accept"))
                strongSelf.navigator.goToOperative(operative, withParameters: [result.operativeConfig, operativeData, signature], dependencies: strongSelf.dependencies)
            })
        }, onError: { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
    
    func moreInfoAction() {
        guard let url = URL(string: Constants().moreInfoUrl) else {
            return
        }
        navigator.open(url)
    }
}

extension OrderDetailPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
