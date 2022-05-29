import UIKit
import UI
import CoreFoundationLib

final class SettlementMovementTotalCell: UIDesignableView {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
        self.setAccessibilityIdentifiers()
    }
    
    func configureCell(_ text: String) {
        self.amountLabel.text = text
        self.isUserInteractionEnabled = false
    }
}

private extension SettlementMovementTotalCell {
    func setupView() {
        self.backgroundColor = .clear
        self.descriptionLabel.configureText(withKey: "nextSettlement_label_totalSpent",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        self.descriptionLabel.textColor = .mediumSanGray
        self.amountLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        descriptionLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.totalExpenseLabel.rawValue
        amountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.totalExpenseAmountLabel.rawValue
    }
}
