//

import UIKit
import CoreFoundationLib

final class OperativeLabelTableViewCell: BaseViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var title: LocalizedStylableText? {
        didSet {
            guard let title = title else { return }
            typeLabel.set(localizedStylableText: title)
        }
    }
    
    var titleHtml: String? {
        didSet {
            guard let html = titleHtml else { return }
            let data = Data(html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                typeLabel.attributedText = attributedString
            }
        }
    }
    
    var style: LabelStylist? {
        didSet {
            guard let style = style else { return }
            (typeLabel as UILabel).applyStyle(style)
        }
    }    
    
    func applyInsets(insets: Insets?) {
        if let insets = insets {
            bottomConstraint.constant = CGFloat(insets.bottom)
            leftConstraint.constant = CGFloat(insets.left)
            rightConstraint.constant = CGFloat(insets.right)
            topConstraint.constant = CGFloat(insets.top)
            layoutSubviews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeLabel.sizeToFit()
        typeLabel.numberOfLines = 0
        backgroundColor = .uiBackground
        selectionStyle = .none
        setAccessibility()
    }
    
    private func setAccessibility() {
        self.typeLabel.isAccessibilityElement = false
        setAccessibility {
            self.typeLabel.isAccessibilityElement = true
        }
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        typeLabel.accessibilityIdentifier = identifier + "_title"
    }
}

extension OperativeLabelTableViewCell: AccessibilityCapable { }
