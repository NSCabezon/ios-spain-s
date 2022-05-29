import UIKit
import UI

final class BizumFrequentCollectionViewCell: UICollectionViewCell {
    static let identifier = "BizumFrequentCollectionViewCell"
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var nameAvatarLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var bizumImageView: UIImageView!
    @IBOutlet weak private var viewContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setViewModel(_ viewModel: BizumFrequentViewModel) {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.nameAvatarLabel.text = viewModel.avatarName
        self.nameLabel.text = viewModel.name
        self.phoneLabel.text = viewModel.phone
        self.avatarContainerView.backgroundColor = viewModel.avatarColor
        self.bizumImageView.isHidden = true
    }
}

private extension BizumFrequentCollectionViewCell {
    func setupView() {
        self.configureView()
        self.setupLabels()
    }
    
    func setupLabels() {
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
        self.nameLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        self.phoneLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
    }
    
    func configureView() {
        clipsToBounds = false
        contentView.backgroundColor = UIColor.clear
        viewContainer.layer.cornerRadius = 5
        viewContainer.layer.masksToBounds = true
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.atmsShadowGray.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        viewContainer.layer.borderColor = UIColor.mediumSkyGray.cgColor
        viewContainer.layer.borderWidth = 1.0
    }
    
    func configureAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBizumContact.bizumBtnContact
    }
}
