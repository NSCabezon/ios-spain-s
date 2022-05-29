import UI
import CoreFoundationLib

final class LastMovementLoadingTableViewCell: UITableViewCell {
    static let identifier = "LastMovementLoadingTableViewCell"

    @IBOutlet weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet weak var loadingView: LoadingCollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.configureCell()
    }

    public static var bundle: Bundle? {
        return Bundle(for: LastMovementLoadingTableViewCell.self)
    }

    func configureCell() {
        loadingView.startAnimating()
    }
}
