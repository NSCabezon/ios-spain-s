//
//  ClassicCardProductTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 29/10/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class ClassicCardProductTableViewCell: BaseMovementCountCell, GeneralPGCellProtocol, CardProductTableViewCellProtocol, RoundedCellProtocol, SeparatorCellProtocol, DiscretePGCellProtocol {
    @IBOutlet weak var activatePrepaidButton: UILabel?
    @IBOutlet weak var arrowActivateImageView: UIImageView!
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var cardName: UILabel?
    @IBOutlet weak var cardNum: UILabel?
    @IBOutlet weak var cardImg: UIImageView?
    @IBOutlet weak var cardValue: UILabel?
    @IBOutlet weak var cardValueDesc: UILabel?
    @IBOutlet weak var disabledCourtine: UIView?
    @IBOutlet weak var activateButton: UILabel?
    @IBOutlet weak var separationView: DottedLineView?
    weak var delegate: CardProductTableViewCellDelegate?
    private var currentTask: CancelableTask?
    private var card: Any?
    private var discreteMode: Bool = false
    private var cardType: CardType?

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
        activateMode(false)
        cardImg?.image = nil
        card = nil
        currentTask?.cancel()
        separationView?.isHidden = false
        notificationLabel?.isHidden = true
        discreteMode = false
        cardValue?.removeBlur()
        onlySideFrame()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.discreteMode {
            guard !(cardValue?.text?.isEmpty ?? true) else { cardValue?.removeBlur(); return }
            cardValue?.blur(5.0)
        }
    }

    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGCardCellViewModel else { return }
        self.cardType = info.cardType
        setCardNameText(info)
        setCardNumText(info)
        setCurrentTask(info)
        cardValue?.attributedText = info.ammount
        cardValueDesc?.text = info.balanceTitle
        card = info.elem
        disabledCourtine?.isHidden = !info.disabled && !info.toActivate
        super.configureCellWith(info)
        activateMode(info.toActivate)
        hiddesCardValuesIfNeeded(info)
        cardImg?.isAccessibilityElement = true
    }

    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
        self.setAccessibility(setViewAccessibility: self.setAccessibility) 
    }
    func setCellDelegate(_ delegate: CardProductTableViewCellDelegate?) { self.delegate = delegate }
    func roundCorners() { frameView?.roundAllCorners() }
    func roundTopCorners() { frameView?.roundTopCorners() }
    func roundBottomCorners() { frameView?.roundBottomCorners() }
    func removeCorners() { frameView?.removeCorners() }
    func onlySideFrame() { frameView?.onlySideFrame() }
    func hideSeparator(_ hide: Bool) { separationView?.isHidden = hide }
}

private extension ClassicCardProductTableViewCell {
    func commonInit() {
        configureView()
        configureLabels()
        configureImage()
        configureActivateLabel()
        configureNotificationDot()
    }

    func activateMode(_ activate: Bool) {
        self.cardValueDesc?.isHidden = activate
        self.cardValue?.isHidden = activate
        self.activateButton?.isHidden = !activate
        self.arrowActivateImageView?.isHidden = !activate
    }

    func configureView() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.skyGray
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        onlySideFrame()
        separationView?.strokeColor = UIColor.mediumSkyGray
    }

    func configureNotificationDot() {
        notificationLabel?.isHidden = true
    }

    func configureActivateLabel() {
        self.activateButton?.textColor = UIColor.darkTorquoise
        self.activateButton?.text = localized("pg_button_startUsing")
        self.activateButton?.isHidden = true
        self.activateButton?.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.activateButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateButtonDidPressed)))
        self.activateButton?.isUserInteractionEnabled = true
        self.activateButton?.accessibilityIdentifier = AccessibilityGlobalPosition.btnStartUsing
        self.disabledCourtine?.isHidden = true
        self.arrowActivateImageView?.image = Assets.image(named: "icnGoPG")
        self.arrowActivateImageView?.isHidden = true
        self.arrowActivateImageView.accessibilityIdentifier = AccessibilityGlobalPosition.btnStartUsingArrow
        self.activatePrepaidButton?.layer.cornerRadius = (activateButton?.bounds.height ?? 0.0) / 2.0
        self.activatePrepaidButton?.layer.borderWidth = 1.0
        self.activatePrepaidButton?.textColor = UIColor.santanderRed
        self.activatePrepaidButton?.layer.borderColor = activatePrepaidButton?.textColor.cgColor
        self.activatePrepaidButton?.text = localized("pg_button_activateCard")
        self.activatePrepaidButton?.isHidden = true
        self.activatePrepaidButton?.font = UIFont.santander(family: .text, type: .regular, size: 13.0)
        self.activatePrepaidButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateButtonDidPressed)))
        self.activatePrepaidButton?.isUserInteractionEnabled = true
    }

    func configureLabels() {
        configure(cardValue, 22.0, .regular)
        configure(cardValueDesc, 14.0, .regular)
        cardValueDesc?.textColor = UIColor.grafite
    }

    func configureImage() {
        cardImg?.contentMode = .scaleAspectFill
        cardImg?.layer.cornerRadius = 5.0
        cardImg?.backgroundColor = UIColor.clear
        cardImg?.isAccessibilityElement = true
    }

    func configure(_ label: UILabel?, _ size: CGFloat, _ weight: FontType) {
        label?.text = ""
        label?.textColor = UIColor.lisboaGray
        label?.font = UIFont.santander(family: .text, type: weight, size: size)
    }
    
    func setAccessibility() {
        let cardName = self.cardName?.text ?? ""
        let cardNum = self.cardNum?.text?.replacingOccurrences(of: "|", with: "") ?? ""
        let cardValueDesc = self.discreteMode ? "" : self.cardValueDesc?.text ?? ""
        let cardValue = self.discreteMode ? "" : self.cardValue?.text ?? ""
        let notificationLabel = self.notificationLabel?.isHidden ?? true ? "" : self.notificationLabel?.text ?? ""
        let movementsLabel = self.movementLabel?.isHidden ?? true ? "" : self.movementLabel?.text ?? ""
        self.accessibilityValue = "\(cardName) \n \(cardNum) \n \(notificationLabel) \(movementsLabel) \n \(cardValueDesc) \n \(cardValue)"
        self.cardImg?.isAccessibilityElement = false
    }
    
    @objc func activateButtonDidPressed() {
        delegate?.activateCard(card)
    }

    func setCardNameText(_ info: PGCardCellViewModel) {
        let labelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 18),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        cardName?.configureText(
            withKey: info.title ?? "",
            andConfiguration: labelConfig
        )
        cardName?.textColor = .lisboaGray
    }
    
    func setCardNumText(_ info: PGCardCellViewModel) {
        cardNum?.isHidden = info.subtitle == nil
        cardNum?.textColor = .lisboaGray
        let labelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 14),
            alignment: .left,
            lineBreakMode: .none
        )
        if let subtitle = info.subtitle {
            cardNum?.configureText(
                withKey: subtitle,
                andConfiguration: labelConfig
            )
        }
    }
    
    func setCurrentTask(_ info: PGCardCellViewModel) {
        let task = cardImg?.loadImage(
            urlString: info.imgURL,
            placeholder: Assets.image(named: "defaultCard")
        )
        currentTask = task
    }
    
    func hiddesCardValuesIfNeeded(_ info: PGCardCellViewModel) {
        if !info.toActivate {
            cardValueDesc?.isHidden = (info.ammount?.length ?? 0) == 0
            cardValue?.isHidden = (info.ammount?.length ?? 0) == 0
        }
    }
}

extension ClassicCardProductTableViewCell: AccessibilityCapable { }
