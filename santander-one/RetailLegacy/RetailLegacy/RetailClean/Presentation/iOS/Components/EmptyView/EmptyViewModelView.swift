import UIKit

enum EmptyViewStyle {
    case normal
    case globalPosition
}

class EmptyViewModelView: TableModelViewItem<EmptyViewCell> {
    
    var text: LocalizedStylableText
    let title: LocalizedStylableText?
    let isForcingHeight: Bool
    let style: EmptyViewStyle
    let inputIdentifier: String?
    
    convenience init(_ text: LocalizedStylableText, forceHeight: Bool = false, identifier: String? = nil, _ privateComponent: PresentationComponent) {
        self.init(title: nil, text: text, identifier: identifier, forceHeight: forceHeight, privateComponent: privateComponent)
    }
    
    init(title: LocalizedStylableText?, text: LocalizedStylableText, identifier: String? = nil, forceHeight: Bool = false, style: EmptyViewStyle = .normal, privateComponent: PresentationComponent) {
        self.text = text
        self.title = title
        self.isForcingHeight = forceHeight
        self.style = style
        self.inputIdentifier = identifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: EmptyViewCell) {
        viewCell.applyStyle(style: style)
        viewCell.setInfoText(text)
        viewCell.setTitleText(title)
        if let inputIdentifier = inputIdentifier {
            viewCell.setAccessibilityIdetifiers(identifier: inputIdentifier)
        }
    }
    
    override var height: CGFloat? {
        return isForcingHeight ? 268.0 : nil
    }
}
