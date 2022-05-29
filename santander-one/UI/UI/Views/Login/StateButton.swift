//

import UIKit

open class StateButton: UIButton {
    
    public var selectedStylist: ButtonStylist?
    public var normalStylist: ButtonStylist?
    
    public func applyHighlightedStylist(normal: ButtonStylist, selected: ButtonStylist) {
        applyButtonStyle(style: normal)
        selectedStylist = selected
        normalStylist = normal
    }
    
    private func applyButtonStyle(style: ButtonStylist) {
        let button: UIButton = self
        button.applyStyle(style)
    }

    override open var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                if let selectedStylist = selectedStylist {
                    applyButtonStyle(style: selectedStylist)
                }
            } else {
                if let normalStylist = normalStylist {
                    applyButtonStyle(style: normalStylist)
                }
            }
            super.isHighlighted = newValue
        }
    }
}

extension UIButton {
    public func adjustTextIntoButton(scaleFactor: CGFloat = 0.5) {
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = scaleFactor
    }
    
    public func labelButtonLines(numberOfLines: Int = 2) {
        titleLabel?.numberOfLines = numberOfLines
    }
    
    public func setTextAligment(_ aligment: NSTextAlignment, for controlState: UIControl.State) {
        if let attributedString = titleLabel?.attributedText {
            let newAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let style = NSMutableParagraphStyle()
            style.alignment = aligment
            newAttributedString.addAttribute(.paragraphStyle(style))
            setAttributedTitle(newAttributedString, for: controlState)
        } else {
            titleLabel?.textAlignment = aligment
        }
    }
}
