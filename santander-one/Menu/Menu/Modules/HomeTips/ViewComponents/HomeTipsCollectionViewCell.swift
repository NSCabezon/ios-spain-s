import UIKit
import CoreFoundationLib

protocol HomeTipsCollectionViewCellProtocol {
    func setViewModel(_ viewModel: HomeTipsViewModel)
}

class HomeTipsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var imageTipView: UIImageView!
    @IBOutlet weak private var viewContainer: UIView!
    @IBOutlet weak private var descriptionView: UIView!
    @IBOutlet weak private var tagView: UIView!
    @IBOutlet weak private var tagLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    func setViewModel(_ viewModel: HomeTipsViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.descriptionLabel.configureText(withLocalizedString: viewModel.description)
        if let imageUrl = viewModel.tipImageUrl {
            self.imageTipView.loadImage(urlString: imageUrl)
        } else {
            self.imageTipView.image = nil
        }
        guard let tag = viewModel.tag else { return }
        if tag.text != "" {
            self.tagView.isHidden = false
            self.tagLabel.configureText(withLocalizedString: tag.uppercased())
        } else {
            self.tagView.isHidden = true
            self.tagLabel.text = nil
        }
    }
}

extension HomeTipsCollectionViewCell: HomeTipsCollectionViewCellProtocol {}

private extension HomeTipsCollectionViewCell {
    func configureCell() {
        self.clipsToBounds = false
        self.contentView.backgroundColor = UIColor.clear
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.masksToBounds = true
        self.descriptionView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.shadowColor = UIColor.atmsShadowGray.cgColor
        self.contentView.layer.shadowOpacity = 0.3
        self.contentView.layer.shadowRadius = 2.0
        self.contentView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.viewContainer.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.viewContainer.layer.borderWidth = 1.0
        self.titleLabel.font = .santander(family: .headline, type: .bold, size: 10.0)
        self.titleLabel.textColor = .mediumSanGray
        self.titleLabel.textAlignment = .left
        self.titleLabel.accessibilityIdentifier = AccessibilityHomeTips.tipsLabelTitle.rawValue
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.lineBreakMode = .byTruncatingTail
        self.descriptionLabel.adjustsFontSizeToFitWidth = false
        self.descriptionLabel.accessibilityIdentifier = AccessibilityHomeTips.tipsLabelDescription.rawValue
        self.imageTipView.layer.cornerRadius = 5.0
        self.imageTipView.accessibilityIdentifier = AccessibilityHomeTips.tipsImageView.rawValue
        self.tagView.isHidden = true
        self.tagView.layer.cornerRadius = 3
        self.tagView.backgroundColor = .darkTorquoise
        self.tagLabel.font = .santander(family: .text, type: .bold, size: 10.0)
        self.tagLabel.textColor = .white
        self.tagLabel.accessibilityIdentifier = AccessibilityHomeTips.tipsLabelTag.rawValue
        self.accessibilityIdentifier = AccessibilityHomeTips.tipsBtnTip.rawValue
    }
}
