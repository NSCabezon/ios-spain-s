import CoreFoundationLib
import UIKit

typealias CarouselGenericCell = CollectionCellConfigurator<ProductDetailCollectionViewCell, ProductHeader>
typealias CarouselGenericCardCell = CollectionCellConfigurator<ProductGenericCardCollectionViewCell, ProductGenericCardHeader>
typealias CarouselCreditCardCell = CollectionCellConfigurator<ProductCreditCardCollectionViewCell, ProductCreditCardHeader>
typealias CarouselAccountCell = CollectionCellConfigurator<ProductAccountCollectionViewCell, ProductAccountHeader>
typealias CarouselInsuranceCell = CollectionCellConfigurator<ProductInsuranceCollectionViewCell, ProductInsuranceHeader>

typealias ToolTipStrings = (title: LocalizedStylableText, description: String)

class BaseProductHomeProfile<T: GenericProduct & Equatable, X, Input, Response, Error: StringErrorOutput, Transaction>: CurrentProductProvider {
    
    var generatedOptions: [ProductOption]?
    weak var searchInputProvider: SearchInputProvider?
    lazy var searchProfile: SearchParameterCapable? = {
        return makeSearchProfile()
    }()
    
    var isHeaderCellHidden: Bool {
        return false
    }
    
    var showPdfAction: (() -> Void)?
    
    public var logTag: String {
        return String(describing: type(of: self))
    }

    private var nextPage: PaginationDO?
    var currentPosition: Int? {
        didSet {
            transactionList.removeAll()
            
            guard let config = productConfig else { return }
            menuOptions(withProductConfig: config)
        }
    }
    var productConfig: ProductConfig? {
        didSet {
            guard let config = productConfig else { return }
            menuOptions(withProductConfig: config)
        }
    }
    var hasDefaultRows: Bool {
        return true
    }
    
    var numberOfDefaultSections: Int {
        return 2
    }
    
    var needsExtraBottomSpace: Bool {
        return false
    }
    
    var emmaScreenToken: String? {
        return nil
    }
    
    var nextProduct: GenericProduct?
    let selectedProduct: GenericProduct?
    let dependencies: PresentationComponent
    weak var delegate: ProductHomeProfileDelegate?
    weak var shareDelegate: ShowShareType?
    let errorHandler: GenericPresenterErrorHandler
    var completionHandler: (([CarouselItem], Int) -> Void)?
    var completionOptions: (([ProductOption]) -> Void)?
    var transactionsCompletionHandler: (([DateProvider]) -> Void)?
    var transactionList = [Transaction]()
    private var copiableTags = Set<CopyType>()
    
    var loadingTopInset: Double {
        return 14
    }
    
    var productList = [T]() {
        didSet {
            defer {
                completionHandler = nil
            }
            let index = selectedIndex()
            currentPosition = index
            let result = productList.enumerated().map({ (element) in
                convertToProductHeader(element: element.element, position: element.offset)
            })
            completionHandler?(result, index)
        }
    }
    var currentProduct: GenericProduct {
        let position = currentPosition ?? 0
        if productList.count <= position, let selectedProduct = selectedProduct {
            return selectedProduct
        } else {
            return productList[position]
        }
    }
    
    var transactionHeaderTitle: LocalizedStylableText? {
        return nil
    }
    
    func convertToProductHeader(element: T, position: Int) -> CarouselItem {
        fatalError()
    }
    
    var isMorePages: Bool {
        guard let nextPage = nextPage else {
            return false
        }
        return nextPage.endList != true
    }
    
    func selectedIndex() -> Int {
        var selectedIndex = 0
        if let selectedProduct = selectedProduct as? T {
            selectedIndex = productList.map({ $0 }).firstIndex(of: selectedProduct) ?? 0
        }
        return selectedIndex
    }
    
    init(selectedProduct: GenericProduct? = nil,
         dependencies: PresentationComponent,
         errorHandler: GenericPresenterErrorHandler,
         delegate: ProductHomeProfileDelegate,
         shareDelegate: ShowShareType?) {
        self.dependencies = dependencies
        self.errorHandler = errorHandler
        self.selectedProduct = selectedProduct
        self.delegate = delegate
        self.shareDelegate = shareDelegate
    }
    
    func makeSearchProfile() -> ProductSearchParametersHandler<T, X>? {
        return nil
    }
    
    func selectProduct(at position: Int) {
        guard currentPosition != position else {
            return
        }
        currentPosition = position
        nextPage = nil
    }
    
    func productList(completion: @escaping ([CarouselItem], _ selectedIndex: Int) -> Void) {
        completionHandler = completion
        UseCaseWrapper(with: dependencies.useCaseProvider.getPGDataUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: errorHandler,
                       onSuccess: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.productList = strongSelf.extractProductList(globalPosition: result.globalPosition)
        })
    }
    
    func extractProductList(globalPosition: GlobalPositionWrapper) -> [T] {
        fatalError()
    }
    
    func requestTransactions(fromBeginning isFromBeginning: Bool,
                             completion: @escaping ([DateProvider]) -> Void) {
        guard let currentPosition = currentPosition else {
            return
        }
        
        if isFromBeginning {
            nextPage = nil
        }
        
        transactionsCompletionHandler = completion
                
        guard let uc: UseCase<Input, Response, Error> = useCaseForTransactions(pagination: nextPage) else {
            return
        }
        
        UseCaseWrapper(with: uc,
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: errorHandler,
                       onSuccess: { [weak self] (result) in
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            let pagination = strongSelf.paginationFrom(response: result)
            let transactions = strongSelf.transactionsFrom(response: result)
            if let transactions = transactions {
                strongSelf.transactionList.append(contentsOf: transactions)
            }            
            strongSelf.receivedTransactions(transactions: transactions, nextPage: pagination)
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            strongSelf.receivedTransactions(transactions: nil, nextPage: nil)
        })
    }
    
    func loadProductConfig(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getProductConfigUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] response in
                self?.productConfig = response.productConfig
                completion()
            },
            onError: { _ in
                completion()
            }
        )
    }
    
    private func handleProductConfigResponse(_ productConfig: ProductConfig?, completion: @escaping () -> Void) {
        self.productConfig = productConfig
        completion()
    }
        
    func useCaseForTransactions<Input, Response, Error: StringErrorOutput>(pagination: PaginationDO?) -> UseCase<Input, Response, Error>? {
        guard let currentPosition = currentPosition else {
            return nil
        }
        let product = productList[currentPosition]
        
        return searchProfile?.useCaseForTransactions(product: product, pagination: pagination)
    }
    
    func paginationFrom(response: Response) -> PaginationDO? {
        fatalError()
    }
    
    func transactionsFrom(response: Response) -> [Transaction]? {
        fatalError()
    }
    
    func addExtraHeaderSection(section: TableModelViewSection) {}
    
    func receivedTransactions(transactions: [Transaction]?, nextPage: PaginationDO?) {
        defer {
            transactionsCompletionHandler = nil
        }
        let isFirstPage = self.nextPage == nil
        self.nextPage = nextPage
        guard let transactions = transactions else {
            transactionsCompletionHandler?([DateProvider]())
            return
        }
        var result = [DateProvider]()
        for transaction in transactions {
            let element = convertToDateProvider(from: transaction)
            result.append(element)
        }
        if isFirstPage {
            result.first?.isFirstTransaction = true
        }
        transactionsCompletionHandler?(result)
    }
    
    func convertToDateProvider(from transaction: Transaction) -> DateProvider {
        fatalError()
    }
    
    func menuOptions(withProductConfig productConfig: ProductConfig) {
        fatalError()
    }
        
    func infoToShareWithCode(_ code: Int?) -> String? {
        guard let tag = code, let info = copiableTags.first(where: { $0.tag == tag })?.info else {
            return nil
        }

        return info
    }
    
    func addCopyTag(tag: Int, info: String?) {
        copiableTags.insert(CopyType(tag: tag, info: info))
    }

    // MARK: - ShareInfoHandler
    
    func shareInfoWithCode(_ code: Int?) {
        guard let infoToShare = infoToShareWithCode(code) else {
            return
        }
        shareDelegate?.shareContent(infoToShare)
    }

}

extension BaseProductHomeProfile: CacheSearchParameterHandlerDelegate {
    func clear() {
        transactionList.removeAll()
    }
}

extension BaseProductHomeProfile: ShareInfoHandler {}
