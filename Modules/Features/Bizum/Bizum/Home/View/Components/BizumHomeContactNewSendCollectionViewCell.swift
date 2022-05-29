import UI
import CoreFoundationLib
import ESUI

final class BizumHomeContactNewSendCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var contactsNewSendView: UIView!
    @IBOutlet weak private var contactsNewSendImage: UIImageView!
    @IBOutlet weak private var contactsNewSendTitleLabel: UILabel!
    @IBOutlet weak private var contactsNewSendSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
}

private extension BizumHomeContactNewSendCollectionViewCell {
    func configureView() {
        let contactsNewSendViewShadow = ShadowConfiguration(color: UIColor.darkRed,
                                                            opacity: 0.35,
                                                            radius: 2,
                                                            withOffset: 1,
                                                            heightOffset: 2)
        self.contactsNewSendView.drawRoundedBorderAndShadow(with: contactsNewSendViewShadow,
                                                            cornerRadius: 5,
                                                            borderColor: UIColor.clear,
                                                            borderWith: 1)
        self.contactsNewSendView.backgroundColor = .dullRed
        self.contactsNewSendImage.image = ESAssets.image(named: "icnBizumSendWhite")
        self.contactsNewSendTitleLabel.font = UIFont.santander(type: .bold, size: 18)
        self.contactsNewSendTitleLabel.textColor = UIColor.white
        self.contactsNewSendTitleLabel.set(localizedStylableText: localized("transfer_button_newSend"))
        self.contactsNewSendSubtitleLabel.textColor = UIColor.white
        let contactsNewSendSubtitleLabelConfig = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 14),
                                                                                    textStyles: nil,
                                                                                    alignment: nil,
                                                                                    lineHeightMultiple: 0.75,
                                                                                    lineBreakMode: nil)
        self.contactsNewSendSubtitleLabel.configureText(withKey: "bizum_label_sendMoneyToPhone",
                                                        andConfiguration: contactsNewSendSubtitleLabelConfig)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumCellNewSend
        self.contactsNewSendImage.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumImageNewSend
        self.contactsNewSendTitleLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumTitleNewSend
        self.contactsNewSendSubtitleLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumSubTitleNewSend
    }
    
}
