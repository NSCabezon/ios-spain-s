import CoreFoundationLib
import CoreDomain
import Cards

final class ModuleCoordinatorDelegateMock: CardsHomeModuleCoordinatorDelegate {
    func goToWebView(configuration: WebViewConfiguration) { }
    
    var cardEntity: CardEntity?
    var selectedMonth: String?
    
    func didSelectDownloadTransactions(for entity: CardEntity) { }
    
    func didSelectDismiss() { }
    
    func didSelectMenu() { }
    
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) { }
    
    func easyPay(entity: CardEntity, transactionEntity: CardTransactionEntity, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?) { }
    
    func didSelectSearch(for entity: CardEntity) { }
    
    func didSelectAddToApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate) { }
    
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) { }
    
    func cardsHomeDidAppear() { }
    
    func didSelectOffer(offer: OfferEntity) { }
    
    func didSelectOffer(offer: OfferRepresentable) { }
    
    func didSelectSettlementAction(_ action: NextSettlementActionType, entity: CardEntity) { }
    
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) { }
    
    func didSelectInExtractPdf(_ cardEntity: CardEntity, selectedMonth: String) {
        self.cardEntity = cardEntity
        self.selectedMonth = selectedMonth
    }
    
    func didSelectDownloadTransactions(for entity: CardEntity, withFilters: TransactionFiltersEntity?) {}
    
    func didGenerateTransactionsPDF(for card: CardEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [CardTransactionEntityProtocol], showDisclaimer: Bool) {}
    
}
