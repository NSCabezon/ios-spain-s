import UIKit
import UI
import CoreFoundationLib

final class BizumNGOEmptyTableViewCell: UITableViewCell {
    static let identifier = "BizumNGOEmptyTableViewCell"
    @IBOutlet weak private var emptyTitleLabel: UILabel!
    @IBOutlet weak private var emptyMessageLabel: UILabel!
    @IBOutlet weak private var emptyImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
        self.setAppearance()
        self.setAccessibilityIdentifiers()
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
        self.accessibilityIdentifier = AccessibilityBizumContact.imgLeavesCell
    }
    
    func setTitle(_ localizedTitleText: LocalizedStylableText, localizedMessageText: LocalizedStylableText) {
        emptyTitleLabel.configureText(withLocalizedString: localizedTitleText)
        emptyMessageLabel.configureText(withLocalizedString: localizedMessageText)
        showEmptyView()
    }
    
    func hideEmptyView() {
        self.emptyTitleLabel.isHidden = true
        self.emptyMessageLabel.isHidden = true
        self.emptyImageView.isHidden = true
    }
    
    func showEmptyView() {
        self.emptyTitleLabel.isHidden = false
        self.emptyMessageLabel.isHidden = false
        self.emptyImageView.isHidden = false
    }
}

private extension BizumNGOEmptyTableViewCell {
    func setAppearance() {
        self.emptyTitleLabel.setSantanderTextFont(type: .regular, size: 20.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        self.contentView.accessibilityIdentifier = AccessibilityBizumDonation.listNGOEmptyView
    }
}
