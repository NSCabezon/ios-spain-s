import Foundation
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

final class CardDetailDataView: XibView {
    
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardExpirationLabel: UILabel!
    @IBOutlet private weak var cardHolderLabel: UILabel!
    @IBOutlet private weak var inactiveCardView: UIView!
    @IBOutlet private weak var inactiveCardBackgroundView: UIView!
    @IBOutlet private weak var inactiveCardTitle: UILabel!
    @IBOutlet private weak var inactiveCardSubtitle: UILabel!
    @IBOutlet private weak var inactiveCardButton: LisboaButton!
    private var card: CardDetail?
    let onTouchButtonSubject = PassthroughSubject<Void, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(card: CardDetail) {
        inactiveCardView.isHidden = !card.isInactive
        if let cardImageUrlString = card.fullCardImageStringUrl {
            cardImageView.loadImage(urlString: cardImageUrlString,
                                    placeholder: Assets.image(named: "defaultCard"),
                                    completion: nil)
        }
        cardImageView.alpha = card.hasDisabledStyle ? 0.5 : 1
        cardNumberLabel.text = card.pan
        cardNumberLabel.textColor = card.tintColor
        cardExpirationLabel.text = card.expirationDate
        cardExpirationLabel.textColor = card.tintColor
        cardHolderLabel.text = card.stampedName
        cardHolderLabel.textColor = card.tintColor
        self.card = card
    }
}

private extension CardDetailDataView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.cardNumberLabel.setSantanderTextFont(type: .bold, size: 20, color: card?.tintColor ?? .black)
        self.cardExpirationLabel.setSantanderTextFont(type: .bold, size: 14, color: card?.tintColor ?? .black)
        self.cardHolderLabel.setSantanderTextFont(type: .bold, size: 14, color: card?.tintColor ?? .black)
        self.inactiveCardTitle.font = .santander(family: .text, type: .regular, size: 16)
        self.inactiveCardTitle.textColor = .lisboaGray
        self.inactiveCardTitle.configureText(withKey: "cardHome_label_inactiveCard")
        self.inactiveCardSubtitle.font = .santander(family: .text, type: .regular, size: 12)
        self.inactiveCardSubtitle.textColor = .lisboaGray
        self.inactiveCardSubtitle.text = localized("cardHome_text_activateCard")
        self.inactiveCardButton.backgroundPressedColor = .darkTorquoise
        self.inactiveCardButton.backgroundNormalColor = .darkTorquoise
        self.inactiveCardButton.setTitle(localized("cardBoarding_button_activateCard"), for: .normal)
        self.inactiveCardButton.setTitleColor(.white, for: .normal)
        self.inactiveCardButton.titleLabel?.font = .santander(family: .text, type: .bold, size: 14)
        self.inactiveCardButton.addAction { [weak self] in
            self?.onTouchButtonSubject.send()
        }
        self.inactiveCardBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.inactiveCardBackgroundView.layer.cornerRadius = 8
        self.setAccessibilityIdentifiers()
    }
            
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailCard
        self.cardImageView?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailCardImage
        self.cardHolderLabel?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailHolderName
        self.cardExpirationLabel?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailExpirationDate
        self.cardNumberLabel?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailPan
        self.inactiveCardView?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailViewCardboarding
        self.inactiveCardTitle?.accessibilityIdentifier = AccessibilityCardDetail.cardHomeLabelInactiveCard
        self.inactiveCardSubtitle?.accessibilityIdentifier = AccessibilityCardDetail.cardHomeTextActivateCard
        self.inactiveCardButton?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailBtnActivateCard
    }
}
