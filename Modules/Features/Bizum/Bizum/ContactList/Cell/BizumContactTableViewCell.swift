import UI
import ESUI

class BizumContactTableViewCell: UITableViewCell {
    static let identifier = "BizumContactTableViewCell"
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var nameAvatarLabel: UILabel!
    @IBOutlet weak private var bizumImageView: UIImageView!
    @IBOutlet weak private var thumbNailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbNailImageView.image = nil
        self.thumbNailImageView.isHidden = true
        self.nameAvatarLabel.isHidden = true
    }
    
    func configure(_ viewModel: BizumContactListViewModel) {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        if let imageData = viewModel.thumbnailData {
            self.thumbNailImageView.image = UIImage(data: imageData)
            self.thumbNailImageView.isHidden = false
            self.nameAvatarLabel.isHidden = true
            self.thumbNailImageView.layer.cornerRadius = cornerRadius
        } else {
            self.nameAvatarLabel.isHidden = false
            self.thumbNailImageView.isHidden = true
            self.nameAvatarLabel.text = viewModel.initials
        }
        self.nameLabel.text = viewModel.name
        self.nameLabel.isHidden = viewModel.name?.isEmpty ?? true
        self.phoneLabel.text = viewModel.phone.tlfFormatted()
        self.avatarContainerView.backgroundColor = viewModel.colorModel.color
        self.bizumImageView.image = viewModel.isBizum ? ESAssets.image(named: "icnBizumBlack") : nil
    }
}

private extension BizumContactTableViewCell {
    func setAppearance() {
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.nameLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        self.phoneLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
        self.containerView.drawRoundedAndShadowedNew()
    }
}
