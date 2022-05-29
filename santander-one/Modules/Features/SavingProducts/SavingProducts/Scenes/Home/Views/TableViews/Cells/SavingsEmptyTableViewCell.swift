import UIKit
import CoreFoundationLib
import UI

final class SavingsEmptyTableViewCell: UITableViewCell {
    static let identifier: String = "EmptyTableViewCell"
    @IBOutlet weak private var emptyImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    func configure(titleKey: String?, descriptionKey: String) {
        self.titleLabel.configureText(withKey: titleKey ?? "")
        self.descriptionLabel.configureText(withKey: descriptionKey)
        self.titleLabel.accessibilityIdentifier = titleKey
        self.descriptionLabel.accessibilityIdentifier = descriptionKey
    }
}

private extension SavingsEmptyTableViewCell {
    func appearance() {
        self.titleLabel.font = .santander(family: .headline, type: .bold, size: 18)
        self.descriptionLabel.font = .santander(family: .micro, type: .regular, size: 16)
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.textColor = .lisboaGray
        DispatchQueue.main.async { self.emptyImageView.setLeavesLoader() }
    }
}
