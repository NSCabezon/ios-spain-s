import Foundation
import UI
import CoreFoundationLib

final class MultipleCardHeaderView: UIDesignableView {
    @IBOutlet private weak var datesLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var contractLabel: UILabel!
    @IBOutlet private weak var numberContractLabel: UILabel!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    func setInfo(_ viewModel: NextSettlementViewModel) {
        datesLabel.configureText(withLocalizedString: viewModel.datesText)
        amountLabel.attributedText = viewModel.totalAmount
        numberContractLabel.text = viewModel.contract
    }
}

private extension MultipleCardHeaderView {
    func setAppearance() {
        self.backgroundColor = .clear
        self.datesLabel.setSantanderTextFont(type: .bold, size: 12.0, color: .mediumSanGray)
        self.amountLabel.setSantanderTextFont(type: .bold, size: 36.0, color: .lisboaGray)
        self.amountLabel.adjustsFontSizeToFitWidth = true
        self.contractLabel.configureText(withKey: "nextSettlement_label_contract",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13),
                                                                                              alignment: .right))
        self.contractLabel.textColor = .grafite
        self.numberContractLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        self.numberContractLabel.textAlignment = .right
    }
    
    func setAccessibilityIdentifiers() {
        datesLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.datesLabel.rawValue
        amountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.amountLabel.rawValue
        contractLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.amountLabel.rawValue
        numberContractLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.cardNameLabel.rawValue
    }
}
