import UIKit
import UI
import CoreFoundationLib

final class BizumEmptyTableViewCell: UITableViewCell {
    static let identifier = "BizumEmptyTableViewCell"
    @IBOutlet weak private var emptyTitleLabel: UILabel!
    @IBOutlet weak private var emptyImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
        self.setAppearance()
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
    }
    
    func setSearchTerm(term: String?) {
        guard let searchTerm = term, !searchTerm.isEmpty else {
            self.hideEmptyView()
            return
        }
        self.emptyTitleLabel.configureText(withLocalizedString: localized("globalSearch_title_empty", [StringPlaceholder(.value, searchTerm)]))
        self.showEmptyView()
    }
    
    func setEmptyResults(_ localizedText: LocalizedStylableText) {
        emptyTitleLabel.configureText(withLocalizedString: localizedText)
        showEmptyView()
    }
    
    func hideEmptyView() {
        self.emptyTitleLabel.isHidden = true
        self.emptyImageView.isHidden = true
    }
    
    func showEmptyView() {
        self.emptyTitleLabel.isHidden = false
        self.emptyImageView.isHidden = false
        self.setAccessibilityIdentifiers()
    }
}

private extension BizumEmptyTableViewCell {
    func setAppearance() {
        self.emptyTitleLabel.setSantanderTextFont(type: .regular, size: 18.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityBizumContact.imgLeavesCell
        self.emptyTitleLabel.accessibilityIdentifier = AccessibilityBizumContact.bizumEmptyTitleLabel
    }
}
