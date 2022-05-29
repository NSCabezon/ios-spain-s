//
//  CardProductTableViewCell.swift
//
//  Created by alvola on 07/10/2019.
//  Modified by Jose Norberto Hidalgo on 29/10/2021
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

protocol CardProductTableViewCellDelegate: AnyObject {
    func activateCard(_ card: Any?)
    func turnOnCard(_ card: Any?)
}

protocol CardProductTableViewCellProtocol: AnyObject {
    func setCellDelegate(_ delegate: CardProductTableViewCellDelegate?)
}

final class CardProductTableViewCell: UITableViewCell, GeneralPGCellProtocol, CardProductTableViewCellProtocol, DiscretePGCellProtocol {
    
    @IBOutlet weak var arrowActiveCardImageView: UIImageView!
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var cardName: UILabel?
    @IBOutlet weak var cardNum: UILabel?
    @IBOutlet weak var cardImg: UIImageView?
    @IBOutlet weak var disabledCourtine: UIView?
    @IBOutlet weak var cardDataStack: UIStackView?
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var cardValue: UILabel?
    @IBOutlet weak var cardValueDesc: UILabel?
    @IBOutlet weak var movementView: UIView?
    @IBOutlet weak var movementLabel: UILabel?
    @IBOutlet weak var availableView: UIView?
    @IBOutlet weak var availableBalanceDesc: UILabel?
    @IBOutlet weak var availableBalanceValue: UILabel?
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var activateButton: UILabel?
    @IBOutlet weak var activateButtonPrepaid: UILabel?
    @IBOutlet weak var movementValueBottomConstraint: NSLayoutConstraint!
    weak var delegate: CardProductTableViewCellDelegate?
    private var currentTask: CancelableTask?
    private var card: Any?
    private var cardType: CardType?
    private var discreteMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
        cardImg?.image = nil
        card = nil
        currentTask?.cancel()
        discreteMode = false
        cardValue?.removeBlur()
        availableBalanceValue?.removeBlur()
        onlySideFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if discreteMode {
            if !(cardValue?.text?.isEmpty ?? true) {
                cardValue?.blur(5.0)
            } else {
                cardValue?.removeBlur()
            }
            if !(availableBalanceValue?.text?.isEmpty ?? true) {
                availableBalanceValue?.blur(5.0)
            } else {
                availableBalanceValue?.removeBlur()
            }
        }
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGCardCellViewModel else { return }
        cardType = info.cardType
        cardName?.configureText(withLocalizedString: LocalizedStylableText(text: info.title ?? "", styles: nil),
                                andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .bold, size: 16),
                                                                                     lineHeightMultiple: 0.75))
        var cardTypeText = "pg_label_creditCard"
        switch cardType {
        case .credit:
            cardTypeText = "pg_label_creditCard"
        case .debit:
            cardTypeText = "pg_label_debitCard"
        case .prepaid:
            cardTypeText = "pg_label_ecashCard"
        default:
            cardTypeText = "pg_label_creditCard"
        }
        cardNum?.text = localized(cardTypeText, [StringPlaceholder(.value, info.subtitle ?? "")]).text
        currentTask = cardImg?.loadImage(
            urlString: info.imgURL,
            placeholder: info.customFallbackImage ?? Assets.image(named: "defaultCard")
        )
        cardValue?.attributedText = info.ammount
        cardValueDesc?.text = info.balanceTitle
        balanceView?.isHidden = (info.ammount?.length ?? 0) == 0
        availableBalanceDesc?.text = localized("pg_label_available")
        availableBalanceValue?.attributedText = info.availableBalance
        card = info.elem
        availableView?.isHidden = !(info.cardType == CardType.credit && info.availableBalance != nil)
        configureCellWith(info)
    }
    
    func setCellDelegate(_ delegate: CardProductTableViewCellDelegate?) { self.delegate = delegate }
    
    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
        self.setDiscreteMode()
    }
}

private extension CardProductTableViewCell {
    func commonInit() {
        self.configureView()
        self.configureLabels()
        self.configureImage()
        self.configureActivateLabel()
        self.setAccessibility()
    }
    
    func configureView() {
        selectionStyle = .none
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.7
        layer.shadowColor = UIColor.mediumSkyGray.cgColor

        movementView?.layer.cornerRadius = 8.0
        movementView?.backgroundColor = UIColor.oneTurquoise.withAlphaComponent(0.07)
        
        statusContainer.layer.masksToBounds = true
        statusContainer.layer.cornerRadius = 4
    }
    
    func configureActivateLabel() {
        self.activateButton?.textColor = UIColor.oneDarkTurquoise
        self.activateButton?.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.activateButton?.isUserInteractionEnabled = true
        self.activateButton?.accessibilityIdentifier = AccessibilityGlobalPosition.btnStartUsing

        self.arrowActiveCardImageView?.image = Assets.image(named: "icnGoPG")
        self.arrowActiveCardImageView?.isHidden = true

        self.activateButtonPrepaid?.layer.cornerRadius = (activateButtonPrepaid?.bounds.height ?? 0.0) / 2.0
        self.activateButtonPrepaid?.layer.borderWidth = 1.0
        self.activateButtonPrepaid?.textColor = UIColor.santanderRed
        self.activateButtonPrepaid?.layer.borderColor = self.activateButtonPrepaid?.textColor.cgColor
        self.activateButtonPrepaid?.text = localized("pg_button_activateCard")
        self.activateButtonPrepaid?.font = UIFont.santander(family: .text, type: .regular, size: 13.0)
        self.activateButtonPrepaid?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateButtonDidPressed)))
        self.activateButtonPrepaid?.isUserInteractionEnabled = true
        
        self.statusView?.isHidden = true
        self.activateButton?.isHidden = true
        self.arrowActiveCardImageView.isHidden = true
        self.activateButtonPrepaid?.isHidden = true
        self.disabledCourtine?.isHidden = true
    }
        
    func configureLabels() {
        configure(cardName, .oneLisboaGray, .oneB100Bold)
        configure(cardNum, .oneLisboaGray, .oneB400Regular)
        configure(cardValue, .oneLisboaGray, .oneH300Regular)
        configure(cardValueDesc, .oneBrownishGray, .oneB300Regular)
        configure(availableBalanceValue, .oneLisboaGray, .oneB300Regular)
        configure(availableBalanceDesc, .oneBrownishGray, .oneB300Regular)
        configure(movementLabel, .oneLisboaGray, .oneB300Regular)
        configure(statusLabel, .oneWhite, .oneB100Bold)
    }
    
    func configureImage() {
        cardImg?.contentMode = .scaleAspectFill
        cardImg?.layer.cornerRadius = 4.0
        cardImg?.backgroundColor = UIColor.lightGray
        cardImg?.isAccessibilityElement = true
    }
    
    func configure(_ label: UILabel?, _ color: UIColor, _ fontName: FontName) {
        label?.text = ""
        label?.textColor = color
        label?.font = UIFont.typography(fontName: fontName)
    }
    
    func configureCellWith(_ info: Any?) {
        guard let info = info as? PGGeneralCellViewModelProtocol else { return }
        if let movCount = info.notification, movCount > 0 {
            movementView?.isHidden = false
            let placeholder = [StringPlaceholder(.number, String(movCount))]
            let string = localized(movCount == 1 ? "pg_label_basketMovements_one" : "pg_label_basketMovements_other", placeholder)
            movementLabel?.configureText(withLocalizedString: string, andConfiguration: nil)
        } else {
            movementView?.isHidden = true
        }
        configureStatus(for: info)
        let extraDataHidden = balanceView?.isHidden ?? false && movementView?.isHidden ?? false && availableView?.isHidden ?? false && statusView?.isHidden ?? false
        cardDataStack?.isHidden = extraDataHidden
        movementValueBottomConstraint.constant = extraDataHidden ? 0.0 : 16.0
    }
    
    func configureStatus(for cardInfo: Any?) {
        guard let cardInfo = cardInfo as? PGCardCellViewModel,
              let cardEntity = self.card as? CardEntity
        else {
            statusView?.isHidden = true
            return
        }
        disabledCourtine?.isHidden = !cardInfo.disabled && !cardInfo.toActivate
        statusView.isHidden = true
        activateButton?.isHidden = true
        arrowActiveCardImageView.isHidden = true
        if cardInfo.toActivate {
            statusContainer.backgroundColor = .oneBrownishGray
            statusLabel.text = localized("pg_label_inactive").uppercased()
            activateButton?.isHidden = false
            activateButton?.text = localized("pg_button_startUsing")
            activateButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateButtonDidPressed)))
            arrowActiveCardImageView.isHidden = false
            statusView.isHidden = false
            return
        }
        disabledCourtine?.isHidden = cardEntity.isContractActive
        if cardEntity.isContractInactive {
            statusContainer.backgroundColor = .oneBrownishGray
            statusLabel.text = localized("pg_label_inactive").uppercased()
            statusView.isHidden = false
            return
        }
        if cardEntity.isContractCancelled {
            statusContainer.backgroundColor = .oneDarkTurquoise
            statusLabel.text = localized("pg_label_blocked").uppercased()
            statusView.isHidden = false
        }
        if cardEntity.isContractBlocked || cardInfo.disabled {
            statusContainer.backgroundColor = .oneDarkTurquoise
            statusLabel.text = localized("pg_label_FrozenCard").uppercased()
            activateButton?.isHidden = false
            activateButton?.text = localized("pg_button_unfrozen")
            activateButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(turnOnButtonDidPressed)))
            arrowActiveCardImageView.isHidden = false
            statusView.isHidden = false
            return
        }
        if cardEntity.isContractIssued {
            statusContainer.backgroundColor = .oneDarkTurquoise
            statusLabel.text = localized("pg_label_newIssue").uppercased()
            statusView.isHidden = false
            return
        }
        if cardEntity.isContractReplacement {
            statusContainer.backgroundColor = .oneDarkTurquoise
            statusLabel.text = localized("pg_label_replacementIssue").uppercased()
            statusView.isHidden = false
            return
        }
    }
    
    @objc private func activateButtonDidPressed() { delegate?.activateCard(card) }
    @objc private func turnOnButtonDidPressed() { delegate?.turnOnCard(card) }
}

// MARK: - Accesibility -
private extension CardProductTableViewCell {
    func setDiscreteMode() {
        let cardName = self.cardName?.text ?? ""
        let cardNum = self.cardNum?.text?.replacingOccurrences(of: "|", with: " ") ?? ""
        let cardValueDesc = self.discreteMode ? "" : self.cardValueDesc?.text ?? ""
        let cardValue = self.discreteMode ? "" : self.cardValue?.text ?? ""
        let movementsLabel = self.movementLabel?.isHidden ?? true ? "" : self.movementLabel?.text ?? ""
        self.accessibilityValue = "\(cardName) \n \(cardNum) \n \(movementsLabel) \n \(cardValueDesc) \n \(cardValue)"
    }

    func setAccessibility() {
        self.cardImg?.accessibilityIdentifier = AccessibilityIds.cardImg
        self.cardName?.accessibilityIdentifier = AccessibilityIds.cardName
        self.cardValueDesc?.accessibilityIdentifier = AccessibilityIds.cardValueDesc
        self.cardValue?.accessibilityIdentifier = AccessibilityIds.cardValue
        self.movementLabel?.accessibilityIdentifier = AccessibilityIds.movementLabel
        self.availableBalanceDesc?.accessibilityIdentifier = AccessibilityIds.availableBalanceDesc
        self.availableBalanceValue?.accessibilityIdentifier = AccessibilityIds.availableBalanceValue
        self.activateButton?.accessibilityIdentifier = AccessibilityIds.activateButton
        self.activateButtonPrepaid?.accessibilityIdentifier = AccessibilityIds.activateButtonPrepaid
        switch cardType {
        case .credit:
            self.cardNum?.accessibilityIdentifier = AccessibilityIds.cardNumCredit
        case .debit:
            self.cardNum?.accessibilityIdentifier = AccessibilityIds.cardNumDebit
        case .prepaid:
            self.cardNum?.accessibilityIdentifier = AccessibilityIds.cardNumPrepaid
        default:
            self.cardNum?.accessibilityIdentifier = AccessibilityIds.cardNumDefault
        }
    }
        
    enum AccessibilityIds {
        public static let cardImg = "imgCard"
        public static let cardName = "cardLabelAlias"
        public static let cardNumCredit = "pg_label_creditCard"
        public static let cardNumDebit = "pg_label_debitCard"
        public static let cardNumPrepaid = "pg_label_prepaidCard"
        public static let cardNumDefault = "pg_label_defaultCard"
        public static let cardValueDesc = "pg_label_outstandingBalanceDots"
        public static let cardValue = "cardLabelCurrentBalance"
        public static let movementLabel = "pgBasket_label_transaction"
        public static let availableBalanceDesc = "shareIconDetail"
        public static let availableBalanceValue = "cardLabelAvailableBalance"
        public static let activateButton = "cardBtnActivate"
        public static let activateButtonPrepaid = "cardBtnActivatePrepaid"
    }
}

// MARK: - RoundedCellProtocol -
extension CardProductTableViewCell: RoundedCellProtocol {
    func roundCorners() { frameView?.roundAllCorners() }
    func roundTopCorners() { frameView?.roundTopCorners() }
    func roundBottomCorners() { frameView?.roundBottomCorners() }
    func removeCorners() { frameView?.removeCorners() }
    func onlySideFrame() { frameView?.onlySideFrame() }
}

extension CardProductTableViewCell: AccessibilityCapable { }
