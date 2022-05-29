import UIKit
import CoreFoundationLib
import UI

final class PregrantedOfferCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftIcon: UIImageView!
    @IBOutlet private weak var rightIcon: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    
    public var viewIdentifier = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.accessibilityIdentifier = "label_preconceivedTop"
        leftIcon.accessibilityIdentifier = "icnPayTax1White"
        rightIcon.accessibilityIdentifier = "icnArrowRightPG"
        self.layer.cornerRadius = 5.0
    }
    
    func setViewModel(_ viewModel: PregrantedBannerViewModel) {
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.leftIcon.image = Assets.image(named: viewModel.pregrantedBannerColorEnum.icnPayTax())
        self.rightIcon.image = Assets.image(named: viewModel.pregrantedBannerColorEnum.arrowImage())
        self.containerView.backgroundColor = viewModel.pregrantedBannerColorEnum.color()
        self.titleLabel.setSantanderTextFont(size: 16, color: viewModel.pregrantedBannerColorEnum.colorTitle())
        let localizeBannerText = viewModel.pregrantedBannerColorEnum.getLiteral(text: viewModel.pregrantedBannerText, amount: viewModel.amount)
        self.titleLabel.configureText(withLocalizedString: localizeBannerText,
                                      andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.accessibilityIdentifier = self.viewIdentifier
    }
}
