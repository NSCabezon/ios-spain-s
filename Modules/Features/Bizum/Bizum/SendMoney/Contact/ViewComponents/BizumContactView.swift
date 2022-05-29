import UI

class BizumContactView: XibView {
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var nameAvatarLabel: UILabel!
    @IBOutlet weak private var deleteButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak private var thumbNailImageView: UIImageView!
    private var viewModel: BizumContactViewModel?
    var action: ((BizumContactViewModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: BizumContactViewModel) {
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
        self.phoneLabel.text = viewModel.phone.tlfFormatted()
        self.avatarContainerView.backgroundColor = viewModel.colorModel?.color
        self.viewModel = viewModel
        if let tag = viewModel.tag {
            self.tag = tag
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let viewModel = self.viewModel else { return }
        action?(viewModel)
    }
    
    func getViewModel() -> BizumContactViewModel? {
        return self.viewModel
    }
}

private extension BizumContactView {
    func setAppearance() {
        self.nameLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        self.phoneLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.deleteButton.setImage(Assets.image(named: "icnRemoveGreen"), for: .normal)
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView.layer.masksToBounds = false
    }
    
    func setupAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBizumContact.bizumBtnContact
        self.deleteButton.accessibilityIdentifier = AccessibilityBizumContact.btnTrash
    }
}
