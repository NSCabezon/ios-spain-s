import Foundation
import UI
import CoreFoundationLib

protocol FractionedPaymentsDetailMovementViewDelegate: AnyObject {
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel)
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel)
}

final class FractionedPaymentsDetailMovementView: XibView {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var seeFractionableOptionsView: SeeFractionableOptionsView!
    
    private weak var delegate: FractionedPaymentsDetailMovementViewDelegate?
    private var viewModel: FractionablePurchaseViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(model: FractionablePurchaseViewModel,
                    delegate: FractionedPaymentsDetailMovementViewDelegate) {
        self.viewModel = model
        self.delegate = delegate
        setDescriptionLabel(model)
        setAmountLabel(model)
        setFractionableOptionsView(model)
    }
}

private extension FractionedPaymentsDetailMovementView {
    func setupView() {
        backgroundColor = .clear
        setAccessibilityIds()
        addTapGesture()
    }
    
    func setDescriptionLabel(_ model: FractionablePurchaseViewModel) {
        guard let text = model.movementTitle else {
            return
        }
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 14),
            alignment: .left,
            lineBreakMode: .none
        )
        descriptionLabel.configureText(
            withKey: text.camelCasedString,
            andConfiguration: localizedConfig
        )
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.numberOfLines = 1
    }
    
    func setAmountLabel(_ model: FractionablePurchaseViewModel) {
        let attributedText = createAttributedStringForAmount(model.amount)
        amountLabel.attributedText = attributedText
        amountLabel.textColor = .lisboaGray
        amountLabel.numberOfLines = 1
    }
    
    func createAttributedStringForAmount(_ amount: AmountEntity?) -> NSAttributedString {
        guard let amount = amount else {
            return NSAttributedString()
        }
        let moneyDecorator = MoneyDecorator(
            amount,
            font: .santander(family: .text, type: .bold, size: 20),
            decimalFontSize: 16
        )
        guard let attributedText = moneyDecorator.getFormatedCurrency() else {
            return NSAttributedString()
        }
        return attributedText
    }
    
    func setFractionableOptionsView(_ model: FractionablePurchaseViewModel) {
        let feeViewModels = model.getMovementTransaction()?.feeViewModels ?? []
        seeFractionableOptionsView.delegate = self
        seeFractionableOptionsView.configView(
            model.getIsExpanded(),
            feeViewModels: feeViewModels
        )
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapInPillDetailMovement)
        )
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInPillDetailMovement() {
        guard let model = self.viewModel else {
            return
        }
        delegate?.didSelectFractionedPaymentMovement(model)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillContentMovementBaseView
        descriptionLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillContentMovementDescriptionLabel
        amountLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillContentMovementAmountLabel
    }
}

extension FractionedPaymentsDetailMovementView: DidTapInSeeFractionableOptionsViewDelegate {
    func didTapInSelector() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
