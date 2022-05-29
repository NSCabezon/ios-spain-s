import UIKit
import UI
import CoreFoundationLib

final class ReceivedTransferDetailAmountView: XibView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var conceptTitleLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var separator: DottedLineView!
    
    init(model: ReceivedTransferDetailAmountViewModel) {
        super.init(frame: .zero)
        self.setupView()
        self.configure(with: model)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension ReceivedTransferDetailAmountView {
    func setupView() {
        configureStyle()
        configureTexts()
        setAccessiblityIdentifiers()
    }
    
    func configureStyle() {
        view?.backgroundColor = .mediumSkyGray
        containerView.backgroundColor = .white
        amountTitleLabel.textColor = .grafite
        amountTitleLabel.font = .santander(family: .text, type: .regular, size: 13)
        conceptTitleLabel.textColor = .grafite
        conceptTitleLabel.font = .santander(family: .text, type: .regular, size: 13)
        amountLabel.textColor = .lisboaGray
        amountLabel.font = .santander(family: .text, type: .bold, size: 32)
        conceptLabel.textColor = .lisboaGray
        conceptLabel.font = .santander(family: .text, type: .italic, size: 14)
        conceptLabel.numberOfLines = 0
        separator.strokeColor = .mediumSkyGray
    }
    
    func configureTexts() {
        amountTitleLabel.configureText(withKey: "deliveryDetails_label_amount")
        conceptTitleLabel.configureText(withKey: "deliveryDetails_label_concept")
    }
    
    func setAccessiblityIdentifiers() {
        amountTitleLabel.accessibilityIdentifier = "deliveryDetails_label_amount"
        amountLabel.accessibilityIdentifier = TransferReceivedDetailAccessibilityIdentifier.amount
        conceptTitleLabel.accessibilityIdentifier = "deliveryDetails_label_concept"
        conceptLabel.accessibilityIdentifier = TransferReceivedDetailAccessibilityIdentifier.concept
    }
    
    func configure(with model: ReceivedTransferDetailAmountViewModel) {
        amountLabel.attributedText = model.transferAmount
        conceptLabel.text = model.concept
    }
}
