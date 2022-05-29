import CoreFoundationLib
import UIKit
import UI

private extension AviosBanner {
    var titleKey: String {
        return "pg_title_avios"
    }
    
    var subtitleKey: String {
        return "pg_text_avios"
    }
}

final class AviosBanner: DesignableView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    var calculatedHeight: CGFloat {
        let stackTopToSuperTopConstant: CGFloat = 7
        let stackBottomToSuperBottomConstant: CGFloat = 8
        let titleHeight = titleLabel.heightWith(localized(titleKey).asAttributedString(for: titleLabel),
                                                titleLabel.font,
                                                titleLabel.frame.width)
        let subtitleHeight = subtitleLabel.heightWith(localized(subtitleKey).asAttributedString(for: subtitleLabel),
                                                      subtitleLabel.font,
                                                      subtitleLabel.frame.width)
        
        return stackTopToSuperTopConstant + titleHeight + subtitleHeight + stackBottomToSuperBottomConstant
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        accessibilityIdentifier = AccessibilityAvios.pgBtnZonaAvios
        contentView?.backgroundColor = .clear
        imageView.image = Assets.image(named: "icnOneIberia")
        imageView.accessibilityIdentifier = "icnOneIberia"
        arrowImageView.image = Assets.image(named: "icnArrowLightRight")
        arrowImageView.accessibilityIdentifier = "icnArrowLightRight"
        separator.backgroundColor = .mediumSkyGray
        titleLabel.configureText(
            withKey: titleKey,
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .headline, type: .regular, size: 16),
                lineHeightMultiple: 0.8,
                lineBreakMode: .byWordWrapping
            )
        )
        titleLabel.accessibilityIdentifier = titleKey
        subtitleLabel.configureText(
            withKey: subtitleKey,
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                lineHeightMultiple: 0.8,
                lineBreakMode: .byWordWrapping
            )
        )
        subtitleLabel.accessibilityIdentifier = subtitleKey
    }
}
