import CoreFoundationLib
import UIKit
import UI

public struct OperativeSummaryPaymentLocationViewModel {
    public let forceLabelsHeight: Bool
    public let action: () -> Void
    
    public init(forceLabelsHeight: Bool, action: @escaping () -> Void) {
        self.action = action
        self.forceLabelsHeight = forceLabelsHeight
    }
}

extension OperativeSummaryPaymentLocationView {
    private var titleText: LocalizedStylableText {
        localized("summary_button_payPlanOne")
    }
    
    private var subtitleText: LocalizedStylableText {
        localized("summary_label_exclusivePlanOne")
    }
    
    private var descriptionText: LocalizedStylableText {
        localized("summary_text_payPlanOne")
    }
}

final class OperativeSummaryPaymentLocationView: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var oneLogoImageView: UIImageView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    private var viewModel: OperativeSummaryPaymentLocationViewModel?
    
    convenience init(_ viewModel: OperativeSummaryPaymentLocationViewModel) {
        self.init(frame: .zero)
        self.viewModel = viewModel
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBottomConstraint()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.view?.backgroundColor = .clear
        descriptionLabel.setSantanderTextFont(size: 13, color: .lisboaGray)
        contentView.drawBorder(cornerRadius: 5, color: .mediumSkyGray, width: 1)
        imageView.image = Assets.image(named: "icnPayPlanOne")
        oneLogoImageView.image = Assets.image(named: "icnOneRed")
        descriptionLabel.configureText(withKey: "summary_text_payPlanOne")
        setAccessibilityIdentifiers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewSelected))
        view?.addGestureRecognizer(tap)
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityTransferSummary.paymentLocationContainer.rawValue
        view?.accessibilityIdentifier = AccessibilityTransferSummary.paymentLocation.rawValue
    }
    
    private func updateBottomConstraint() {
        guard viewModel?.forceLabelsHeight == true else { return }
        let descriptionHeight = descriptionLabel.heightWith(descriptionText.asAttributedString(for: descriptionLabel),
                                                            descriptionLabel.font,
                                                            descriptionLabel.frame.width)
        heightConstraint.constant = descriptionHeight + 20
        view?.setNeedsLayout()
    }
    
    @objc private func viewSelected() {
        viewModel?.action()
    }
}
