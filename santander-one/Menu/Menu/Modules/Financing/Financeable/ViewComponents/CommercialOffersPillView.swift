import UIKit
import UI
import CoreFoundationLib

public protocol CommercialOffersPillViewDelegate: AnyObject {
    func didTapInOffer(_ viewModel: OfferEntityViewModel)
}

public final class CommercialOffersPillView: XibView {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    private var offerId: String?
    private var viewModel: OfferEntityViewModel?
    private weak var delegate: CommercialOffersPillViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func configView(baseURL: String?, offerPill: PullOffersFinanceableCommercialOfferPillEntity, viewModel: OfferEntityViewModel, delegate: CommercialOffersPillViewDelegate) {
        guard let offerId = offerPill.locationId,
              let urlIcon = offerPill.icon,
              let title = offerPill.title,
              let desc = offerPill.desc else {
            return
        }
        self.offerId = offerId
        self.viewModel = viewModel
        self.delegate = delegate
        setImageIcon(baseURL: baseURL, iconURL: urlIcon)
        setTitleLabel(title)
        setDescriptionLabel(desc)
    }
}

private extension CommercialOffersPillView {
    func setupView() {
        backgroundColor = .clear
        setBaseView()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setImageIcon(baseURL: String?, iconURL: String) {
        guard let baseURL = baseURL else { return }
        iconImageView.loadImage(urlString: baseURL + iconURL)
    }
    
    func setBaseView() {
        let shadowConfiguration = ShadowConfiguration(
            color: UIColor.lisboaGray.withAlphaComponent(0.33),
            opacity: 0.7,
            radius: 3.0,
            withOffset: 1,
            heightOffset: 2
        )
        baseView.drawRoundedBorderAndShadow(
            with: shadowConfiguration,
            cornerRadius: 6.0,
            borderColor: .white,
            borderWith: 0
        )
        baseView.backgroundColor = .white
    }
    
    func setTitleLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 14),
            alignment: .center,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        titleLabel.textColor = .lisboaGray
        titleLabel.numberOfLines = 2
    }
    
    func setDescriptionLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 12),
            alignment: .center,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        descriptionLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        descriptionLabel.textColor = .brownishGray
        descriptionLabel.numberOfLines = 0
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFinancingCommercialOffer.offerView
        iconImageView.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.offerIcon
        titleLabel.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.offerTitle
        descriptionLabel.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.offerDesc
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInCommercialOffer))
        baseView.addGestureRecognizer(tap)
    }
    
    @objc func didTapInCommercialOffer() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didTapInOffer(viewModel)
    }
}
