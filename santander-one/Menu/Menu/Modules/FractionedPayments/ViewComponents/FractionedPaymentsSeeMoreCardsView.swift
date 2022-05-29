import UI
import CoreFoundationLib

protocol FractionedPaymentsSeeMoreCardsViewDelegate: AnyObject {
    func didTapInSeeMoreCards()
}

final class FractionedPaymentsSeeMoreCardsView: XibView {
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    private weak var delegate: FractionedPaymentsSeeMoreCardsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setDelegate(delegate: FractionedPaymentsSeeMoreCardsViewDelegate) {
        self.delegate = delegate
    }
}

private extension FractionedPaymentsSeeMoreCardsView {
    func setupView() {
        backgroundColor = .clear
        setCardImage()
        setTitleLabel()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setCardImage() {
        cardImageView.image = Assets.image(named: "icnCardsMenu")?.withRenderingMode(.alwaysTemplate)
        cardImageView.tintColor = .darkTorquoise
    }
    
    func setTitleLabel() {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 12),
            alignment: .left,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        titleLabel.textColor = .darkTorquoise
        titleLabel.numberOfLines = 1
        titleLabel.configureText(
            withKey: "financing_label_seeMoreCards",
            andConfiguration: localizedConfig
        )
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInSeeMoreCards))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInSeeMoreCards() {
        delegate?.didTapInSeeMoreCards()
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.seeMoreCardsBaseView
        cardImageView.accessibilityIdentifier = AccessibilityFractionedPaymentsView.seeMoreCardsImageView
        titleLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.seeMoreCardsTitleLabel
    }
}
