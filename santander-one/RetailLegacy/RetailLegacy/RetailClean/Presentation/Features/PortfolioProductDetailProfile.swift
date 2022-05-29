import Foundation
import CoreFoundationLib

class PortfolioProductDetailProfile: BaseProductDetailProfile<PortfolioProduct>, ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("genericToolbar_title_detail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    private let portfolioProduct: PortfolioProduct

    init(product: GenericProductProtocol? = nil, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.portfolioProduct = product as! PortfolioProduct
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }

    override func convertToProductHeader(element: PortfolioProduct, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI() ?? "",
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: false,
                                 shareDelegate: self)
        addCopyTag(tag: 1, info: element.getDetailUI())
        return CarouselGenericCell(data: data)
    }
    
    override func extractProduct() -> PortfolioProduct {
        return portfolioProduct
    }
    
    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        let loadingSection = LoadingSection()
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        loadingSection.add(item: loading)
        sections.append(loadingSection)
        
        return sections
    }
    
    func getAllInfo(_ productDetail: PortfolioHolderList) -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        if let alias = portfolioProduct.getPortfolioAliasUI() {
            let aliasSection = ProductInfoSection()
            let aliasViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .copiable,
                                                            infoTitle: dependencies.stringLoader.getString("productDetail_label_stocks"),
                                                            info: alias,
                                                            privateComponent: dependencies,
                                                            copyTag: 2,
                                                            shareDelegate: self)
            addCopyTag(tag: 2, info: alias)
            aliasSection.add(item: aliasViewModel)
            sections.append(aliasSection)
        }
        
        if let totalShares = portfolioProduct.getCounterValueAmountValue() {
            let totalSharesSection = ProductInfoSection()
            let totalSharesViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_shares"),
                                                                  info: totalShares.getFormattedValue(5),
                                                                  privateComponent: dependencies,
                                                                  shareDelegate: self)
            totalSharesSection.add(item: totalSharesViewModel)
            sections.append(totalSharesSection)
        }
        
        if let totalNumberHolders = productDetail.getNumberOfHolders() {
            let totalNumberHoldersSection = ProductInfoSection()
            let totalNumberHoldersViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_nHolder"),
                                                                         info: String(describing: totalNumberHolders),
                                                                         privateComponent: dependencies,
                                                                         shareDelegate: self)
            totalNumberHoldersSection.add(item: totalNumberHoldersViewModel)
            sections.append(totalNumberHoldersSection)
        }
        
        if let firstHolders = productDetail.getFirstHolder() {
            let firstHoldersSection = ProductInfoSection()
            let firstHoldersViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_firstHolder"),
                                                                   info: firstHolders.camelCasedString,
                                                                   privateComponent: dependencies,
                                                                   shareDelegate: self)
            firstHoldersSection.add(item: firstHoldersViewModel)
            sections.append(firstHoldersSection)
        }
        
        setFirstElement(sections: sections)
        
        return sections
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections.filter {!$0.isKind(of: LoadingSection.self)}
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
        
        guard let portfolio = portfolioProduct.portfolio else { return }
        
        UseCaseWrapper(with: dependencies.useCaseProvider.getPortfolioProductHolderDetailUseCase(input: GetPortfolioProductHolderDetailUseCaseInput(portfolio: portfolio)), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) -> Void in
            
            guard let strongSelf = self else { return }
            completion(strongSelf.getAllInfo(result.transactionDetail))
            
            }, onError: {(error) -> Void in
                RetailLogger.e(self.logTag, "PortfolioProductHolderDTO ERROR \(error?.getErrorDesc() ?? "")")
                completion(nil)
        })
    }
}
