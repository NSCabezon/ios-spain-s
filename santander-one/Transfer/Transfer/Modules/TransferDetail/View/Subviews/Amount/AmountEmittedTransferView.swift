import UIKit
import UI
import CoreFoundationLib

final class AmountEmittedTransferView: XibView {
    @IBOutlet private weak var amountContainer: UIView!
    @IBOutlet private weak var descriptionContainer: UIView!
    @IBOutlet private weak var amountTitle: UILabel!
    @IBOutlet private weak var amount: UILabel!
    @IBOutlet private weak var descriptionTitle: UILabel!
    @IBOutlet private weak var concept: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.configureStyle()
        self.configureTexts()
        self.setAccessiblityIdentifiers()
    }
    
    func configureStyle() {
        self.amountTitle.textColor = .grafite
        self.amountTitle.font = .santander(family: .text, type: .regular, size: 13)
        self.descriptionTitle.textColor = .grafite
        self.descriptionTitle.font = .santander(family: .text, type: .regular, size: 13)
        self.amount.textColor = .lisboaGray
        self.amount.font = .santander(family: .text, type: .bold, size: 32)
        self.concept.textColor = .lisboaGray
        self.concept.font = .santander(family: .text, type: .italic, size: 14)
        self.concept.numberOfLines = 0
    }
    
    func addBorder(sides: [UIRectEdge]) {
        sides.forEach { (_) in
            self.borders(for: sides)
        }
    }
    
    private func configureTexts() {
        self.amountTitle.configureText(withKey: "deliveryDetails_label_amount")
        self.descriptionTitle.configureText(withKey: "deliveryDetails_label_concept")
    }
    
    private func setAccessiblityIdentifiers() {
        self.amountTitle.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.amountTitle
        self.amount.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.amount
        self.descriptionTitle.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.conceptTitle
        self.concept.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.concept
    }
    
    func setAmount(_ amountEntity: AmountEntity?) {
        guard let amountEntity = amountEntity else {
            return
        }
        let decorator = MoneyDecorator(amountEntity, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        let attr = decorator.formatAsMillions()
        self.amount.attributedText = attr
    }
    
    func setConcept(_ concept: String?) {
        self.concept.text = concept
        self.descriptionContainer.isHidden = (concept ?? "").isEmpty
    }
}
