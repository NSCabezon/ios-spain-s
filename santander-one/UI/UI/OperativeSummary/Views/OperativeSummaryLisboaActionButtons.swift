import UIKit
import CoreFoundationLib

public protocol OperativeSummaryLisboaActionButtonsDelegate: AnyObject {
    func pdfButtonPressed()
    func shareButtonPressed()
}

public final class OperativeSummaryLisboaActionButtons: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    public weak var delegate: OperativeSummaryLisboaActionButtonsDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func addAdditionalButton(_ keyTitle: String, icon: String, action: @escaping () -> Void) {
        let additionalButton = ActionButton()
        let model = ActionButtonFillViewModel(
            viewType: .defaultButton(
                DefaultActionButtonViewModel(
                    title: localized(keyTitle),
                    imageKey: icon,
                    titleAccessibilityIdentifier: keyTitle,
                    imageAccessibilityIdentifier: icon
                )
            )
        )
        additionalButton.setViewModel(model)
        additionalButton.accessibilityIdentifier = "summaryOperativeButton\(keyTitle)"
        additionalButton.isHidden = false
        additionalButton.addAction {
            action()
        }
        stackView.addArrangedSubview(additionalButton)
    }
}

private extension OperativeSummaryLisboaActionButtons {
    func setupView() {
        backgroundColor = .skyGray
        let pdfButton = ActionButton()
        let pdfModel = ActionButtonFillViewModel(
            viewType: .defaultButton(
                DefaultActionButtonViewModel(
                    title: localized("summary_button_downloadPDF"),
                    imageKey: "icnPdfLisboa",
                    titleAccessibilityIdentifier: AccessibilityTransferSummary.btnDownloadPdf.rawValue,
                    imageAccessibilityIdentifier: "icnPdfLisboa"
                )
            )
        )
        pdfButton.setViewModel(pdfModel)
        pdfButton.accessibilityIdentifier = AccessibilityTransferSummary.btnDownloadPdf.rawValue
        pdfButton.addAction {
            self.delegate?.pdfButtonPressed()
        }
        let shareButton = ActionButton()
        let shareModel = ActionButtonFillViewModel(
            viewType: .defaultButton(
                DefaultActionButtonViewModel(
                    title: localized("generic_button_share"),
                    imageKey: "icnShareBostonRedLight",
                    titleAccessibilityIdentifier: AccessibilityTransferSummary.btnShare.rawValue,
                    imageAccessibilityIdentifier: "icnShareBostonRedLight"
                )
            )
        )
        shareButton.setViewModel(shareModel)
        shareButton.accessibilityIdentifier = AccessibilityTransferSummary.btnShare.rawValue
        shareButton.addAction {
            self.delegate?.shareButtonPressed()
        }
        stackView.addArrangedSubview(pdfButton)
        stackView.addArrangedSubview(shareButton)
    }
}
