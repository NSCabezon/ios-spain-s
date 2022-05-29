import UIKit

enum ConfirmationTableViewItemModelColor {
    case normal
    case green
}

typealias ConfirmationTableItemIdentifiers = (view: String?, description: String?, value: String?)

class ConfirmationTableViewItemModel: TableModelViewItem<ConfirmationItemViewCell> {
    
    private let descriptionText: LocalizedStylableText
    private let valueText: String
    private let isLast: Bool
    private let valueColor: ConfirmationTableViewItemModelColor
    private let isFirst: Bool
    private let valueLines: Int
    private var lineBreak: NSLineBreakMode
    private var textAlignment: NSTextAlignment
    private let descriptionIdentifier: String?
    private let valueIdentifier: String?
    
    init(_ descriptionText: LocalizedStylableText,
         _ valueText: String,
         _ isLast: Bool = false,
         _ privateComponent: PresentationComponent,
         _ valueColor: ConfirmationTableViewItemModelColor = .normal,
         isFirst: Bool = false,
         valueLines: Int = 1,
         lineBreak: NSLineBreakMode = .byTruncatingMiddle,
         textAlignment: NSTextAlignment = .right,
         accessibilityIdentifier: String? = nil,
         descriptionIdentifier: String? = nil,
         valueIdentifier: String? = nil) {
        self.descriptionText = descriptionText
        self.valueText = valueText
        self.isLast = isLast
        self.valueColor = valueColor
        self.isFirst = isFirst
        self.valueLines = valueLines
        self.lineBreak = lineBreak
        self.textAlignment = textAlignment
        self.descriptionIdentifier = descriptionIdentifier
        self.valueIdentifier =  valueIdentifier
        super.init(dependencies: privateComponent)
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    override func bind(viewCell: ConfirmationItemViewCell) {
        viewCell.valueLines = valueLines
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
        viewCell.descriptionText = descriptionText
        viewCell.valueColor = valueColor
        viewCell.valueText = valueText
        viewCell.lineBreak = lineBreak
        viewCell.valueTextAlignment = textAlignment
        viewCell.setAccessibilityIdentifiers(identifiers: (accessibilityIdentifier, descriptionIdentifier, valueIdentifier))
    }
}
