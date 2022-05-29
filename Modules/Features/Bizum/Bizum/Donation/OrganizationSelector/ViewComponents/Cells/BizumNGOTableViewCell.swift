import UI

class BizumNGOTableViewCell: UITableViewCell {
    static let identifier = "BizumNGOTableViewCell"
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    func configure(_ viewModel: BizumNGOListViewModel) {
        self.nameLabel.text = viewModel.alias
        self.subtitleLabel.text = viewModel.displayedIdentifier
    }
}

private extension BizumNGOTableViewCell {
    func setAppearance() {
        self.nameLabel.setSantanderTextFont(type: .bold, size: 18.0, color: .lisboaGray)
        self.subtitleLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .mediumSanGray)
        self.containerView.drawRoundedAndShadowedNew()
    }
    
    func setAccessibilityIdentifiers() {
        self.contentView.accessibilityIdentifier = AccessibilityBizumDonation.listNGOBtnOng
    }
}
