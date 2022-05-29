import UI
import CoreFoundationLib

class BizumNGOLoadingTableViewCell: UITableViewCell {
    static let identifier = "BizumNGOLoadingTableViewCell"
    var viewController: UIViewController?
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.font = .santander(family: .text, size: 20.0)
            self.titleLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet {
            self.subtitleLabel.font = .santander(family: .text, size: 14.0)
            self.subtitleLabel.textColor = .lisboaGray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
        self.selectionStyle = .none
        self.setAccessibilityIdentifiers()
    }

    func startLoading() {
        self.titleLabel.text = localized("donations_label_loading")
        self.subtitleLabel.text = localized("loading_label_moment")
        self.loadingImage.setPointsLoader()
        self.loadingImage.startAnimating()
    }
}

private extension BizumNGOLoadingTableViewCell {
    func setAccessibilityIdentifiers() {
        self.contentView.accessibilityIdentifier = AccessibilityBizumDonation.listNGOLoadingView
    }
}
