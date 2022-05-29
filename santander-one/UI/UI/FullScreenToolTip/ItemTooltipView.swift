import UIKit
import CoreFoundationLib

public enum SeparationType {
    case lineal
    case dotted(_ dashPattern: [NSNumber])
}

public struct SeparatorViewConfiguration {
    
    let color: UIColor
    let type: SeparationType
    
    public init(color: UIColor = UIColor.mediumSkyGray.withAlphaComponent(0.35), type: SeparationType = .lineal) {
        self.color = color
        self.type = type
    }
}

public struct ItemTooltipViewConfiguration {

    let image: UIImage?
    let text: LocalizedStylableText
    let separatorViewConfiguration: SeparatorViewConfiguration
    let textFont: UIFont
    
    public init(image: UIImage?, text: LocalizedStylableText, font: UIFont = .santander(family: .text, type: .regular, size: 14), separatorViewConfiguration: SeparatorViewConfiguration = SeparatorViewConfiguration()) {
        self.image = image
        self.text = text
        self.textFont = font
        self.separatorViewConfiguration = separatorViewConfiguration
    }
}

public final class ItemTooltipView: XibView {
    @IBOutlet private weak var itemImageview: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    private var separatorConfiguration: SeparatorViewConfiguration?
    
    public convenience init(configuration: ItemTooltipViewConfiguration) {
        self.init(frame: CGRect.zero)
        setupView(configuration: configuration)
    }
    
    public func viewDidLayout() {
        guard let separatorConfig = separatorConfiguration else { return }
        configureSeparator(separatorConfig)
        separatorView.setNeedsDisplay()
    }
}

private extension ItemTooltipView {
    
    func setupView(configuration: ItemTooltipViewConfiguration) {
        self.separatorConfiguration = configuration.separatorViewConfiguration
        self.itemImageview.image = configuration.image
        self.itemLabel.configureText(withLocalizedString: configuration.text, andConfiguration: LocalizedStylableTextConfiguration(font: configuration.textFont))
        self.itemLabel.textColor = .lisboaGray
        self.setAccessibilityIdentifiers()
    }
    
    func configureSeparator(_ configuration: SeparatorViewConfiguration) {
        switch configuration.type {
        case .lineal:
            separatorView.backgroundColor = configuration.color
        case .dotted(let pattern):
            separatorView.dotted(with: pattern, color: configuration.color.cgColor)
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "itemTooltip_view"
        self.itemLabel.accessibilityIdentifier = "itemTooltip_label"
        self.itemImageview.accessibilityIdentifier = "itemTooltip_image"
    }
}
