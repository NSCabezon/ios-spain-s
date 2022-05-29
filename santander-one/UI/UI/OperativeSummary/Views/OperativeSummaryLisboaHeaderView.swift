import CoreFoundationLib
import UIKit

public final class OperativeSummaryLisboaHeaderView: XibView {
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OperativeSummaryLisboaHeaderViewModel) {
        checkImageView.image = Assets.image(named: viewModel.imageName)
        checkImageView.accessibilityIdentifier = viewModel.imageName
        titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75, lineBreakMode: .byTruncatingTail))
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        if let subtitleKey = viewModel.subtitleKey {
            subtitleLabel.configureText(withKey: subtitleKey)
        }
        descriptionLabel.configureText(withKey: viewModel.descriptionKey, andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: viewModel.isOk ? 14 : 16)))
    }
}

private extension OperativeSummaryLisboaHeaderView {
    func setupView() {
        backgroundColor = .skyGray
        accessibilityIdentifier = "summe_title_perfect"
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .headline, type: .bold, size: 28)
        titleLabel.accessibilityIdentifier = "summe_title_perfect_title"
        subtitleLabel.textColor = .mediumSanGray
        subtitleLabel.font = .santander(family: .headline, type: .regular, size: 16)
        subtitleLabel.accessibilityIdentifier = "summary_label_sentMoneyOk"
        descriptionLabel.textColor = .grafite
        descriptionLabel.accessibilityIdentifier = "summary_subtitle_paidOnePay"
    }
}

extension OperativeSummaryLisboaHeaderView {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            let elements = self.groupElements([titleLabel,
                                               subtitleLabel,
                                               descriptionLabel])
            groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }
}
