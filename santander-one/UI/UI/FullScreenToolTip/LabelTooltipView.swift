import UIKit
import CoreFoundationLib

public struct LabelTooltipViewConfiguration {
    let text: LocalizedStylableText
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat
    let font: UIFont
    let textColor: UIColor
    let labelAccessibilityID: String?
    
    public init(text: LocalizedStylableText,
                left: CGFloat,
                right: CGFloat,
                top: CGFloat = 0.0,
                bottom: CGFloat = 0.0,
                font: UIFont,
                textColor: UIColor,
                labelAccessibilityID: String? = nil) {
        self.text = text
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.font = font
        self.textColor = textColor
        self.labelAccessibilityID = labelAccessibilityID
    }
}

public class LabelTooltipView: XibView {
    @IBOutlet private var label: UILabel!
    @IBOutlet private var leftConstraint: NSLayoutConstraint!
    @IBOutlet private var rightConstraint: NSLayoutConstraint!
    @IBOutlet private var topConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    public convenience init(configuration: LabelTooltipViewConfiguration, labelIdentifier: String? = nil) {
        self.init(frame: CGRect.zero)
        self.setupView(configuration: configuration)
        self.setLabelIdentifier(labelIdentifier)
    }
    
    public func setLabelIdentifier(_ identifier: String?) {
        self.label.accessibilityIdentifier = identifier
    }
}

private extension LabelTooltipView {
    func setupView(configuration: LabelTooltipViewConfiguration) {
        self.label.configureText(withLocalizedString: configuration.text, andConfiguration: LocalizedStylableTextConfiguration(font: configuration.font))
        self.label.textColor = configuration.textColor
        self.leftConstraint.constant = configuration.left
        self.rightConstraint.constant = configuration.right
        self.topConstraint.constant = configuration.top
        self.bottomConstraint.constant = configuration.bottom
        self.label.accessibilityIdentifier = configuration.labelAccessibilityID
    }
}
