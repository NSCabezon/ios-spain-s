import Foundation
import CoreFoundationLib

class MonthSelectionDialogPresenter: PrivatePresenter<MonthSelectionViewController, ProductHomeNavigatorProtocol, MonthSelectionPresenterProtocol> {
    
    let card: Card
    let months: PdfMonths
    let launcherProtocol: CardPdfLauncher
    var placeholders: [StringPlaceholder]?
    
    init(card: Card, months: PdfMonths, launcherProtocol: CardPdfLauncher, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: ProductHomeNavigatorProtocol, placeholders: [StringPlaceholder]? = nil) {
        self.card = card
        self.months = months
        self.launcherProtocol = launcherProtocol
        self.placeholders = placeholders
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.SelectExtractMonth().page
    }
}

extension MonthSelectionDialogPresenter: MonthSelectionPresenterProtocol {
    
    var titleText: LocalizedStylableText {
        return dependencies.stringLoader.getString("pdfExtract_title_pdfExtractCard")
    }
    
    var subtitleText: LocalizedStylableText {
        if let placeholders = placeholders {
            return dependencies.stringLoader.getString("cardDetail_label_pdfExtract", placeholders)
        } else {
            return dependencies.stringLoader.getString("cardDetail_label_pdfExtract")
        }
    }
    
    var cancelButton: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_cancel")
    }
    
    var continueButton: LocalizedStylableText {
        return dependencies.stringLoader.getString("cardDetail_label_pdfExtractSee")
    }
    
    var firtsMonth: String {
        return months.first?.uppercased() ?? ""
    }
    
    func monthDidSelected(_ month: String) {
        trackEvent(eventId: TrackerPagePrivate.SelectExtractMonth.Action.seePdf.rawValue, parameters: [:])
        launcherProtocol.pdf(forCard: card, month: month)
    }
    
    func didCancelSelection() {
        launcherProtocol.didCancelMonthSelection()
    }
}
