import UIKit
import UI
import CoreFoundationLib

public final class CardControlDistributionActionView: XibView {

    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ text: String) {
        titleLabel.configureText(
            withKey: text,
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                lineHeightMultiple: 0.8
            ))
    }
}

private extension CardControlDistributionActionView {
    func setupView() {
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .brownishGray
        roundedView.layer.cornerRadius = roundedView.layer.bounds.height/2
        roundedView.backgroundColor = .coolGray
        backgroundColor = .clear
        setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        titleLabel.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemActionLabel
    }
}
