import UI
import CoreFoundationLib

protocol FractionedPaymentsDetailViewDelegate: AnyObject {
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel)
}

final class FractionedPaymentsDetailView: XibView {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!

    private weak var delegate: FractionedPaymentsDetailViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(model: FractionedPaymentsDetailMovementsViewModel,
                    delegate: FractionedPaymentsDetailViewDelegate) {
        self.delegate = delegate
        setDateLabel(model)
        removeArrangedSubviewsIfNeeded()
        addFractionedPaymentPillDetailMovementView(model)
    }
}

private extension FractionedPaymentsDetailView {
    func setupView() {
        backgroundColor = .clear
        setAccessibilityIds()
    }
    
    func setDateLabel(_ model: FractionedPaymentsDetailMovementsViewModel) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 14),
            alignment: .left,
            lineBreakMode: .none
        )
        dateLabel.configureText(
            withLocalizedString: model.setDateFormatterFiltered(false),
            andConfiguration: localizedConfig
        )
        dateLabel.textColor = .bostonRed
        dateLabel.numberOfLines = 1
    }
    
    func addFractionedPaymentPillDetailMovementView(_ model: FractionedPaymentsDetailMovementsViewModel) {
        model.dayMovements.forEach { viewModel in
            let view = FractionedPaymentsDetailMovementView()
            view.configView(
                model: viewModel,
                delegate: self
            )
            stackView.addArrangedSubview(view)
        }
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !stackView.arrangedSubviews.isEmpty {
            stackView.removeAllArrangedSubviews()
        }
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillContentBaseView
        dateLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillContentMovementDateLabel
    }
}

extension FractionedPaymentsDetailView: FractionedPaymentsDetailMovementViewDelegate {
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel) {
        delegate?.didSelectFractionedPaymentMovement(viewModel)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel) {
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
