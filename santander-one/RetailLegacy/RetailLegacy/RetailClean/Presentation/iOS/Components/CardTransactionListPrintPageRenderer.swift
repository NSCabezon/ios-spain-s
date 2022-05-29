import UIKit
import UI
import PdfCommons
import Foundation

class CardTransactionListPrintPageRenderer: UIPrintPageRenderer {
    private let stringLoader: StringLoader
    private let timeManager: TimeManager
    private let info: CardTransactionListPdfHeaderInfo
    
    private let headerLabelsFontSize: CGFloat = CGFloat(Double.proportion(a: 19, b: 6, c: Double(0.053 * A4PageConstants.a4Width)) ?? 6)
    private let normalLabelsFontSize: CGFloat = CGFloat(Double.proportion(a: 25, b: 5.4, c: Double(0.069 * A4PageConstants.a4Width)) ?? 5.4)
    private let footerLabelsFontSize: CGFloat = CGFloat(Double.proportion(a: 72, b: 4.8, c: Double(0.2 * A4PageConstants.a4Width)) ?? 4.8)
    
    private var logoSize: CGSize?
    
    init(info: CardTransactionListPdfHeaderInfo, dependencies: PresentationComponent) {
        self.stringLoader = dependencies.stringLoader
        self.timeManager = dependencies.timeManager
        self.info = info
        super.init()
        
        headerHeight = 0.126 * A4PageConstants.a4Height
        footerHeight = 0.066 * A4PageConstants.a4Height
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        drawLogo()
        drawHolder()
        drawCardNumber()
        drawTopSeparator()
        drawCardTransactionsTitle()
    }
    
    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        drawFooterDateItem()
        drawFooterPaginationItem(pageIndex: pageIndex)
    }
    
    private func drawLogo() {
        let firstLogo = Assets.image(named: "logo_santander")
        let logoOffsetX: CGFloat = 0.063 * A4PageConstants.a4Width
        let logoOffsetY: CGFloat = 0.031 * A4PageConstants.a4Height
        firstLogo?.draw(in: CGRect(x: logoOffsetX, y: logoOffsetY, width: 0.168 * A4PageConstants.a4Width, height: 0.02 * A4PageConstants.a4Height))
        logoSize = firstLogo?.size
    }
    
    private func drawHolder() {
        //TITLE
        let holderTitle = stringLoader.getString("pdf_label_holder").text
        let titleOffsetX: CGFloat = logoSize != nil ? 0.063 * A4PageConstants.a4Width + logoSize!.width + 0.079 * A4PageConstants.a4Width : 0.31 * A4PageConstants.a4Width
        let titleOffsetY: CGFloat = 0.031 * A4PageConstants.a4Height
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoBold(size: CGFloat(headerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyDark
        ]
        let titleAttributed = NSAttributedString(string: holderTitle, attributes: titleAttributes)
        titleAttributed.draw(at: CGPoint(x: titleOffsetX, y: titleOffsetY))
        let titleSize: CGSize = titleAttributed.getTextSize()
        
        //INFO
        let holderOffsetX: CGFloat = titleOffsetX + titleSize.width + 0.014*A4PageConstants.a4Width
        let holderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoRegular(size: CGFloat(headerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyDark
        ]
        let holderAttributed: NSAttributedString = NSAttributedString(string: info.holder.capitalized, attributes: holderAttributes)
        holderAttributed.draw(at: CGPoint(x: holderOffsetX, y: titleOffsetY))
    }
    
    private func drawCardNumber() {
        //TITLE
        let accountTitle = stringLoader.getString("pdf_label_cards").text
        let titleOffsetX: CGFloat = logoSize != nil ? 0.063 * A4PageConstants.a4Width + logoSize!.width + 0.079 * A4PageConstants.a4Width : 0.31 * A4PageConstants.a4Width
        let titleOffsetY: CGFloat = 0.047 * A4PageConstants.a4Height
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoBold(size: CGFloat(headerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyDark
        ]
        let titleAttributed = NSAttributedString(string: accountTitle, attributes: titleAttributes)
        titleAttributed.draw(at: CGPoint(x: titleOffsetX, y: titleOffsetY))
        let titleSize: CGSize = titleAttributed.getTextSize()
        
        //INFO
        let accountOffsetX: CGFloat = titleOffsetX + titleSize.width + 0.014*A4PageConstants.a4Width
        let accountAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoRegular(size: CGFloat(headerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyDark
        ]
        let cardNumberAttributed = NSAttributedString(string: maskCard(card: info.cardNumber), attributes: accountAttributes)
        cardNumberAttributed.draw(at: CGPoint(x: accountOffsetX, y: titleOffsetY))
    }
    
    private func maskCard(card: String) -> String {
        var maskedCard = card
        let start = card.index(card.startIndex, offsetBy: 6)
        let end = card.index(card.startIndex, offsetBy: 12)
        maskedCard.replaceSubrange(start..<end, with: "******")
        return maskedCard
    }
    
    private func drawTopSeparator() {
        let offsetY: CGFloat = 0.091*A4PageConstants.a4Height
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.sanGreyLight.cgColor)
        context?.move(to: CGPoint(x: 0.063*A4PageConstants.a4Width, y: offsetY))
        context?.addLine(to: CGPoint(x: A4PageConstants.a4Width - 0.06*A4PageConstants.a4Width, y: offsetY))
        context?.strokePath()
    }
    
    private func drawCardTransactionsTitle() {
        //TITLE
        let accountTransactionsTitle: String
        
        switch (info.fromDate, info.toDate) {
        case (.some(let from), .some(let to)):
            accountTransactionsTitle = stringLoader.getString("pdf_label_transactionsCardDate", [StringPlaceholder(.date, timeManager.toString(date: from, outputFormat: .dd_MMM_yyyy) ?? ""), StringPlaceholder(.date, timeManager.toString(date: to, outputFormat: .dd_MMM_yyyy) ?? "")]).text
        case (.some(let from), nil):
            accountTransactionsTitle = stringLoader.getString("pdf_label_fromDate", [StringPlaceholder(.date, timeManager.toString(date: from, outputFormat: .dd_MMM_yyyy) ?? "")]).text
        case (nil, .some(let to)):
            accountTransactionsTitle = stringLoader.getString("pdf_label_toDate", [StringPlaceholder(.date, timeManager.toString(date: to, outputFormat: .dd_MMM_yyyy) ?? "")]).text
        case (nil, nil):
            accountTransactionsTitle = stringLoader.getString("pdf_label_transactionsCards").text
        }
        
        let titleOffsetX: CGFloat = 0.063 * A4PageConstants.a4Width
        let titleOffsetY: CGFloat = 0.102 * A4PageConstants.a4Height
        
        let titleFontSize: CGFloat = CGFloat(Double.proportion(a: 164, b: 7, c: Double(0.456 * A4PageConstants.a4Width)) ?? 7)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoBold(size: CGFloat(titleFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanRed
        ]
        let titleAttributed = NSAttributedString(string: accountTransactionsTitle, attributes: titleAttributes)
        titleAttributed.draw(at: CGPoint(x: titleOffsetX, y: titleOffsetY))
    }
    
    private func drawFooterDateItem() {
        let dateTitle: String = stringLoader.getString("pdf_text_dateDocuement", [StringPlaceholder(.date, timeManager.toString(date: Date(), outputFormat: .dd_MMM_yyyy) ?? "")]).text
        let titleOffsetX: CGFloat = 0.059 * A4PageConstants.a4Width
        let titleOffsetY: CGFloat = A4PageConstants.a4Height - 0.033 * A4PageConstants.a4Height
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoRegular(size: CGFloat(footerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyMedium
        ]
        let titleAttributed = NSAttributedString(string: dateTitle, attributes: titleAttributes)
        titleAttributed.draw(at: CGPoint(x: titleOffsetX, y: titleOffsetY))
    }
    
    private func drawFooterPaginationItem(pageIndex: Int) {
        let paginationTitle: String = stringLoader.getString("pdf_text_numberPage", [StringPlaceholder(.number, "\(pageIndex + 1)"), StringPlaceholder(.number, "\(numberOfPages)")]).text
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.latoRegular(size: CGFloat(footerLabelsFontSize)),
            NSAttributedString.Key.foregroundColor: UIColor.sanGreyMedium
        ]
        let titleAttributed = NSAttributedString(string: paginationTitle, attributes: titleAttributes)
        let titleSize: CGSize = titleAttributed.getTextSize()
        
        let titleOffsetX: CGFloat = A4PageConstants.a4Width - 0.062 * A4PageConstants.a4Width - titleSize.width
        let titleOffsetY: CGFloat = A4PageConstants.a4Height - 0.033 * A4PageConstants.a4Height
        
        titleAttributed.draw(at: CGPoint(x: titleOffsetX, y: titleOffsetY))
    }
}
