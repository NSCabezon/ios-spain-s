import UI
import CoreFoundationLib

final class LastMovementEmptyTableViewCell: UITableViewCell {
    static let identifier = "LastMovementEmptyTableViewCell"
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet weak var emptyView: SingleEmptyView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.configureCell()
    }

    public static var bundle: Bundle? {
        return Bundle(for: LastMovementEmptyTableViewCell.self)
    }
    
    func configureCell() {
        emptyView.titleFont(UIFont.santander(family: .headline, size: 20.0))
        emptyView.updateTitle(localized("deeplink_alert_noFractionalTransactions"))
        emptyView.centerView()
    }
}
