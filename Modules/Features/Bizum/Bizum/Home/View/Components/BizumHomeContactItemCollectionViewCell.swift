import UI
import ESUI

final class BizumHomeContactItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var initalsView: UIView!
    @IBOutlet weak private var initalsLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var bizumImage: UIImageView!
    @IBOutlet weak private var bizumImageHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }

    func set(_ viewModel: BizumHomeContactViewModel) {
        self.initalsView.backgroundColor = viewModel.colorModel.color
        self.initalsLabel.text = viewModel.initials
        self.nameLabel.text = viewModel.name
        self.phoneLabel.text = viewModel.phone?.tlfFormatted()
        self.bizumImage.isHidden = !viewModel.isRegisterInBizum
        self.bizumImageHeight.constant = viewModel.isRegisterInBizum ? 22: 0
    }
}

private extension BizumHomeContactItemCollectionViewCell {
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
        self.initalsView.layer.cornerRadius = 21
        self.initalsLabel.font = UIFont.santander(type: .bold, size: 15)
        self.initalsLabel.textColor = UIColor.white
        self.nameLabel.font = UIFont.santander(type: .bold, size: 14)
        self.nameLabel.textColor = UIColor.white
        self.phoneLabel.font = UIFont.santander(size: 14)
        self.phoneLabel.textColor = UIColor.white
        self.bizumImage.image = ESAssets.image(named: "bizumWhite")
    }
    
    func setAccessibilityIdentifiers() {
        self.initalsLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumInitialsLabel
        self.initalsView.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumInitialsView
        self.nameLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumTitle
        self.phoneLabel.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumSubTitle
        self.bizumImage.accessibilityIdentifier = AccessibilityBizumHomeContact.bizumImage
    }
}
