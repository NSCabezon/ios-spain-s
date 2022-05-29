import UIKit
import UI
import CoreFoundationLib

public struct SelectAmortizationHeaderViewModel {
    let name: String
    let pending: String
    
    public init(name: String, pending: String) {
        self.name = name
        self.pending = pending
    }
}

public final class SelectAmortizationStepHeaderView: XibView {
    @IBOutlet private weak var stackviewContainer: UIStackView!
    @IBOutlet private weak var stackviewName: UIStackView!
    @IBOutlet private weak var stackviewPending: UIStackView!
    @IBOutlet private weak var labelNameTitle: UILabel!
    @IBOutlet private weak var labelName: UILabel!
    @IBOutlet private weak var labelPendingTitle: UILabel!
    @IBOutlet private weak var labelPending: UILabel!
    @IBOutlet private weak var viewSeparator: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: SelectAmortizationHeaderViewModel) {
        self.labelName.text = viewModel.name.capitalized
        self.labelPending.text = viewModel.pending
    }
}

private extension SelectAmortizationStepHeaderView {
    func setAppearance() {
        self.setupViews()
        self.setupLabels()
        self.setAccesibilityIdentifiers()
    }
    
    func setupViews() {
        self.view?.backgroundColor = .skyGray
        self.viewSeparator.backgroundColor = .mediumSkyGray
        self.stackviewName.alignment = .leading
        self.stackviewPending.alignment = .trailing
        self.stackviewName.spacing = 0
        self.stackviewPending.spacing = 0
    }
    
    func setupLabels() {
        self.labelNameTitle.textColor = .grafite
        self.labelPendingTitle.textColor = .grafite
        self.labelName.textColor = .lisboaGray
        self.labelPending.textColor = .grafite
        self.labelName.font = .santander(family: .text, type: .regular, size: 15)
        self.labelPending.font = .santander(family: .text, type: .regular, size: 15)
        self.labelName.textAlignment = .left
        self.labelPending.textAlignment = .right
        let configurationBold = LocalizedStylableTextConfiguration(
                    font: .santander(family: .text, type: .bold, size: 12),
                    alignment: .left)
        self.labelNameTitle.configureText(withKey: "amotization_label_loan", andConfiguration: configurationBold)
        let configurationRegular = LocalizedStylableTextConfiguration(
                    font: .santander(family: .text, type: .regular, size: 12),
                    alignment: .right)
        self.labelPendingTitle.configureText(withKey: "amortization_label_pending", andConfiguration: configurationRegular)
    }

    private func setAccesibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.headerView
        self.labelNameTitle.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.headerLabelLoanTitle
        self.labelPendingTitle.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.headerLabelPendingTitle
        self.labelName.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.headerLabelLoan
        self.labelPending.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.headerLabelPending
    }
}
