import UIKit
import CoreFoundationLib

class AccountOperativeHeaderView: BaseHeader, ViewCreatable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var amountlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        self.setAccessibilityIdentifiers()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoMedium(size: 16), textAlignment: .left))
        accountLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoLight(size: 14), textAlignment: .left))
        amountlabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .right))
    }
    
    func configure(alias: String, iban: String, amount: String) {
        titleLabel.text = alias
        accountLabel.text = iban
        amountlabel.text = amount
    }
}

private extension AccountOperativeHeaderView {
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityLegacy.AccountHeaderStackView.viewGenericHeaderOperativeTitleLeftLabel
        self.accountLabel.accessibilityIdentifier = AccesibilityLegacy.AccountHeaderStackView.viewGenericHeaderOperativeDescriptionLeftLabel
        self.amountlabel.accessibilityIdentifier = AccesibilityLegacy.AccountHeaderStackView.viewGenericHeaderOperativeRightLabel
    }
}
