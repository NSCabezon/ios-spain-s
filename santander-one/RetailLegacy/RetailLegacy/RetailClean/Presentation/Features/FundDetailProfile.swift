import Foundation
import CoreFoundationLib

class FundDetailProfile: BaseProductDetailProfile<Fund>, ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_fundDetail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.FundsDetail().page
    }

    // MARK: -

    private let product: Fund

    init(product: GenericProductProtocol? = nil, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.product = product as! Fund
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }
    
    override func convertToProductHeader(element: Fund, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI() ?? "",
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: false,
                                 shareDelegate: self,
                                 amountFormat: .long)
        addCopyTag(tag: 1, info: element.getDetailUI())
        return CarouselGenericCell(data: data)
    }
    
    override func extractProduct() -> Fund {
        return product
    }
    
    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        let aliasSection = ProductInfoSection()
        if let alias = makeAliasSection() {
            aliasSection.add(item: alias)
            sections.append(aliasSection)
        }
        
        let loadingSection = LoadingSection()
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        loadingSection.add(item: loading)
        sections.append(loadingSection)
        
        return sections
    }
    
    func getAllInfo(_ productDetail: FundDetail) -> [TableModelViewSection] {
        
        var sections = [TableModelViewSection]()
        
        let aliasSection = ProductInfoSection()
        if let alias = makeAliasSection() {
            aliasSection.add(item: alias)
            sections.append(aliasSection)
        }
        
        if let associatedAccount = productDetail.getLinkedAccountDesc() {
            let associatedAccountSection = ProductInfoSection()
            let associatedViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .copiable,
                                                                 infoTitle: dependencies.stringLoader.getString("productDetail_label_associatedAccount"),
                                                                 info: associatedAccount,
                                                                 privateComponent: dependencies,
                                                                 copyTag: 2,
                                                                 shareDelegate: self)
            addCopyTag(tag: 2, info: associatedAccount)
            associatedAccountSection.add(item: associatedViewModel)
            sections.append(associatedAccountSection)
        }
        
        if let holder = productDetail.getHolder() {
            let holderSection = ProductInfoSection()
            let holderViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .notInteractive,
                                                             infoTitle: dependencies.stringLoader.getString("productDetail_label_holder"),
                                                             info: holder.camelCasedString,
                                                             privateComponent: dependencies,
                                                             shareDelegate: self)
            holderSection.add(item: holderViewModel)
            sections.append(holderSection)
        }
        
        if let fundDescription = productDetail.getDescription() {
            let fundDescriptionSection = ProductInfoSection()
            let fundDescriptionViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .notInteractive,
                                                                      infoTitle: dependencies.stringLoader.getString("productDetail_label_description"),
                                                                      info: fundDescription,
                                                                      privateComponent: dependencies,
                                                                      shareDelegate: self)
            fundDescriptionSection.add(item: fundDescriptionViewModel)
            sections.append(fundDescriptionSection)
        }
        
        if let stock = productDetail.getValueAmount() {
            let stockSections = ProductInfoSection()
            let stockViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_liquidationStock"),
                                                            info: stock,
                                                            privateComponent: dependencies,
                                                            shareDelegate: self)
            stockSections.add(item: stockViewModel)
            sections.append(stockSections)
        }
        
        if let liquidationDate = productDetail.getValueDate() {
            let liquidationSection = ProductInfoSection()
            let liquidationViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_liquidationDate"),
                                                                  info: dateToString(liquidationDate),
                                                                  privateComponent: dependencies,
                                                                  shareDelegate: self)
            liquidationSection.add(item: liquidationViewModel)
            sections.append(liquidationSection)
        }
        
        if let shares = productDetail.getNumberShares() {
            let sharesSection = ProductInfoSection()
            let sharesViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_shares"),
                                                             info: String(describing: shares),
                                                             privateComponent: dependencies,
                                                             shareDelegate: self)
            sharesSection.add(item: sharesViewModel)
            sections.append(sharesSection)
        }
        
        if let totalStock = productDetail.getTotalStock() {
            let totalStockSection = ProductInfoSection()
            let totalStockViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_totalStock"),
                                                                 info: totalStock,
                                                                 privateComponent: dependencies,
                                                                 shareDelegate: self)
            totalStockSection.add(item: totalStockViewModel)
            sections.append(totalStockSection)
        }
        
        setFirstElement(sections: sections)
     
        return sections
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections.filter {!$0.isKind(of: LoadingSection.self)}
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
        
        UseCaseWrapper(with: dependencies.useCaseProvider.getFundDetailUseCase(input: GetFundDetailUseCaseInput(fund: product)), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) -> Void in
            
            guard let strongSelf = self else { return }
            completion(strongSelf.getAllInfo(result.getFundDetail()))
            
            }, onError: {(error) -> Void in
                RetailLogger.e(self.logTag, "GetFundDetailUseCaseInput ERROR \(error?.getErrorDesc() ?? "")")
                completion(nil)
        })
    }

    // MARK: - Private funcs
    private func makeAliasSection() -> ProductDetailInfoViewModel? {
        let alias = product.getAliasCamelCase()
        let aliasViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_alias"),
                                                        info: alias,
                                                        privateComponent: dependencies,
                                                        shareDelegate: self)
        return aliasViewModel
    }
    
    private func dateToString(_ date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy)?.lowercased() ?? ""
    }
    
}
