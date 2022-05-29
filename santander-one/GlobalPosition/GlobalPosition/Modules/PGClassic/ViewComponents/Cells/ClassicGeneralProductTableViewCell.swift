//
//  ClassicGeneralProductTableViewCell.swift
//  Alamofire
//
//  Created by alvola on 29/10/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class ClassicGeneralProductTableViewCell: BaseMovementCountCell, GeneralPGCellProtocol, RoundedCellProtocol, SeparatorCellProtocol, DiscretePGCellProtocol {
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var piggyBankImage: UIImageView?
    @IBOutlet weak var piggyBankWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var separationView: DottedLineView?
    private var discreteMode: Bool = false
    private var centerYConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
        separationView?.isHidden = false
        notificationLabel?.text = ""
        notificationLabel?.isHidden = true
        discreteMode = false
        valueLabel?.removeBlur()
        onlySideFrame()
        piggyBankImage?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if discreteMode {
            guard !(valueLabel?.text?.isEmpty ?? true) else { valueLabel?.removeBlur(); return }
            valueLabel?.blur(5.0)
        }
    }

    func setCellInfo(_ info: Any?) {
        super.configureCellWith(info)
        self.piggyBankWidthConstraint.constant = 0
        if let info = info as? PGGenericNotificationCellViewModel {
            if let accountEntity = info.elem as? AccountEntity {
                showsPiggyBankImage(accountEntity)
                titleLabel?.numberOfLines = 1
                titleLabel?.lineBreakMode = .byTruncatingTail
            }
            set(info.title, info.subtitle, info.ammount)
        } else if let info = info as? PGGeneralCellViewModelProtocol {
            titleLabel?.numberOfLines = 2
            titleLabel?.lineBreakMode = .byTruncatingTail
            set(info.title, info.subtitle, info.ammount)
        }
        self.setAccessibilityIdentifiers(info: info)
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    func showsPiggyBankImage(_ accountEntity: AccountEntity) {
        if accountEntity.isPiggyBankAccount {
            self.piggyBankImage?.image = Assets.image(named: "imgPgPiggyBank")
        }
        let isPiggyBank = accountEntity.isPiggyBankAccount
        self.piggyBankImage?.isHidden = !isPiggyBank
        self.piggyBankWidthConstraint.constant = isPiggyBank ? 52 : 0
    }

    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    func roundCorners() { frameView?.roundAllCorners() }
    func roundTopCorners() { frameView?.roundTopCorners(); separationView?.isHidden = false }
    func roundBottomCorners() {
        frameView?.roundBottomCorners()
        separationView?.isHidden = true
    }
    func onlySideFrame() { frameView?.onlySideFrame() }
    func removeCorners() { frameView?.removeCorners() }

    func hideSeparator(_ hide: Bool) { separationView?.isHidden = hide }
}

extension ClassicGeneralProductTableViewCell {
    private func set(_ title: String?, _ subtitle: String?, _ value: NSAttributedString?) {
        titleLabel?.configureText(withLocalizedString: LocalizedStylableText(text: title ?? "", styles: nil),
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18),
                                                                                       lineHeightMultiple: 0.75))
        valueLabel?.attributedText = value
        setupSubtitleLabel(with: subtitle)
    }

    private func commonInit() {
        configureView()
        configureLabels()
        configureNotificationDot()
    }

    internal func configureView() {
        selectionStyle = .none
        separationView?.strokeColor = UIColor.mediumSkyGray
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView.backgroundColor = UIColor.skyGray
        onlySideFrame()
        piggyBankImage?.isHidden = true
    }

    private func configureLabels() {
        configure(titleLabel, 18.0, .bold)
        configure(subtitleLabel, 14.0, .regular)
        configure(valueLabel, 22.0, .regular)
    }

    private func setupSubtitleLabel(with subtitle: String?) {
        subtitleLabel?.text = subtitle
        if let subtitle = subtitle, !subtitle.isEmpty {
            showSubtitleLabel()
        } else {
            hideSubtitleLabel()
        }
    }
    
    private func hideSubtitleLabel() {
        if centerYConstraint == nil {
            centerYConstraint = titleLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        }
        centerYConstraint?.isActive = true
        self.layoutIfNeeded()
    }
    
    private func showSubtitleLabel() {
        centerYConstraint?.isActive = false
        self.layoutIfNeeded()
    }

    private func configureNotificationDot() {
        notificationLabel?.isHidden = true
    }

    private func configure(_ label: UILabel?, _ size: CGFloat, _ weight: FontType, textColor: UIColor = UIColor.lisboaGray) {
        label?.text = ""
        label?.textColor = textColor
        label?.font = UIFont.santander(family: .text, type: weight, size: size)
    }
    
    private func setAccessibility() {
        self.piggyBankImage?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
        let titleLabel = self.replacePostalCodeWithCP(title: self.titleLabel?.text ?? "")
        let subtitleLabel = self.subtitleLabel?.text ?? ""
        let notificationLabel = self.notificationLabel?.isHidden ?? true ? "" : self.notificationLabel?.text ?? ""
        let movementsLabel = self.movementLabel?.isHidden ?? true ? "" : self.movementLabel?.text ?? ""
        let valueLabel = self.discreteMode ? "" : self.replaceLetteWithValue(amount: self.valueLabel?.text ?? "")
        self.accessibilityValue = "\(titleLabel) \n \(subtitleLabel) \n \(notificationLabel) \(movementsLabel) \n \(valueLabel)"
    }
    
    private func replacePostalCodeWithCP(title: String) -> String {
        let title = title.replacingOccurrences(of: " Cp", with: " C P")
        return title
    }
    
    private func replaceLetteWithValue(amount: String) -> String {
        var amountNew = amount.replacingOccurrences(of: "B", with: localized("voiceover_billions"))
        amountNew = amountNew.replacingOccurrences(of: "M", with: localized("voiceover_millons"))
        return amountNew
    }
    
    private func setAccessibilityIdentifiers(info: Any) {
        if let info = info as? PGGeneralCellViewModelProtocol ?? info as? PGGenericNotificationCellViewModel {
            if let elem = info.elem as? GlobalPositionProduct {
                self.accessibilityIdentifier = "pgClassic_\(elem.productId)"
                self.piggyBankImage?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
                self.titleLabel?.accessibilityIdentifier = "pgClassic_\(elem.productId)_title"
                self.subtitleLabel?.accessibilityIdentifier = "pgClassic_\(elem.productId)_subtitle"
                self.valueLabel?.accessibilityIdentifier = "pgClassic_\(elem.productId)_value"
                self.notificationLabel?.accessibilityIdentifier = "pgClassic_\(elem.productId)_movementsValue"
                self.movementLabel?.accessibilityIdentifier = "pgClassic_\(elem.productId)_movementsLabel"
            }
        }
    }
}

extension ClassicGeneralProductTableViewCell: AccessibilityCapable { }
