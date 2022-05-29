import CoreFoundationLib
import UIKit
import CoreDomain

class OrdersProfile: BaseProductHomeProfile<StockAccount, DateRangeAndOrderTypeSearchParameter, GetOrderListUseCaseInput, GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput, Order>, ProductProfile {
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    private class OrderDetailRequest: Hashable {
        let position: Int
        let useCaseWrapper: UseCaseWrapper<GetOrderDetailUseCaseInput, GetOrderDetailUseCaseOkOutput, GetOrderDetailUseCaseErrorOutput>
        
        init(position: Int, useCase: UseCaseWrapper<GetOrderDetailUseCaseInput, GetOrderDetailUseCaseOkOutput, GetOrderDetailUseCaseErrorOutput>) {
            self.position = position
            self.useCaseWrapper = useCase
        }
        
        static func == (lhs: OrdersProfile.OrderDetailRequest, rhs: OrdersProfile.OrderDetailRequest) -> Bool {
            return lhs.position == rhs.position
        }
    
        func hash(into hasher: inout Hasher) {
            hasher.combine(position)
        }
        
        func cancel() {
            useCaseWrapper.cancel()
        }
        
    }

    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }
    
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_orders")
    }
        
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("stocks_label_orders").uppercased()
    }
    
    var isFilterIconVisible: Bool {
        return true
    }
    
    var showNavigationInfo: Bool {
        return false
    }
    
    override var hasDefaultRows: Bool {
        return true
    }
    
    override var numberOfDefaultSections: Int {
        return 1
    }
    
    override var needsExtraBottomSpace: Bool {
        return true
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.Orders().page
    }
    
    // MARK: -

    private var orderDetailRequests = Set<OrderDetailRequest>()

    override init(selectedProduct: GenericProduct? = nil, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
        UseCaseWrapper(with: dependencies.useCaseProvider.deleteStockOrdersUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler)
    }
        
    func transactionDidSelected(at index: Int) {
        let order = transactionList[index]
        let stock = productList[currentPosition ?? 0]
        
        guard order.detailRequestStatus == .done else {
            return
        }
        delegate?.goToOrderDetail(with: order, stock: stock)
        
    }
        
    override func convertToProductHeader(element: StockAccount, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAliasUpperCase(),
                                 subtitle: element.getDetailUI(),
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: nil,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [StockAccount] {
        
        if let stockAccount = self.selectedProduct as? StockAccount {
            if let stockAccountType = stockAccount.stockAccountType {
                switch stockAccountType {
                case .RVManaged:
                    return globalPosition.managedRVStockAccounts.get(ordered: true, visibles: true)
                case .RVNotManaged:
                    return globalPosition.notManagedRVStockAccounts.get(ordered: true, visibles: true)
                default: break
                }
            }
        }
        
        return globalPosition.stockAccounts.list
    }
    
    override func paginationFrom(response: GetOrderListUseCaseOkOutput) -> PaginationDO? {
        return response.pagination
    }
    
    override func transactionsFrom(response: GetOrderListUseCaseOkOutput) -> [Order]? {
        return response.orderList
    }
    
    override func convertToDateProvider(from transaction: Order) -> DateProvider {
        return OrderModelView(product: transaction, privateComponent: dependencies)
    }
    
    func displayIndex(index: Int) {
        guard transactionList.count > index else { return }
        let order = transactionList[index]
        guard order.detailRequestStatus != .done, orderDetailRequests.first(where: { $0.position == index }) == nil else {
            return
        }
        let stock = productList[currentPosition ?? 0]
        let input = GetOrderDetailUseCaseInput(stockAccount: stock, order: order)
        let uc = dependencies.useCaseProvider.getOrderDetailUseCase(input: input)
        let ucw = UseCaseWrapper(with: uc,
                                 useCaseHandler: dependencies.useCaseHandler,
                                 errorHandler: errorHandler,
                                 onSuccess: { [weak order, weak self] (response) in
                                    order?.setDetail(detail: response.orderDetail) 
                                    order?.detailRequestStatus = .done
                                    self?.removeDetailRequest(position: index, andCancel: false)
                                    self?.delegate?.updateIndex(index: index)
            },
                                 onGenericErrorType: {[weak order, weak self] (_) in
                                    order?.detailRequestStatus = .done
                                    self?.removeDetailRequest(position: index, andCancel: false)
                                    self?.delegate?.updateIndex(index: index)
        })
        let request = OrderDetailRequest(position: index, useCase: ucw)
        orderDetailRequests.insert(request)
    }
    
    func endDisplayIndex(index: Int) {
        removeDetailRequest(position: index, andCancel: true)
    }
    
    private func removeDetailRequest(position: Int, andCancel cancel: Bool) {
        guard let request = orderDetailRequests.first(where: { $0.position == position }) else {
            return
        }
        orderDetailRequests.remove(request)
        if cancel {
            request.cancel()
        }
    }
    
    override func infoToShareWithCode(_ tag: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        let info = product.getDetailUI()
        guard info.count > 0 else { return nil }

        return info
    }
    
    // MARK: - Menu Options
    
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        completionOptions?([])
    }
    
    override func makeSearchProfile() -> ProductSearchParametersHandler<StockAccount, DateRangeAndOrderTypeSearchParameter>? {
        let profile = OrderSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.cacheDelegate = self
        profile.currentProductProvider = self
        profile.searchInputProvider = searchInputProvider
        return profile
    }
    
}
