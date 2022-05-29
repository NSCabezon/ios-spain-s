import UIKit
import CoreFoundationLib

class OldSelectableProductViewCell: UITableViewCell {
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoContainer.drawRoundedAndShadowed()
        self.infoContainer.backgroundColor = .uiWhite
        self.aliasLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        self.identifierLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        self.amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 26.0)))
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.setAccessibilityIdentifiers()
    }

    func setup(viewModel: OldSelectableAccountViewModel) {
        self.aliasLabel.text = viewModel.account.getAlias()?.uppercased()
        self.identifierLabel.text = viewModel.account.getIBANPapel()
        self.amountLabel.text = viewModel.account.getAmountUI()
    }
}

private extension OldSelectableProductViewCell {
    private func setAccessibilityIdentifiers() {
        self.aliasLabel.accessibilityIdentifier = AccesibilityLegacy.OldSelectableProductView.productSelectionTitleTextView
        self.identifierLabel.accessibilityIdentifier = AccesibilityLegacy.OldSelectableProductView.productSelectionSubtitleTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityLegacy.OldSelectableProductView.productSelectionAmountTextView
    }
}
