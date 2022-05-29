import UIKit
import CoreFoundationLib

extension UIButton: StylableLocalizedButton {
    public func set(localizedStylableText: LocalizedStylableText, state: UIControl.State, completion: (() -> Void)? = nil) {
        if localizedStylableText.styles != nil, let label = titleLabel {
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: label.font, andAlignment: label.textAlignment)
            label.font = UIFont.font(name: label.font.fontName, size: label.font.pointSize)
            self.setAttributedTitle(text, for: state)
        } else {
            setTitle(localizedStylableText.text, for: state)
            if let completion = completion {
                completion()
            }
        }
    }
    
    public func setImageName(_ name: String, withTintColor tintColor: UIColor) {
        if let image = Assets.image(named: name) {
            self.tintColor = tintColor
            self.setImage(image, for: .normal)
        }
    }
}
