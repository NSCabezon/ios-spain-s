import Foundation
import CoreFoundationLib

class PensionDetailProfile: BaseProductDetailProfile<Pension>, ProductDetailProfile {

    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_planDetail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.PensionDetail().page
    }

    // MARK: -

    private let product: Pension

    init(product: GenericProductProtocol? = nil, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.product = product as! Pension
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }
    
    override func convertToProductHeader(element: Pension, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI(),
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
    
    override func extractProduct() -> Pension {
        return product
    }
    
    override func shareInfoWithCode(_ code: Int?) {
        if let screenId = self.screenId, code == 1 {
            delegate?.track(event: TrackerPagePrivate.PensionDetail.Action.copyContract.rawValue, screen: screenId, parameters: [:])
        }
        super.shareInfoWithCode(code)
    }
    
    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        if let alias = product.getAlias() {
            let aliasSection = ProductInfoSection()
            let aliasViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_alias"),
                                                            info: alias.camelCasedString,
                                                            privateComponent: dependencies,
                                                            shareDelegate: self)
            aliasSection.add(item: aliasViewModel)
            sections.append(aliasSection)
        }
        
        let loadingSection = LoadingSection()
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        loadingSection.add(item: loading)
        sections.append(loadingSection)
        
        setFirstElement(sections: sections)
        
        return sections
    }
    
    func getAllInfo(_ productDetail: PensionDetail) -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        if let alias = product.getAlias() {
            let aliasSection = ProductInfoSection()
            let aliasViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_alias"),
                                                            info: alias.camelCasedString,
                                                            privateComponent: dependencies,
                                                            shareDelegate: self)
            aliasSection.add(item: aliasViewModel)
            sections.append(aliasSection)
        }
        
        if let linkedAccountDesc = productDetail.getLinkedAccountDesc {
            let linkedAccountSection = ProductInfoSection()
            let linkedAccountViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .copiable,
                                                                    infoTitle: dependencies.stringLoader.getString("productDetail_label_associatedAccount"),
                                                                    info: linkedAccountDesc,
                                                                    privateComponent: dependencies,
                                                                    copyTag: 2,
                                                                    shareDelegate: self)
            addCopyTag(tag: 2, info: linkedAccountDesc)
            linkedAccountSection.add(item: linkedAccountViewModel)
            sections.append(linkedAccountSection)
        }
        
        if let holder = productDetail.getHolder {
            let holderSection = ProductInfoSection()
            let holderViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_holder"),
                                                             info: holder.camelCasedString,
                                                             privateComponent: dependencies,
                                                             shareDelegate: self)
            holderSection.add(item: holderViewModel)
            sections.append(holderSection)
        }
        
        if let description = productDetail.getDescription {
            let descriptionSection = ProductInfoSection()
            let descriptionViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_description"),
                                                                  info: description,
                                                                  privateComponent: dependencies,
                                                                  shareDelegate: self)
            descriptionSection.add(item: descriptionViewModel)
            sections.append(descriptionSection)
        }
        
        if let valueAmount = productDetail.getValueAmount {
            let valueAmountSection = ProductInfoSection()
            let valueAmountViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_liquidationStock"),
                                                                  info: valueAmount,
                                                                  privateComponent: dependencies,
                                                                  shareDelegate: self)
            valueAmountSection.add(item: valueAmountViewModel)
            sections.append(valueAmountSection)
        }
        
        if let valueDate = productDetail.getValueDate {
            let valueDateSection = ProductInfoSection()
            let valueDateViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_liquidationDate"),
                                                                info: dateToString(valueDate),
                                                                privateComponent: dependencies,
                                                                shareDelegate: self)
            valueDateSection.add(item: valueDateViewModel)
            sections.append(valueDateSection)
        }
        
        if let numberShares = productDetail.getNumberShares {
            let numberSharesSection = ProductInfoSection()
            let numberSharesViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_shares"),
                                                                   info: decimalToString(numberShares),
                                                                   privateComponent: dependencies,
                                                                   shareDelegate: self)
            numberSharesSection.add(item: numberSharesViewModel)
            sections.append(numberSharesSection)
        }
        
        if let totalStock = productDetail.getTotalStock {
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
        
        UseCaseWrapper(with: dependencies.useCaseProvider.getPensionDetailUseCase(input: GetPensionDetailUseCaseInput(pension: product)), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) -> Void in
            
            guard let strongSelf = self else { return }
            completion(strongSelf.getAllInfo(result.getPensionDetail()))
            
            }, onError: { error -> Void in
                RetailLogger.e(self.logTag, "PensionDetailDTO ERROR \(error?.getErrorDesc() ?? "")")
                completion(nil)
        })
    }
    
    private func decimalToString(_ decimal: Decimal) -> String {
        return formatterForRepresentation(.decimal(decimals: 5)).string(for: decimal)!
    }
    
    private func dateToString(_ date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy)?.lowercased() ?? ""
    }

}
