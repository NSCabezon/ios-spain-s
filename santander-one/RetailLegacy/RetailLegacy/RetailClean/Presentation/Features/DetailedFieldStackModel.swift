import Foundation
import UIKit

class DetailedFieldStackModel: StackItem<DetailedFieldStackView> {

    var isFirst = false
    var isLast = false
    let title: LocalizedStylableText
    let detail: LocalizedStylableText
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    let actionClosure: (() -> Void)?
    
    init(title: LocalizedStylableText,
         detail: LocalizedStylableText,
         insets: Insets = Insets(left: 14, right: 14, top: 0, bottom: 0), actionClosure: (() -> Void)? = nil) {
        self.title = title
        self.detail = detail
        self.actionClosure = actionClosure
        super.init(insets: insets)
    }
    
    override func bind(view: DetailedFieldStackView) {
        view.setTitle(title)
        view.setDetail(detail)
        view.isFirst = isFirst
        view.isLast = isLast
        view.setOptionClosure(actionClosure)
        view.setDetailLineBreakMode(lineBreakMode)
    }
    
    func setDetailLineBreakMode(_ lineBreakMode: NSLineBreakMode) {
        self.lineBreakMode = lineBreakMode
    }
}
