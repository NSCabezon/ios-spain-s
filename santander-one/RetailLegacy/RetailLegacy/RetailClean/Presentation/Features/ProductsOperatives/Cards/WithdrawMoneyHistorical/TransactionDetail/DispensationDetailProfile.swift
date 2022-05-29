import Foundation

class DispensationDetailProfile: BaseProductDetailProfile<Dispensation> {
    
    private var sections: [TableModelViewSection]!
    
    private let card: Card
    private let cardDetail: CardDetail
    private let account: Account?
    
    init(dispensation: Dispensation, card: Card, cardDetail: CardDetail, account: Account?, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.card = card
        self.cardDetail = cardDetail
        self.account = account
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
        detailProduct = dispensation
    }
    
    override func detailProduct(completion: @escaping (CarouselItem) -> Void) {
        completion(VoidCarouselItem())
    }
    
    override func convertToProductHeader(element: Dispensation, position: Int) -> CarouselItem {
        return VoidCarouselItem()
    }
}

extension DispensationDetailProfile: ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_historyWhitdraw")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    func getInfo() -> [TableModelViewSection] {
        sections = [TableModelViewSection]()
        let section = ProductInfoSection()
        
        var fixedValues: [(key: LocalizedStylableText, value: String?, valueColor: ItemViewColor?)] = []
        if detailProduct.status == .pending, let operationCode = detailProduct.operationCode {
            fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_operationCode"),
                             value: operationCode,
                             valueColor: OperationCodeItemViewColor())]
        }
        
        fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_status"),
                         value: dependencies.stringLoader.getString(detailProduct.status.situationKey).text.camelCasedString,
                         valueColor: DispensationStatusItemViewColor(status: detailProduct.status))]
        if let phone = detailProduct.otpPhone {
            fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_issuerPhone"), value: phone.obfuscateNumber(withNumberOfAsterisks: 5), valueColor: nil)]
        }
        fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_amount"), value: detailProduct.amount.getFormattedAmountUI(0), valueColor: nil)]
        fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_card"), value: card.getAliasAndInfo(), valueColor: nil)]
        if let linkedAccountOldContract = cardDetail.linkedAccountOldContract {
            fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_originAccount"), value: account?.getAliasAndInfo() ?? IBAN.create(fromText: linkedAccountOldContract).getAliasAndInfo(withCustomAlias: dependencies.stringLoader.getString("generic_summary_associatedAccount").text), valueColor: nil)]
        }
        fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_issuanceDate"),
                         value: dependencies.timeManager.toString(date: detailProduct.releaseDate, outputFormat: .D_MMM_YYYY_7_HH_mm_ss), valueColor: nil)]
        fixedValues += [(key: dependencies.stringLoader.getString("confirmationHistoryWhitdraw_item_expirationDate"),
                         value: dependencies.timeManager.toString(date: detailProduct.expirationDate, outputFormat: .D_MMM_YYYY_7_HH_mm_ss), valueColor: nil)]
        
        let fixedItems = fixedValues.map {
            ProductDetailInfoViewModel(infoTitle: $0.key,
                                       info: $0.value,
                                       privateComponent: dependencies,
                                       valueColor: $0.valueColor,
                                       shareDelegate: self)
        }
        
        section.items.append(contentsOf: fixedItems)
        
        sections = [section]
     
        return sections
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
        completion(sections)
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections
    }
}
