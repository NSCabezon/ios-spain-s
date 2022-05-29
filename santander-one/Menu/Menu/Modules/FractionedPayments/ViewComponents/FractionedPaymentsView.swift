import UI
import CoreFoundationLib
import UIKit

protocol FractionedPaymentsViewDelegate: AnyObject {
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel)
}

final class FractionedPaymentsView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var bottomSeparatorView: UIView!

    weak var delegate: FractionedPaymentsViewDelegate?
    private var viewModel: FractionedPaymentsViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(model: FractionedPaymentsViewModel,
                    delegate: FractionedPaymentsViewDelegate) {
        self.viewModel = model
        self.delegate = delegate
        removeArrangedSubviewsIfNeeded()
        addCardHeaderView(model)
        addFractionedPaymentsView(model.fractionedPaymentMovements)
    }
}

private extension FractionedPaymentsView {
    func setupView() {
        backgroundColor = .clear
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        setAccessibilityIds()
    }
    
    func addCardHeaderView(_ model: FractionedPaymentsViewModel) {
        let view = FractionedPaymentsCardHeaderView()
        view.configView(model)
        stackView.addArrangedSubview(view)
    }
    
    func addFractionedPaymentsView(_ models: [FractionedPaymentsDetailMovementsViewModel]) {
        models.forEach { model in
            let view = FractionedPaymentsDetailView()
            view.configView(
                model: model,
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
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillBaseView
    }
}

extension FractionedPaymentsView: FractionedPaymentsDetailViewDelegate {
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel) {
        delegate?.didSelectFractionedPaymentMovement(viewModel)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel) {
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
