import Foundation
import CoreFoundationLib
import Loans
import CoreDomain

protocol ProductOptionsDelegate: class {
    var generatedOptions: [ProductOption]? { get }
}

protocol DateProvider: AnyObject, TableModelViewProtocol {
    var isFirstTransaction: Bool { get set }
    var transactionDate: Date? { get }
    var shouldDisplayDate: Bool { get set }
}

protocol ProductHomeProfileDelegate: ProductLauncherOptionsPresentationDelegate, ActionDataProvider {
    func goToTransactionDetail(product: GenericProductProtocol, transactions: [GenericTransactionProtocol], selectedPosition: Int, productHome: PrivateMenuProductHome)
    func goToLiquidation(product: GenericProductProtocol)
    func updateIndex (index: Int)
    func updateAllIndex()
    func reloadAllIndex(request: Bool)
    func clearFilter()
    func updateProductHeader (product: CarouselItem, currentIndex: Int)
    func goToSearchStocks(usecase: LoadStockSuperUseCase?)
    func goToOrderDetail(with order: Order, stock: StockAccount)
    func addExtraRequestResponse(using data: [DateProvider])
    func goStocksDetail(stock: Stock, stockAccount: StockAccount)
    func goToTransactionsPdf(with data: Data, pdfSource: PdfSource, toolbarTitleKey: String)
    func showAlertInfo(title: LocalizedStylableText?, body message: LocalizedStylableText)
    func showAlert(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType)
    func showCoachmark(_ isForced: Bool)
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate)
}

extension ProductHomeProfileDelegate {
    func showCoachmark(_ isForced: Bool = true) {}
}

protocol ProductLauncherOptionsPresentationDelegate: ProductLauncherPresentationDelegate, OperativeLauncherDelegate, TrackerEventProtocol {
    func goToDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, productHome: PrivateMenuProductHome)
    func executePullOfferAction(action: OfferActionRepresentable, offerId: String?, location: PullOfferLocation?)
    func showBillInsuranceEmitterPrompt(onAction: @escaping (() -> Void))
}

extension ProductLauncherOptionsPresentationDelegate {
    func executePullOfferAction(action: OfferActionRepresentable, offerId: String?, location: PullOfferLocation?) {}
}

protocol ProductLauncherPresentationDelegate: class {
    func startLoading()
    func endLoading(completion: (() -> Void)?)
    func showAlert(title: LocalizedStylableText?,
                   body message: LocalizedStylableText,
                   withAcceptComponent accept: DialogButtonComponents,
                   withCancelComponent cancel: DialogButtonComponents?)
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?)
}

typealias ProductOption = (title: LocalizedStylableText, imageKey: String, index: Int)

protocol ProductProfile: ProductOptionsDelegate, ActionDataProvider, TrackerScreenProtocol {
    var productTitle: LocalizedStylableText { get }
    var transactionHeaderTitle: LocalizedStylableText? { get }
    var isMorePages: Bool { get }
    var loadingPlaceholder: Placeholder {get}
    var loadingTopInset: Double { get }
    var delegate: ProductHomeProfileDelegate? {get}
    var currentProduct: GenericProduct { get }
    var needsExtraBottomSpace: Bool { get }
    var showPdfAction: (() -> Void)? { get set }
    func productList(completion: @escaping ([CarouselItem], _ selectedIndex: Int) -> Void)
    func selectProduct(at position: Int)
    func loadProductConfig(_ completion: @escaping () -> Void)
    func requestTransactions(fromBeginning isFromBeginning: Bool, completion: @escaping ([DateProvider]) -> Void)
    var completionOptions: (([ProductOption]) -> Void)? { get set }
    var productConfig: ProductConfig? { get set }
    func optionDidSelected(at index: Int)
    func startSecondaryRequest()
    var isFilterIconVisible: Bool { get }
    var isHeaderCellHidden: Bool { get }
    var showNavigationInfo: Bool { get }
    func transactionDidSelected(at index: Int)
    func showInfo()
    func displayIndex(index: Int)
    func endDisplayIndex(index: Int)
    var hasDefaultRows: Bool { get }
    var numberOfDefaultSections: Int { get }
    var searchProfile: SearchParameterCapable? { get set }
    func addExtraHeaderSection(section: TableModelViewSection)
    var optionsBackgroundColor: BackgroundColor { get }
    func handleCandidateOffers()
    var menuOptionSelected: PrivateMenuOptions? { get }
}

extension ProductProfile {
    func displayIndex(index: Int) {}
    func endDisplayIndex(index: Int) {}
    func optionDidSelected(at index: Int) {}
    func showInfo() {}
    func startSecondaryRequest() {}
    func requestTransactions(completion: @escaping ([DateProvider]) -> Void) {
        requestTransactions(fromBeginning: false, completion: completion)
    }
    
    var optionsBackgroundColor: BackgroundColor {
        return .gray
    }
    func handleCandidateOffers() {}
    
    var menuOptionSelected: PrivateMenuOptions? {
        return nil
    }
}

enum ProductsOptions {
    enum PensionOptions: Int {
        case contribution = 0, periodicInput, detail, purchasePension
    }
    enum LoansOptions: Int {
        case amortization = 0, changeAccount, detail, purchaseLoan
    }
    enum FundOptions: Int {
        case subscription = 0, transfer, detail, purchaseFund
    }
    enum DepositOptions: Int {
        case detail = 0, purchaseDeposit
    }
    enum AccountProfileOptions: Int {
        case transfer = 0, evolution, receipts, detail, foreignExchange, purchaseAccount
    }
    enum CardOptions: Int {
        case activateCard = 0, directMoney, paylater, payOff, prepaidCharge, pinQuery, CVVQuery, blockCard, mobilePay, withdrawMoneyWithCode, mobileTopUp, ces, pdf, cardLimitManagement, solidary, modifyPaymentForm, purchaseCard
    }
    enum StockProfileOptions: Int {
        case allStocks = 0, search, broker, alerts
    }
    enum ProductProfileTransactionOptions: Int {
        case detail = 0
    }
    enum ImpositionOptions: Int {
        case detail = 0, liquidation
    }
    enum InsuranceProtectionOptions: Int {
        case policyGestion = 0
    }
    
    enum InsuranceSavingOptions: Int {
        case extraAportation = 0
        case aportationPlanChange  = 1
        case activatePlan = 2
    }
}
