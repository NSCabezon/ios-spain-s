import UI
import CoreFoundationLib
import ESUI

final class BizumHomeContactSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
}

private extension BizumHomeContactSearchCollectionViewCell {
    func configureView() {
        self.containerView.backgroundColor = .dullRed
        let shadowConfiguration = ShadowConfiguration(color: .darkRed,
                                                      opacity: 0.7,
                                                      radius: 2,
                                                      withOffset: 1,
                                                      heightOffset: 2)
        self.containerView.drawRoundedBorderAndShadow(with: shadowConfiguration,
                                                      cornerRadius: 5,
                                                      borderColor: .clear,
                                                      borderWith: 0)
        self.iconImage.image = ESAssets.image(named: "icnContacts")
        self.titleLabel.font = UIFont.santander(type: .bold, size: 16)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.set(localizedStylableText: localized("bizum_button_viewSchedule"))
        self.subtitleLabel.textColor = UIColor.white
        let subtitleLabelConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 14),
                                                                            textStyles: nil,
                                                                            alignment: nil,
                                                                            lineHeightMultiple: 0.75,
                                                                            lineBreakMode: nil)
        self.subtitleLabel.configureText(withKey: "bizum_text_viewSchedule", andConfiguration: subtitleLabelConfiguration)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumCellSearch
        self.iconImage.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumImageSearch
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumTitleSearch
        self.subtitleLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumSubTitleSearch
    }
}
