import UIKit
import CoreFoundationLib

class TitleLabelStackView: StackItemView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .left))
        self.setAccessibilityIdentifiers()
    }
    
    func setTitle(title: LocalizedStylableText, accessibilityIdentifier: String? = nil) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setTitleLines(_ lines: Int) {
        titleLabel.numberOfLines = lines
    }
    
    func setStyle(_ style: TitleLabelStackStyle) {
        titleLabel.applyStyle(style.configuration)
        titleLabel.setNeedsDisplay()
    }
    
    func setAccessbilityIdentifiers(identifier: String) {
        titleLabel.accessibilityIdentifier = identifier
    }
    
}

enum TitleLabelStackStyle {
    case title
    case titleLight
    case redTitle
    case description
    
    var configuration: LabelStylist {
        switch self {
        case .title:
            return LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .left)
        case .titleLight:
            return LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16), textAlignment: .left)
        case .redTitle:
            return LabelStylist(textColor: .sanRed, font: .latoBold(size: 14), textAlignment: .left)
        case .description:
            return LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .center)
        }
    }
}


private extension TitleLabelStackView {
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityLegacy.TitleLabelStackView.viewTitleLabel
    }
    
}
