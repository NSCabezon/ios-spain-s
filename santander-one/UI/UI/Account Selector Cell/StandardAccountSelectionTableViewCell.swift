import UIKit
import CoreFoundationLib

public final class StandardAccountSelectionTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var accountTitleLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var availableAmountTitleLabel: UILabel!
    @IBOutlet private weak var availableAmountLabel: UILabel!
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.containerView.drawRoundedAndShadowedNew(radius: 5.0, borderColor: .lightSkyBlue)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.accountTitleLabel.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
        self.accountNumberLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        self.availableAmountTitleLabel.setSantanderTextFont(size: 14, color: .mediumSanGray)
        self.availableAmountLabel.setSantanderTextFont(size: 22, color: .lisboaGray)
        self.accountTitleLabel.numberOfLines = 2
        self.setAccessibilityIdentifiers("")
    }
    
    public func setup(with viewModel: AccountSelectionViewModelProtocol) {
        self.availableAmountTitleLabel.text = localized("accountHome_label_availableBalance")
        self.accountTitleLabel.text = viewModel.alias
        self.accountNumberLabel.text = viewModel.iban
        self.availableAmountLabel.attributedText = viewModel.currentBalanceAmount
    }
    
    public func setHighlighted() {
        self.containerView.backgroundColor = .darkTorquoise
        self.accountTitleLabel.textColor = .white
        self.accountNumberLabel.textColor = .white
        self.availableAmountTitleLabel.textColor = .white
        self.availableAmountLabel.textColor = .white
    }
    
    public func setUnhighlighted() {
        self.containerView.backgroundColor = .white
        self.accountTitleLabel.textColor = .lisboaGray
        self.accountNumberLabel.textColor = .lisboaGray
        self.availableAmountTitleLabel.textColor = .lisboaGray
        self.availableAmountLabel.textColor = .lisboaGray
    }
    
    public func setAccessibilityIdentifiersWithindex(_ index: String) {
        setAccessibilityIdentifiers(index)
    }
}

private extension StandardAccountSelectionTableViewCell {
    func setAccessibilityIdentifiers(_ index: String) {
        containerView.accessibilityIdentifier = AccessibilityTransferOrigin.accountArea.rawValue + index
        accountTitleLabel.accessibilityIdentifier = AccessibilityTransferOrigin.accountAliasLabel.rawValue + index
        accountNumberLabel.accessibilityIdentifier = AccessibilityTransferOrigin.accountIBANLabel.rawValue + index
        availableAmountTitleLabel.accessibilityIdentifier = AccessibilityTransferOrigin.accountAvailableBalanceLabel.rawValue + index
        availableAmountLabel.accessibilityIdentifier = AccessibilityTransferOrigin.accountBalanceLabel.rawValue + index
    }
}
