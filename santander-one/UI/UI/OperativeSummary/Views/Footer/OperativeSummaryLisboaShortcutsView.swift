import UIKit
import CoreFoundationLib

public final class OperativeSummaryLisboaShortcutsView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OperativeSummaryLisboaShortcutsViewModel) {
        titleLabel.text = viewModel.title
        for vm in viewModel.elements {
            let view = OperativeSummaryLisboaShortcutView()
            view.setViewModel(vm)
            stackView.addArrangedSubview(view)
        }
    }
}

private extension OperativeSummaryLisboaShortcutsView {
    func setupView() {
        titleLabel.accessibilityIdentifier = AccessibilityTransferSummary.whatNowLabel.rawValue
        backgroundColor = .blueAnthracita
        separatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .white
        titleLabel.font = .santander(family: .text, type: .bold, size: 20)
    }
}
