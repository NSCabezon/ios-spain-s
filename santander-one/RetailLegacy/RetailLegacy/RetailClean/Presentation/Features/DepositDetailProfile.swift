import Foundation
import CoreFoundationLib

class DepositDetailProfile: BaseProductDetailProfile<Deposit>, ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_depositDetail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.DepositDetail().page
    }

    // MARK: -

    private let product: Deposit

    init(product: GenericProductProtocol? = nil, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.product = product as! Deposit
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }
    
    override func convertToProductHeader(element: Deposit, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI() ?? "",
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: false,
                                 copyTag: nil,
                                 isBigSeparator: false,
                                 shareDelegate: self,
                                 amountFormat: .long)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProduct() -> Deposit {
        return product
    }
    
    override func shareInfoWithCode(_ code: Int?) {
        if let screenId = self.screenId {
            delegate?.track(event: TrackerPagePrivate.DepositDetail.Action.copy.rawValue, screen: screenId, parameters: [:])
        }
        
        super.shareInfoWithCode(code)
    }

    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        if let contractNumber = product.getDetailUI() {
            let ownerSection = ProductInfoSection()
            let ownerViewModel = ProductDetailInfoViewModel(interactionableTextLabelType: .copiable,
                                                            infoTitle: dependencies.stringLoader.getString("productDetail_label_contract"),
                                                            info: contractNumber,
                                                            privateComponent: dependencies,
                                                            copyTag: 1,
                                                            shareDelegate: self)
            addCopyTag(tag: 1, info: contractNumber)
            ownerSection.add(item: ownerViewModel)
            sections.append(ownerSection)
        }
        
        if let alias = product.getAlias() {
            let aliasSection = ProductInfoSection()
            let aliasViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_alias"),
                                                            info: alias.camelCasedString,
                                                            privateComponent: dependencies,
                                                            shareDelegate: self)
            aliasSection.add(item: aliasViewModel)
            sections.append(aliasSection)
        }
        
        setFirstElement(sections: sections)
        
        return sections
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections.filter {!$0.isKind(of: LoadingSection.self)}
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
    
    }
    
}
