import UI
import CoreFoundationLib
import UIKit
import UIOneComponents

final class FractionedPaymentsCardHeaderView: XibView {
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view?.applyOneGradient(OneGradientType.oneGrayGradient(direction: GradientDirection.topToBottom))
    }
    
    func configView(_ model: FractionedPaymentsViewModel) {
        showCardImage(model.cardUrlString)
        removeArrangedSubviewsIfNeeded()
        addCardTitleLabel(model.cardName)
        addCardDetailLabel(model.cardTypeWithIban)
    }
}

private extension FractionedPaymentsCardHeaderView {
    func setupView() {
        backgroundColor = .clear
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillHeaderBaseView
    }
    
    func showCardImage(_ urlString: String) {
        handleCardImage(urlString)
        cardImageView.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillHeaderImageView
    }
    
    func handleCardImage(_ imageUrl: String?) {
        let defaultImage = Assets.image(named: "defaultCard")
        if let imageUrl = imageUrl {
            cardImageView.loadImage(
                urlString: imageUrl,
                placeholder: defaultImage,
                completion: nil
            )
        } else {
            cardImageView.image = defaultImage
        }
    }
    
    func addCardTitleLabel(_ text: String) {
        let label = UILabel()
        label.textColor = .lisboaGray
        label.numberOfLines = 1
        label.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillHeaderTitleLabel
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 14),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        label.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        stackView.addArrangedSubview(label)
    }
    
    func addCardDetailLabel(_ text: String) {
        let label = UILabel()
        label.textColor = .brownishGray
        label.numberOfLines = 1
        label.accessibilityIdentifier = AccessibilityFractionedPaymentsView.pillHeaderDetailLabel
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 12),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        label.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        stackView.addArrangedSubview(label)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !stackView.arrangedSubviews.isEmpty {
            stackView.removeAllArrangedSubviews()
        }
    }
}
