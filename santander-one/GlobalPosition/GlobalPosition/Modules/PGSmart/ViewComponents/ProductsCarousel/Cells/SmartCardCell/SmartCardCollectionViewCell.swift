//
//  SmartCardCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Luis Escámez Sánchez on 20/12/2019.
//

import CoreFoundationLib
import UI

final class SmartCardCollectionViewCell: UICollectionViewCell, GeneralPGCellProtocol {
    
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var cardAliasLabel: UILabel!
    @IBOutlet weak var securedCardPan: UILabel!
    @IBOutlet weak var availableMoneyTitleLabel: UILabel!
    @IBOutlet weak var availableMoneyDescriptionLabel: BluringLabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var activatePrepaidButton: UIButton!
    @IBOutlet weak var lastMovementsStackView: UIStackView!
    @IBOutlet weak var lastMovementsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastMovementsNumberLabel: UILabel!
    @IBOutlet weak var movementsLabel: UILabel!
    
    private var currentTask: CancelableTask?
    private var cardType: CardType?
    weak var delegate: CardProductTableViewCellDelegate?
    private var card: Any?

    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        setLabelStyle()
        setButtonStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        availableMoneyDescriptionLabel.initializeCanvas()
        currentTask?.cancel()
        
        lastMovementsNumberLabel.text = ""
        movementsLabel.text = ""
    }
    
    // MARK: - Accesible Methods
    func setCellInfo(_ info: Any?) {
        guard let viewModel = info as? PGCardCellViewModel else { return }
        self.cardType = viewModel.cardType
        productTypeLabel.configureText(withKey: "pgProduct_title_card",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 14.0)))
        cardAliasLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.title ?? "", styles: nil),
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0),
                                                                                          lineHeightMultiple: 0.75))
        securedCardPan.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.subtitle ?? "", styles: nil),
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        availableMoneyTitleLabel.text = viewModel.balanceTitle
        if let cardEntity = viewModel.elem as? CardEntity {
            if cardEntity.cardType == .debit {
                availableMoneyDescriptionLabel.isHidden = true
            } else {
                availableMoneyDescriptionLabel?.attributedText = viewModel.ammount
                availableMoneyDescriptionLabel?.isBlured = viewModel.discreteMode ?? false
            }
        }
        
        currentTask = cardImage?.loadImage(
            urlString: viewModel.imgURL,
            placeholder: viewModel.customFallbackImage ?? Assets.image(named: "defaultCard")
        )
        card = viewModel.elem
        setDisableCard(viewModel.disabled)
        setActivateCard(viewModel.toActivate)
        if let number = viewModel.notification, number != 0 {
            lastMovementsStackViewHeightConstraint.constant = 21
            lastMovementsNumberLabel.text = "\(number)"
            movementsLabel.configureText(withLocalizedString: localized((number == 1) ? "pgBasket_label_transaction_one" : "pgBasket_label_transaction_other"))
        } else {
            lastMovementsStackViewHeightConstraint.constant = 0
        }
        self.setAccessibilityIdentifiers()
        self.cardImage.isAccessibilityElement = true
        self.setAccessibility {
            self.setAccessibilityLabel()
            self.disableAccessibilityElements()
        }
    }
    
    func setCellDelegate(_ delegate: CardProductTableViewCellDelegate?) { self.delegate = delegate }
}
    // MARK: - Private Methods
private extension SmartCardCollectionViewCell {
    
    func setAppearance() {
        self.contentViewCell.layer.cornerRadius = 5
        self.contentViewCell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    func setLabelStyle() {
        productTypeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        cardAliasLabel.textColor = UIColor.white
        cardAliasLabel.numberOfLines = 0
        securedCardPan.textColor = UIColor.white
        availableMoneyTitleLabel.textColor = UIColor.white
        availableMoneyTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        availableMoneyDescriptionLabel.textColor = UIColor.white
        availableMoneyDescriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        availableMoneyDescriptionLabel.adjustsFontSizeToFitWidth = true
        availableMoneyDescriptionLabel.textAlignment = .left
        availableMoneyDescriptionLabel.applyTextAlignmentToAttributedText = true
        
        lastMovementsNumberLabel.textColor = UIColor.white
        lastMovementsNumberLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        lastMovementsNumberLabel.textAlignment = .left
        movementsLabel.textColor = UIColor.white
        movementsLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        movementsLabel.textAlignment = .left
    }
    
    func setButtonStyle() {
        activatePrepaidButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 12.0)
        activatePrepaidButton.setTitle(localized("pg_button_activateCard"), for: .normal)
        activatePrepaidButton.setTitleColor(UIColor.white, for: .normal)
        activatePrepaidButton.layer.cornerRadius = (activatePrepaidButton?.bounds.height ?? 0.0) / 2.0
        activatePrepaidButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        activatePrepaidButton.isHidden = true
        activateButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        activateButton.setTitle(localized("pg_button_startUsing"), for: .normal)
        activateButton.setTitleColor(UIColor.santanderRed, for: .normal)
        activateButton.layer.cornerRadius = (activateButton?.bounds.height ?? 0.0) / 2.0
        activateButton.backgroundColor = UIColor.white
        activateButton.isHidden = true
        self.activateButton?.accessibilityIdentifier = AccessibilityGlobalPositionSmart.btnStartUsing.rawValue
        addLongPressGesture()
    }
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressButton))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.allowableMovement = 0.0
        activatePrepaidButton.addGestureRecognizer(longPressGesture)
        activateButton.addGestureRecognizer(longPressGesture)
    }
    
    func setDisableCard(_ status: Bool) {
        availableMoneyTitleLabel.isHidden = status
        availableMoneyDescriptionLabel.isHidden = status
        
        if !status {
            cardAliasLabel.textColor = UIColor.white.withAlphaComponent(1)
            securedCardPan.textColor = UIColor.white.withAlphaComponent(1)
            cardImage.alpha = 1
        } else {
            cardAliasLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            securedCardPan.textColor = UIColor.white.withAlphaComponent(0.5)
            cardImage.alpha = 0.5
        }
        self.setAccessibility(setViewAccessibility: self.updateAccessibilityValue)
    }
    
    func setActivateCard(_ status: Bool) {
        self.activateButton?.isHidden = !status
    }
    
    func activateButtonDidPressed() {
        delegate?.activateCard(card)
    }
    
    @objc func didPressButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            activatePrepaidButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else if gestureRecognizer.state == .ended {
            activatePrepaidButton.backgroundColor =  UIColor.black.withAlphaComponent(0.2)
            activateButtonDidPressed()
        }
    }
    
    func setAccessibilityLabel() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        self.accessibilityLabel = productTypeValue
        self.accessibilityTraits = .button
        self.updateAccessibilityValue()
        self.isAccessibilityElement = true
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductViewCard
        self.productTypeLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductTitleCard
        self.cardAliasLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductAliasCard
        self.securedCardPan.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductCardNumber
        self.movementsLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgSmartCardLabelTransaction
        self.lastMovementsNumberLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgSmartCardLabelTransactionValue
        self.availableMoneyTitleLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelOutstandingBalanceDots
        self.availableMoneyDescriptionLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelOutstandingBalanceDotsValue
        if let type = cardType {
            self.cardImage.accessibilityIdentifier = "pgSmart_\(type)_card_image"
        } else {
            self.cardImage.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductImgCard
        }
        
    }
    
    func updateAccessibilityValue() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        let cardAliasValue = self.cardAliasLabel.text ?? ""
        let securedCardPanValue = self.securedCardPan.text ?? ""
        let numberOfMovementsValue = (self.lastMovementsNumberLabel.text ?? "") + (self.movementsLabel.text ?? "")
        let availableMoneyTitleValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyTitleLabel.text ?? ""
        let availableMoneyDescriptionValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyDescriptionLabel.attributedText?.string ?? ""
        self.accessibilityValue = productTypeValue + "." +
            cardAliasValue + "." +
            securedCardPanValue  + ".\n" +
            numberOfMovementsValue + "." +
            availableMoneyTitleValue + "." +
            availableMoneyDescriptionValue
    }
    
    func disableAccessibilityElements() {
        self.productTypeLabel.isAccessibilityElement = false
        self.cardAliasLabel.isAccessibilityElement = false
        self.securedCardPan.isAccessibilityElement = false
        self.availableMoneyTitleLabel.isAccessibilityElement = false
        self.availableMoneyDescriptionLabel.isAccessibilityElement = false
        self.cardImage.isAccessibilityElement = false
    }
}

extension SmartCardCollectionViewCell: AccessibilityCapable { }
