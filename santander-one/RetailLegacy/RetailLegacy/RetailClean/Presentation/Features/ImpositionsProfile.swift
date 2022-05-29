import Foundation
import CoreFoundationLib
import CoreDomain

class ImpositionProfile: BaseProductHomeProfile<Imposition, DateRangeSearchParameters, GetImpositionsTransactionUseCaseInput, GetImpositionsTransactionUseCaseOkOutput, GetImpositionsTransactionUseCaseErrorOutput, ImpositionTransaction>, ProductProfile {
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    let impositionsProfile: [Imposition]

    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }
    
    func product(at position: Int) -> GenericProduct {
        return productList[position]
    }

    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_imposition")
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

    // MARK: - Tracking

    var screenId: String? {
        return TrackerPagePrivate.DepositImpositions().page
    }

    // MARK: -

    private lazy var options = [ProductOption]()

    init(impositionsProfile: [Imposition], selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.impositionsProfile = impositionsProfile

        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
    }

    override func convertToProductHeader(element: Imposition, position: Int) -> CarouselItem {
        let data = ProductHeader(title: impositionUI(from: element.subcontract),
                                 subtitle: impositionDescription(from: element.deposit?.getAliasCamelCase() ?? "", TAE: element.TAE ?? ""),
                                 amount: element.settlementAmount,
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: false,
                                 copyTag: 1,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Imposition] {
        return impositionsProfile
    }
    
    override func paginationFrom(response: GetImpositionsTransactionUseCaseOkOutput) -> PaginationDO? {
        return response.impositionTransaction.pagination
    }
    
    override func transactionsFrom(response: GetImpositionsTransactionUseCaseOkOutput) -> [ImpositionTransaction]? {
        return response.impositionTransaction.impositionTransactions
    }
    
    override func convertToDateProvider(from transaction: ImpositionTransaction) -> DateProvider {
        return ImpositionsTransactionsViewModel(transaction, false, dependencies)
    }

    // MARK: - Menu Options
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        options.append(ImpositionOptionsHandler.buildDetail(dependencies))
        options.append(ImpositionOptionsHandler.buildLiquidations(dependencies))
        completionOptions?(options)
    }

    func optionDidSelected(at index: Int) {
        
        if let impositions = ProductsOptions.ImpositionOptions(rawValue: index) {
            switch impositions {
            case .detail:
                goToDetail()
            case .liquidation:
                goToLiquidation()
            }
        }
    }
    
    private func goToDetail() {
        if let product = currentImposition() {
            delegate?.goToDetail(product: product, productDetail: nil, productHome: .impositionDetail)
        }
    }
    
    private func goToLiquidation() {
        if let product = currentImposition() {
            delegate?.goToLiquidation(product: product)
        }
    }
    
    private func currentImposition() -> Imposition? {
        guard let position = currentPosition else { return nil }
        let product = productList[position]
        return product
    }
    
    func transactionDidSelected(at index: Int) {
        guard let product = selectedProduct as? Imposition else { return }
        delegate?.goToTransactionDetail(product: product, transactions: transactionList, selectedPosition: index, productHome: .impositionTransactionDetail)
    }
    
    func showInfo() {
    }
    
    private func impositionUI(from subContract: String) -> String {
        let impositionsTitle = dependencies.stringLoader.getString("toolbar_title_imposition").text.uppercased()
        let impositionNumber = dependencies.stringLoader.getString("deposits_label_number", [StringPlaceholder(StringPlaceholder.Placeholder.number, subContract)]).text.uppercased()
        return "\(impositionsTitle) \(impositionNumber)"
    }
    
    private func impositionDescription(from contractType: String, TAE: String) -> String {
        let contract = dependencies.stringLoader.getString("detailImposition_text_APR", [StringPlaceholder(StringPlaceholder.Placeholder.name, contractType),
                                                                                         StringPlaceholder(StringPlaceholder.Placeholder.number, TAE)])
        return contract.text
    }
    
    override func makeSearchProfile() -> ProductSearchParametersHandler<Imposition, DateRangeSearchParameters>? {
        let profile = ImpositionSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.cacheDelegate = self
        profile.searchInputProvider = searchInputProvider
        return profile
    }
}
