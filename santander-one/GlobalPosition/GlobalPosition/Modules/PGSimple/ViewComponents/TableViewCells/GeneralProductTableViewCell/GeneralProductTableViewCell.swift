//
//  GeneralProductTableViewCell.swift
//  toTest
//
//  Created by alvola on 07/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

final class GeneralProductTableViewCell: UITableViewCell, GeneralPGCellProtocol, RoundedCellProtocol, DiscretePGCellProtocol {
    @IBOutlet private weak var frameView: RoundedView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bottomSeparationView: UIView?
    @IBOutlet private weak var piggyBankImage: UIImageView?
    @IBOutlet private weak var santanderLogoImage: UIImageView?
    @IBOutlet private weak var titleTrailingPiggy: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingValue: NSLayoutConstraint!
    @IBOutlet private weak var bottomSubtitle: NSLayoutConstraint!
    @IBOutlet private weak var bottomStackView: NSLayoutConstraint!
    @IBOutlet private weak var rowsStackView: UIStackView?
    @IBOutlet private weak var piggyBankImageWidthConstraint: NSLayoutConstraint!

    private var discreteMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
        bottomSeparationView?.isHidden = true
        discreteMode = false
        onlySideFrame()
        piggyBankImage?.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rowsStackView?.arrangedSubviews.forEach { ($0 as? GeneralProductCellRowProtocol)?.setDiscreteMode(discreteMode) }
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGGeneralCellViewModelProtocol else { return }
        if let accountEntity = info.elem as? AccountEntity {
            showsPiggyBankImage(accountEntity)
        }
        var rows: [PGStatedCellViewModelRow] = []
        if let info = info as? PGStatedCellViewModel, let infoRows = info.rows {
            rows.append(contentsOf: infoRows)
        }
        if let number = info.notification, number > 0 {
            rows.append(.movements(number: number))
        }
        set(title: info.title, subtitle: info.subtitle, rows: rows)
    }
    
    func roundTopCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        layer.shadowRadius = 7
        frameView?.roundTopCorners()
        bottomSeparationView?.isHidden = false
    }
    
    func roundBottomCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowRadius = 7
        frameView?.roundBottomCorners()
        bottomSeparationView?.isHidden = true
    }
    
    func roundCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowRadius = 7
        frameView?.roundAllCorners()
        bottomSeparationView?.isHidden = true
    }
    
    func removeCorners() {
        frameView?.removeCorners()
    }
    
    func onlySideFrame() {
        frameView?.onlySideFrame()
    }
    
    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    func configureView() {
        selectionStyle = .none
        clipsToBounds = false
        setConfigureView()
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.15
        layer.shadowColor = UIColor.oneLisboaGray.cgColor
    }
}

private extension GeneralProductTableViewCell {
    func setConfigureView() {
        santanderLogoImage?.image = Assets.image(named: "icnSanSmall")
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.oneLisboaGray.cgColor
        frameView?.removeBorder()
        bottomSeparationView?.backgroundColor = UIColor.lightSanGray.withAlphaComponent(0.9)
    }
    
    func commonInit() {
        configureLabels()
        configureView()
        setAccessibility(setViewAccessibility: setAccessibility)
    }
    
    func configureLabels() {
        configure(label: titleLabel, fontName: .oneH100Bold, color: .oneLisboaGray)
        titleLabel?.numberOfLines = 2
        configure(label: subtitleLabel, fontName: .oneB400Regular, color: .oneLisboaGray)
    }
    
    func configure(label: UILabel?, fontName: FontName, color: UIColor) {
        label?.text = ""
        label?.textColor = color
        label?.font = UIFont.typography(fontName: fontName)
    }
    
    func showsPiggyBankImage(_ accountEntity: AccountEntity) {
        guard self.piggyBankImageWidthConstraint != nil else { return }
        
        let isPiggyBank = accountEntity.isPiggyBankAccount
        self.piggyBankImage?.image = isPiggyBank ? Assets.image(named: "imgPgPiggyBank") : nil
        self.piggyBankImage?.isHidden = !isPiggyBank
        self.titleTrailingPiggy.priority = isPiggyBank ? .defaultHigh : .defaultLow
        self.titleTrailingValue.priority = isPiggyBank ? .defaultLow : .init(998)
        
        if isPiggyBank {
            NSLayoutConstraint.activate([self.piggyBankImageWidthConstraint])
        } else {
            NSLayoutConstraint.deactivate([self.piggyBankImageWidthConstraint])
        }
    }
    
    func set(title: String?, subtitle: String?, rows: [PGStatedCellViewModelRow]?) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        rowsStackView?.removeAllArrangedSubviews()
        bottomSubtitle.priority = rows?.isEmpty == false ? .defaultLow : .defaultHigh
        bottomStackView.priority = rows?.isEmpty == false ? .defaultHigh : .defaultLow
        guard let rows = rows else { return }
        for row in rows {
            switch row {
            case let .movements(number):
                let view = MovementsRow()
                view.setInfo(number: number,
                             numberAccessibilityId: AccessibilityGlobalPosition.generalProductSimpleCellMovementsRowLabel)
                rowsStackView?.addArrangedSubview(view)
            case let .titleAmount(titleKey, amount):
                let view = TitleAmountRow()
                view.setInfo(title: localized(titleKey),
                             amount: amount,
                             titleAccessibilityId: titleKey,
                             amountAccessibilityId: AccessibilityGlobalPosition.generalProductSimpleCellTitleAmountRowAmountLabel)
                rowsStackView?.addArrangedSubview(view)
            }
        }
    }
    
    func setAccessibility() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.generalProductSimpleCellTitleLabel
        self.subtitleLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.generalProductSimpleCellSubtitleLabel
        self.piggyBankImage?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
        self.santanderLogoImage?.accessibilityIdentifier = AccessibilityGlobalPosition.icnSanSmall
        let titleLabel = self.titleLabel?.text ?? ""
        let subtitleLabel = self.subtitleLabel?.text ?? ""
        self.accessibilityValue = "\(titleLabel) \n \(subtitleLabel)"
    }
}

extension GeneralProductTableViewCell: AccessibilityCapable { }
