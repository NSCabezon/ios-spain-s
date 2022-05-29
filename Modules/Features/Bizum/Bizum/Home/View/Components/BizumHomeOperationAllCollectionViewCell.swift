import UI
import CoreFoundationLib
import ESUI

final class BizumHomeOperationAllCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
}

private extension BizumHomeOperationAllCollectionViewCell {
    func configureView() {
        self.containerView.backgroundColor = .darkTorquoise
        let shadowConfiguration = ShadowConfiguration(color: .mediumSkyGray,
                                                      opacity: 0.7,
                                                      radius: 2,
                                                      withOffset: 1,
                                                      heightOffset: 2)
        self.containerView.drawRoundedBorderAndShadow(with: shadowConfiguration,
                                                      cornerRadius: 5,
                                                      borderColor: .darkTorquoise,
                                                      borderWith: 0)
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        self.titleLabel.textColor = UIColor.white
        self.textLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        self.textLabel.textColor = UIColor.white
        self.iconImage.image = ESAssets.image(named: "icnBizumSeeAllRecents")
        self.titleLabel.set(localizedStylableText: localized("generic_button_seeAll"))
        self.textLabel.set(localizedStylableText: localized("bizum_text_seeAllReuseHistory"))
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationAllTitle
        self.textLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationAllText
    }
}
