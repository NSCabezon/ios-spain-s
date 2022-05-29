import UIKit
import CoreFoundationLib

protocol SummaryItemData: CustomStringConvertible {
    func createSummaryItem() -> SummaryItem
    var isShareable: Bool { get }
}

enum SimpleSummaryDataWrapType {
    case character
    case word
}

class IbanSummaryWrap {
    static func getWrapType(text: String) -> SimpleSummaryDataWrapType {
        if UIScreen.main.isIphone4or5 && text.range(of: #"[A-Z][A-Z][0-9][0-9]\s[0-9]+"#, options: .regularExpression) != nil && !text.uppercased().contains("ES") {
            return .character
        } else {
            return .word
        }
    }
}

struct SimpleSummaryData {
    let field: LocalizedStylableText
    let value: String
    let isShareable: Bool
    let wrapType: SimpleSummaryDataWrapType
    let fieldIdentifier: String?
    let valueIdentifier: String?
    
    init(field: LocalizedStylableText, value: String, wrapType: SimpleSummaryDataWrapType = .word, fieldIdentifier: String? = nil, valueIdentifier: String? = nil) {
        self.isShareable = true
        self.field = field
        self.value = value
        self.wrapType = wrapType
        self.fieldIdentifier = fieldIdentifier
        self.valueIdentifier = valueIdentifier
    }
}

extension SimpleSummaryData: SummaryItemData {
    func createSummaryItem() -> SummaryItem {
        return SummaryItemViewConfigurator<SimpleSummaryItemView, SimpleSummaryData>(data: self)
    }
    
    var description: String {
        return "\(field.text) \(value)"
    }
}

class SummaryItemView: UIView {
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    private var heightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        frame = .zero
        fieldLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        valueLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14.0)))
        valueLabel.numberOfLines = 2
        valueLabel.textAlignment = .right
    }
    
    override func layoutSubviews() {
        guard let superview = superview else {
            return
        }
        fieldLabel.sizeToFit()
        valueLabel.sizeToFit()
        let height =  8 + max(fieldLabel.frame.size.height, valueLabel.frame.size.height) + 8
        if let constraint = heightConstraint {
            constraint.constant = height
        } else {
            let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
            superview.addConstraint(constraint)
            heightConstraint = constraint
        }
        super.layoutSubviews()
    }
}

class SimpleSummaryItemView: SummaryItemView, ConfigurableSummaryItemView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func configure(data: SimpleSummaryData) {
        switch data.wrapType {
        case .character:
            valueLabel.lineBreakMode = .byCharWrapping
        case .word:
            valueLabel.lineBreakMode = .byWordWrapping
        }
        fieldLabel.set(localizedStylableText: data.field)
        if data.field.text.words.count > 1 {
            fieldLabel.numberOfLines = 2
        } else {
            fieldLabel.numberOfLines = 1
        }
        valueLabel.text = data.value
        setAccessibilityIds(data)
    }
}

extension Array where Element == SimpleSummaryData {
    
    mutating func append(field: LocalizedStylableText, value: String) {
        append(SimpleSummaryData(field: field, value: value))
    }
}

private extension SimpleSummaryItemView {
    func setAccessibilityIds(_ data: SimpleSummaryData) {
        if let identifier = data.fieldIdentifier {
            fieldLabel.accessibilityIdentifier = identifier
        } else {
            fieldLabel.accessibilityIdentifier = AccessibilityInstantMoney.summaryBase.rawValue + data.field.text.camelCasedString
        }
        if let identifier = data.valueIdentifier {
            valueLabel.accessibilityIdentifier = identifier
        } else {
            valueLabel.accessibilityIdentifier = AccessibilityInstantMoney.summaryBase.rawValue + data.value.camelCasedString
        }
    }
}
