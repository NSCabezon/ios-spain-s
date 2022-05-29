//
//  CardboardingCardCell.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//

import UI
import CoreFoundationLib

final class CardboardingCardCell: UITableViewCell {
    static let identifier: String = "CardboardingCardCell"
    static let nibName: String = "CardboardingCardCell"
    static let heightForRow: CGFloat = 112
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var imageViewContainer: UIView!
    @IBOutlet weak private var cardImageView: UIImageView!
    @IBOutlet weak private var aliasLabel: UILabel!
    @IBOutlet weak private var cardInfoLabel: UILabel!
    @IBOutlet weak private var pendingLabel: UILabel!
    @IBOutlet weak private var activateCardStackView: UIStackView!
    @IBOutlet weak private var activateCardLabel: UILabel!
    @IBOutlet weak private var activateCardArrow: UIImageView!
    private var currentTask: CancelableTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.configureLabels()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cardImageView.image = nil
        self.pendingLabel.isHidden = true
        self.activateCardStackView.isHidden = true
        self.currentTask?.cancel()
        self.configureLabels()
    }
    
    func configureCellWithModel(model: CardboardingCardCellViewModel) {
        self.aliasLabel.textColor = .lisboaGray
        self.aliasLabel.configureText(withLocalizedString: LocalizedStylableText(text: model.title, styles: nil),
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18),
                                                                                           lineHeightMultiple: 0.75))
        self.cardInfoLabel.text = model.subtitle
        self.cardImageView.loadImage(urlString: model.imgURL,
                                     placeholder: Assets.image(named: "defaultCard"),
                                     completion: nil)
        self.pendingLabel.isHidden = !model.isInactive
        self.activateCardStackView.isHidden = !model.isInactive
        self.cardImageView.alpha = model.isInactive ? 0.5 : 1.0
        self.setupAccessibilityIdentifiers(type: "\(model.entity.cardType)")
    }
}

private extension CardboardingCardCell {
    func setupView() {
        self.containerView.drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        self.containerView.drawShadow(offset: 2, opaticity: 0.8, color: .lightSanGray, radius: 3)
        self.backgroundColor = .clear
        self.containerView.backgroundColor = .white
        self.pendingLabel.backgroundColor = .purple
        self.pendingLabel.textColor = .white
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .text,
                                                                                type: .bold,
                                                                                size: 10),
                                                               alignment: .center)
        self.pendingLabel.configureText(withKey: "generic_label_pending",
                                        andConfiguration: configuration)
        self.cardImageView.contentMode = .scaleAspectFill
        self.selectionStyle = .none
        self.activateCardArrow.image = Assets.image(named: "icnGoPG")
        self.cardImageView.drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        self.imageViewContainer.backgroundColor = .clear
        self.imageViewContainer.drawShadow(offset: 2, opaticity: 0.8, color: .lightSanGray, radius: 3)
    }
    
    func configureLabels() {
        self.cardInfoLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        self.pendingLabel.roundCorners(corners: .allCorners, radius: 3.0)
        self.activateCardLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .darkTorquoise)
        self.activateCardLabel.configureText(withKey: "cardBoarding_button_activateCard")
    }
    
    func setupAccessibilityIdentifiers(type: String) {
        self.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.cardboardingView
        self.aliasLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.cardAliasLabel
        self.cardInfoLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.cardInfoLabel
        self.activateCardLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.activateCardLabel
        self.activateCardArrow.accessibilityIdentifier =  AccessibilityCardBoardingCardsSelector.activateCardIcon
        self.pendingLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.pendingLabel
        self.cardImageView.isAccessibilityElement = true
        self.setAccessibility { self.cardImageView.isAccessibilityElement = false }
        self.cardImageView.accessibilityIdentifier = "CardBoardingCardsSelector_imgCard_\(type)"
    }
}

extension CardboardingCardCell: AccessibilityCapable { }
