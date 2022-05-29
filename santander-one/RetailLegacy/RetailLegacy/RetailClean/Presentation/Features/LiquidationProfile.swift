import CoreFoundationLib
import CoreDomain

class LiquidationProfile: BaseProductHomeProfile<Imposition, DateRangeSearchParameters, LoadImpositionLiquidationsUseCaseInput, LoadImpositionLiquidationsUseCaseOKOutput, LoadImpositionLiquidationsUseCaseErrorOutput, Liquidation>, ProductProfile {

    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    let selectedImposition: Imposition
    
    override init(selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.selectedImposition = selectedProduct as! Imposition
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }
    
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_settlements")
    }
        
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("toolbar_title_settlements").uppercased()
    }
    
    var isFilterIconVisible: Bool {
        return true
    }
    
    var showNavigationInfo: Bool {
        return false
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.DepositLiquidation().page
    }

    // MARK: -

    private lazy var options = [ProductOption]()

    override func convertToProductHeader(element: Imposition, position: Int) -> CarouselItem {
        let data = ProductHeader(title: impositionUI(from: element.subcontract),
                                 subtitle: impositionDescription(from: element.deposit?.getAliasCamelCase() ?? "", TAE: element.TAE ?? ""),
                                 amount: element.settlementAmount,
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: false,
                                 copyTag: 1,
                                 isBigSeparator: true,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Imposition] {
        return [selectedImposition]
    }
    
    override func paginationFrom(response: LoadImpositionLiquidationsUseCaseOKOutput) -> PaginationDO? {
        return response.liquidationList.pagination
    }
    
    override func transactionsFrom(response: LoadImpositionLiquidationsUseCaseOKOutput) -> [Liquidation]? {
        return response.liquidationList.transactions
    }
    
    override func convertToDateProvider(from transaction: Liquidation) -> DateProvider {
        return LiquidationTransactionViewModel(transaction, false, dependencies)
    }
    
    // MARK: - Menu Options
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        completionOptions?(options)
    }
    
    func transactionDidSelected(at index: Int) {
        delegate?.goToDetail(product: ImpositionAndLiquidation(imposition: selectedImposition, liquidation: transactionList[index]), productDetail: nil, productHome: .liquidationDetail)
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
        let profile = LiquidationSearchHandler(currentProductProvider: self, dependencies: dependencies)
        profile.cacheDelegate = self
        profile.searchInputProvider = searchInputProvider
        return profile
    }
}
