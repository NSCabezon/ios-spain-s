import UIKit
import UI
class EmptyViewCell: BaseViewCell {
    @IBOutlet weak var snowImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func configureStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        snowImage.image = Assets.image(named: "icnNoMovement")
    }
    
    public func setInfoText(_ info: LocalizedStylableText) {
        infoLabel.set(localizedStylableText: info)
    }
    
    public func setTitleText(_ title: LocalizedStylableText?) {
        if let title = title {
            titleLabel.set(localizedStylableText: title)
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }

    func applyStyle(style: EmptyViewStyle) {
        switch style {
        case .normal:
            if titleLabel.isHidden {
                infoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 16.0), textAlignment: .center))
            } else {
                titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 16.0), textAlignment: .center))
                infoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0), textAlignment: .center))
            }
        case .globalPosition:
            infoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0), textAlignment: .center))
        }
    }
    
    func setAccessibilityIdetifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        titleLabel.accessibilityIdentifier = identifier + "_title"
        infoLabel.accessibilityIdentifier = identifier + "_info"
    }
}
