//
import Foundation
import CoreFoundationLib

class ImpositionsDetailProfile: BaseProductDetailProfile<Imposition>, ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_impositionDetail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.DepositImpositionDetail().page
    }

    // MARK: -

    private let product: Imposition

    init(product: GenericProductProtocol? = nil, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.product = product as! Imposition
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }
    
    override func convertToProductHeader(element: Imposition, position: Int) -> CarouselItem {
        let data = ProductHeader(title: impositionUI(from: element.subcontract),
                                 styleSubtitle: impositionDescription(from: product.deposit?.getAliasCamelCase() ?? "", TAE: element.TAE ?? ""),
                                 amount: element.settlementAmount,
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: false,
                                 copyTag: 1,
                                 isBigSeparator: false,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProduct() -> Imposition {
        return product
    }
    
    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        if let renovationIndDesc = product.renovationIndDesc {
            let renovationSection = ProductInfoSection()
            let renovationText: String
            
            if renovationIndDesc.uppercased() == dependencies.stringLoader.getString("detailImposition_text_renew").text.uppercased() {
                renovationText = dependencies.stringLoader.getString("detailImposition_text_expirationRenew").text
            } else if renovationIndDesc.uppercased() == dependencies.stringLoader.getString("detailImposition_text_noRenew").text.uppercased() {
                renovationText = dependencies.stringLoader.getString("detailImposition_text_expirationNoRenew").text
            } else {
                renovationText = ""
            }
            
            if !renovationText.isEmpty {
                let renovationViewModel = ProductDetailInfoViewModel(infoTitle: LocalizedStylableText(text: "", styles: nil),
                                                                     info: renovationText,
                                                                     privateComponent: dependencies,
                                                                     shareDelegate: self)
                renovationSection.add(item: renovationViewModel)
                sections.append(renovationSection)
            }
        }
        
        if let date = product.openingDate {
            let dateSection = ProductInfoSection()
            let dateViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_date"),
                                                           info: imposition(WithDate: date),
                                                           privateComponent: dependencies,
                                                           shareDelegate: self)
            dateSection.add(item: dateViewModel)
            sections.append(dateSection)
        }
        
        if let expirationDate = product.dueDate {
            let expirationDateSection = ProductInfoSection()
            let expirationDateViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_expirationDate"),
                                                                     info: imposition(WithDate: expirationDate),
                                                                     privateComponent: dependencies,
                                                                     shareDelegate: self)
            expirationDateSection.add(item: expirationDateViewModel)
            sections.append(expirationDateSection)
        }
        
        if let capitalitation = product.getDetailUI() {
            let capitalitationSection = ProductInfoSection()
            let capitalitationViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_interest"),
                                                                     info: capitalitation,
                                                                     privateComponent: dependencies,
                                                                     shareDelegate: self)
            capitalitationSection.add(item: capitalitationViewModel)
            sections.append(capitalitationSection)
        }
        
        if let associatedAccount = product.linkedAccountDesc {
            let associatedAccountSection = ProductInfoSection()
            let associatedAccountViewModel = ProductDetailInfoViewModel(infoTitle: dependencies.stringLoader.getString("productDetail_label_associatedAccount"),
                                                                        info: associatedAccount,
                                                                        privateComponent: dependencies,
                                                                        shareDelegate: self)
            associatedAccountSection.add(item: associatedAccountViewModel)
            sections.append(associatedAccountSection)
        }
        
        setFirstElement(sections: sections)
      
        return sections
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections.filter {
            if $0 is LoadingSection { return false }
            return true
        }
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
        completion(nil)
    }
    
    // MARK: - Privates
    private func impositionUI(from subContract: String) -> String {
        return dependencies.stringLoader.getString("detailImposition_text_impositionNumber", [StringPlaceholder(.number, subContract)]).text
    }
    
    private func impositionDescription(from contractType: String, TAE: String) -> LocalizedStylableText {
        let contract = dependencies.stringLoader.getString("detailImposition_text_APR", [StringPlaceholder(StringPlaceholder.Placeholder.name, contractType), StringPlaceholder(StringPlaceholder.Placeholder.number, TAE)])
        return contract
    }
    
    private func imposition(WithDate date: Date) -> String {
        guard let dateString = dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy) else {
            return ""
        }
        return dateString
    }
    
}
