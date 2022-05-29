import UI
import CoreFoundationLib

class WithholdingView: XibView {
    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fixedLabel: UILabel!
    @IBOutlet weak var leavingDate: UILabel!
    @IBOutlet weak var separatorView: DottedLineView!
    
    convenience init(_ viewModel: WithholdingViewModel) {
        self.init(frame: .zero)
        self.setAppearance()
        self.setViewModel(viewModel)
        self.setAccessibilityIdentifiers()
    }

    private func setAppearance() {
        entryDateLabel.font = .santander(family: .text, type: .bold, size: 13.0)
        entryDateLabel.textColor = .mediumSanGray
        conceptLabel.font = .santander(family: .text, type: .bold, size: 14.0)
        conceptLabel.textColor = .lisboaGray
        amountLabel.font = .santander(family: .text, type: .bold, size: 14.0)
        amountLabel.textColor = .lisboaGray
        fixedLabel.font = .santander(family: .text, type: .light, size: 12.0)
        fixedLabel.textColor = .grafite
        leavingDate.font = .santander(family: .text, type: .bold, size: 12.0)
        leavingDate.textColor = .grafite
        separatorView?.strokeColor = .darkSky
    }
    
    private func setViewModel(_ viewModel: WithholdingViewModel) {
        entryDateLabel.text = viewModel.entryDate
        conceptLabel.text = viewModel.concept
        amountLabel.attributedText = viewModel.getAmountFormatted(font: .santander(family: .text, type: .bold, size: 14.0))
        fixedLabel.text = viewModel.fixedLabel
        leavingDate.text = viewModel.leavingDate
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityWithholdingView.withholdingView
        self.entryDateLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelEntrydate
        self.conceptLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelConcept
        self.amountLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelAmount
        self.fixedLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelConsolidated
        self.leavingDate.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelLeavingDate
    }
}
