import UIKit
import Loans
import CoreFoundationLib
import Account
import CoreDomain

public enum StockDetailNavigationOrigin {
    case stocksSearch
    case stocksHome
}

class ProductHomeNavigator: AppStoreNavigator, ProductHomeNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        super.init()
    }
    
    func goToProductHomeDialog(withOptions options: [ProductOption], delegate: ProductHomeViewDelegate) {
        let phPresenter = presenterProvider.productHomeDialogPresenter(withOptions: options)
        phPresenter.view.modalTransitionStyle = .coverVertical
        phPresenter.view.modalPresentationStyle = .overCurrentContext
        phPresenter.view.delegate = delegate
        drawer.present(phPresenter.view, animated: true)
    }
    
    func goToTransactionSearch(parameterSetup: SearchParameterCapable, filterChangeDelegate: FilterChangeDelegate) {
        let productDetailPresenter = presenterProvider.transactionsSearchPresenter(parameterSetup: parameterSetup, filterChangeDelegate: filterChangeDelegate)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(productDetailPresenter.view, animated: true)
    }
    
    func goToProductDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, _ productHome: PrivateMenuProductHome) {
        let productDetailPresenter = presenterProvider.productDetailPresenter
        productDetailPresenter.productHome = productHome
        productDetailPresenter.product = product
        if let productDetail = productDetail {
            productDetailPresenter.productDetail = productDetail
        }
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(productDetailPresenter.view, animated: true)
    }
    
    func goToTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome, syncDelegate: SyncProductHomeDelegate?, optionsDelegate: ProductOptionsDelegate?) {
        switch productHome {
        case .productProfileFund:
            goToProfileTransactionDetail(product: product, transactions: transactions, type: .transactionFunds)
        case .productProfilePlans:
            goToProfileTransactionDetail(product: product, transactions: transactions, type: .transactionPlans)
        case .impositionsHome:
            goToImpositionsHome(product: product, transactions: transactions, selectedPosition: selectedPosition)
        case .productProfileVariableIncomeNotManaged, .productProfileVariableIncomeManaged:
            goToProductProfileVariableIncome(productHome: productHome, product: product)
        case .orders:
            goToOrdersHome(product: product, transactions: transactions, selectedPosition: selectedPosition, syncDelegate: syncDelegate)
        case .cards:
            if case .list(_)? = (transactions[selectedPosition] as? CardMovement)?.transaction {
                goToNormalTransactionDetail(product: product, transactions: transactions, selectedPosition: selectedPosition, productHome: productHome, optionsDelegate: optionsDelegate)
            } else {
                goToNormalTransactionDetail(product: product, transactions: transactions, selectedPosition: selectedPosition, productHome: .cardsPending, optionsDelegate: optionsDelegate)
            }
        default:
            goToNormalTransactionDetail(product: product, transactions: transactions, selectedPosition: selectedPosition, productHome: productHome, optionsDelegate: optionsDelegate)
        }
    }
    
    private func goToProductProfileVariableIncome(productHome: PrivateMenuProductHome, product: GenericProductProtocol) {
        guard let navigator = drawer.currentRootViewController as? NavigationController, let product = product as? PortfolioProduct else {
            return
        }
        let productPresenter: ProductHomePresenter
        let type: StockAccountFromPortfolioProduct
        switch productHome {
        case .productProfileVariableIncomeManaged:
            productPresenter = presenterProvider.productHomePresenterManagedRVStocks
            type = .managed
        case .productProfileVariableIncomeNotManaged:
            productPresenter = presenterProvider.productHomePresenterNotManagedRVStocks
            type = .notManaged
        default:
            return
        }
        productPresenter.productHome = productHome
        productPresenter.selectedProduct = StockAccount.create(product, type: type)
        navigator.pushViewController(productPresenter.view, animated: true)
    }
    
    private func goToNormalTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome, optionsDelegate: ProductOptionsDelegate? = nil) {
        let transactionDetailContainerPresenter = presenterProvider.transactionDetailContainerPresenter
        transactionDetailContainerPresenter.product = product
        transactionDetailContainerPresenter.optionsDelegate = optionsDelegate
        transactionDetailContainerPresenter.transactions = transactions
        transactionDetailContainerPresenter.selectedPosition = selectedPosition
        transactionDetailContainerPresenter.productHome = productHome
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(transactionDetailContainerPresenter.view, animated: true)
    }
    
    private func goToProfileTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], type: PortfolioProductType) {
        guard let selectedProduct = product as? GenericProduct, let profileProducts = transactions as? [PortfolioProduct] else {
            return
        }
        let productPresenter = presenterProvider.productProfileTransactionPresenter
        productPresenter.type = type
        productPresenter.profileProducts = profileProducts
        productPresenter.productHome = .productProfileTransaction
        productPresenter.selectedProduct = selectedProduct
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(productPresenter.view, animated: true)
    }
    
    private func goToImpositionsHome(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int) {
        guard let selectedProduct = product as? GenericProduct, let profileProducts = transactions as? [Imposition] else { return }
        
        let impositionPresente = presenterProvider.productImpositionHomePresenter
        impositionPresente.profileProducts = profileProducts
        impositionPresente.productHome = .impositionsHome
        impositionPresente.selectedProduct = selectedProduct
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(impositionPresente.view, animated: true)
    }
    
    private func goToOrdersHome(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, syncDelegate: SyncProductHomeDelegate?) {
        guard let selectedProduct = product as? GenericProduct else { return }
        let orderPresenter = presenterProvider.productHomePresenter
        orderPresenter.syncDelegate = syncDelegate
        orderPresenter.productHome = .orders
        orderPresenter.selectedProduct = selectedProduct
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(orderPresenter.view, animated: true)
    }
    
    func goToLiquidation(product: GenericProductProtocol) {
        guard let selectedProduct = product as? GenericProduct else { return }
        let liquidationPresenter = presenterProvider.productHomePresenter
        liquidationPresenter.productHome = .liquidation
        liquidationPresenter.selectedProduct = selectedProduct
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(liquidationPresenter.view, animated: true)
    }
    
    func goToStockSearch(useCase: LoadStockSuperUseCase?) {
        guard let usecase = useCase else {
            return
        }
        let presenter = presenterProvider.stockSearchPresenter
        presenter.assignStockLoader(usecase: usecase)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func goToStockDetail(stock: Stock, stockAccount: StockAccount) {
        let stockDetailPresenter = presenterProvider.stockDetailPresenter(stock: stock, stockAccount: stockAccount, stockQuote: nil, origin: .stocksHome)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(stockDetailPresenter.view, animated: true)
    }

    func goToOrderDetail(product: Order, stock: StockAccount) {
        let orderDetailPresenter = presenterProvider.orderDetailPresenter(with: product, stock: stock)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(orderDetailPresenter.view, animated: true)
    }
    
    func goToMonthsSelection(card: Card, months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]? = nil) {
        let monthSelectionPresenter = presenterProvider.monthSelectionDialogPresenter(card: card, withMonths: months, delegate: delegate, placeholders: placeholders)
        monthSelectionPresenter.view.modalTransitionStyle = .crossDissolve
        monthSelectionPresenter.view.modalPresentationStyle = .overCurrentContext
        drawer.present(monthSelectionPresenter.view, animated: true)
    }
    
    // MARK: - PDF
    
    func goToPdf(with data: Data, pdfSource: PdfSource, toolbarTitleKey: String) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: data, title: toolbarTitleKey, pdfSource: pdfSource)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    // MARK: - List dialog
    
    func showListDialog(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType) {
        let dialogPresenter = presenterProvider.listDialogPresenter(title: title, items: items, type: type)
        dialogPresenter.view.modalPresentationStyle = .overCurrentContext
        dialogPresenter.view.modalTransitionStyle = .crossDissolve
        drawer.present(dialogPresenter.view, animated: true)
    }
    
    // MARK: - SCA OTP
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {
        let presenter: OtpScaAccountPresenter = presenterProvider.otpScaAccountPresenter
        presenter.delegate = delegate
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func goToLisboaAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams) {
        let presenter: LisboaOtpScaAccountPresenter = presenterProvider.lisboaOtpScaAccountPresenter
        presenter.delegate = delegate
        presenter.scaTransactionParams = scaTransactionParams
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func goToLisboaAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {
        let presenter: LisboaOtpScaAccountPresenter = presenterProvider.lisboaOtpScaAccountPresenter
        presenter.delegate = delegate
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}
