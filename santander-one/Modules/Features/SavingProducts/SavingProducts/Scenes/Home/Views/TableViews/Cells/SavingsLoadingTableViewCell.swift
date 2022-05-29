import UIKit
import UI
import CoreFoundationLib

final class SavingsLoadingTableViewCell: UITableViewCell {
    @IBOutlet weak private var loadingImageView: UIImageView!
    @IBOutlet weak private var loadingDescriptionLabel: UILabel!
    @IBOutlet weak private var loadingInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
    }
    
    func setIdentifiers(label: String, infoLabel: String, image: String) {
        loadingDescriptionLabel.accessibilityIdentifier = label
        loadingInfoLabel.accessibilityIdentifier = infoLabel
        loadingImageView.isAccessibilityElement = true
        loadingImageView.accessibilityIdentifier = image
    }
}

private extension SavingsLoadingTableViewCell {
    func appearance() {
        self.loadingImageView.setNewJumpingLoader()
        self.loadingDescriptionLabel.textColor = .lisboaGray
        self.loadingInfoLabel.textColor = .lisboaGray
        self.loadingDescriptionLabel.configureText(withKey: "loading_label_transactionsLoading")
        self.loadingInfoLabel.configureText(withKey: "loading_label_moment")
    }
}
