import CoreText
import UIKit

class ConfirmationItemViewCell: BaseViewCell {
    
    var descriptionText: LocalizedStylableText? {
        didSet {
             if let text = descriptionText {
                 fieldDescription.set(localizedStylableText: text)
             } else {
                 fieldDescription.text = nil
            }
        }
    }
    
    var valueColor: ConfirmationTableViewItemModelColor = .normal {
        didSet {
            switch valueColor {
            case .normal:
                fieldValue.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14), textAlignment: .right))
            case .green:
                fieldValue.applyStyle(LabelStylist(textColor: UIColor.green, font: .latoLight(size: 14), textAlignment: .right))
            }
        }
    }
    
    var valueText: String? {
        didSet {
            fieldValue.text = valueText
        }
    }
    
    var valueLines: Int = 1 {
        didSet {
            fieldValue.numberOfLines = valueLines
        }
    }
    
    var isLast: Bool = false {
        didSet {
            separator.isHidden = isLast
            bottomSpaceConstraint.constant = isLast ? 10: 0
        }
    }
    
    var isFirst: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineBreak: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            fieldValue.lineBreakMode = lineBreak
        }
    }
    
    var valueTextAlignment: NSTextAlignment = .right {
        didSet {
            fieldValue.textAlignment = valueTextAlignment
        }
    }
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fieldDescription: UILabel!
    @IBOutlet weak var fieldValue: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var hieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    private let lateralSpace: CGFloat = 30
    private let verticalSpace: CGFloat = 15
    private let labelSpace: CGFloat = 8
    private let labelMinSize: CGFloat = 50

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldDescription.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 14), textAlignment: .left))
        fieldDescription.numberOfLines = 1
        fieldValue.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14), textAlignment: .right))
        fieldValue.numberOfLines = valueLines
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fieldValue.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14), textAlignment: .right))
    }
    
    func drawElements() {
        fieldValue.frame.size.width = frame.width - lateralSpace - lateralSpace - labelSpace - labelMinSize
        fieldValue.sizeToFit()
        fieldDescription.frame.size.width = frame.width - lateralSpace - lateralSpace - labelSpace - fieldValue.frame.size.width
        fieldDescription.sizeToFit()
        hieghtConstraint.constant = verticalSpace + max(fieldValue.frame.size.height, fieldDescription.frame.size.height) + verticalSpace
    }
    
    func setTopSpace(space: Double) {
        containerTopConstraint.constant = CGFloat(space)
    }
    
    func setAccessibilityIdentifiers(identifiers: ConfirmationTableItemIdentifiers?) {
        if let identifiers = identifiers {
            self.accessibilityIdentifier = identifiers.view
            fieldValue.accessibilityIdentifier = identifiers.value
            fieldDescription.accessibilityIdentifier = identifiers.description
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }

    private func applyRoundedStyle() {
        if isFirst {
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        } else if isLast {
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        } else {
            StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
        }
    }
}
