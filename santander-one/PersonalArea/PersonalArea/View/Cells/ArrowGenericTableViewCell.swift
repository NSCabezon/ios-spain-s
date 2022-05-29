//
//  ArrowGenericTableViewCell.swift
//  Alamofire
//
//  Created by David Gálvez Alonso on 21/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class ArrowGenericTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var tooltipBackgroundView: UIView!
    @IBOutlet private weak var selectedLabel: UILabel!
    @IBOutlet private weak var separationView: DottedLineView!
    @IBOutlet private weak var arrowImageView: UIImageView!

    private var infoText: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetView()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? GenericCellModel else { return }
        self.titleLabel.configureText(withKey: info.titleKey)
        self.selectedLabel.text = info.valueInfo?.0 as? String
        self.selectedLabel.isHidden = self.selectedLabel.text?.isEmpty ?? true
        if let tooltipText = info.tooltipInfo?.message {
            self.setInfoText(tooltipText)
        }
        arrowImageView?.isHidden = !info.showDisclosureIndicator
        accessibilityIdentifier = info.accessibilityIdentifier
        self.selectedLabel?.accessibilityIdentifier = AccessibilitySecuritySectionPersonalArea.securitySectionLabelSelectedUser
        self.selectedLabel?.isAccessibilityElement = false
        self.arrowImageView?.accessibilityIdentifier = "\(self.titleLabel?.accessibilityIdentifier ?? "")_icnArrowRight"
        self.arrowImageView.isHidden = !info.showDisclosureIndicator
        self.setAccessibilityIdentifiers(info)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 55.0)
    }
}

private extension ArrowGenericTableViewCell {
    func commonInit() {
        self.resetView()
        self.configureViews()
        self.configureLabels()
        self.configureTooltip()
    }

    func configureViews() {
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.separationView.backgroundColor = UIColor.clear
        self.separationView.strokeColor = UIColor.mediumSkyGray
        self.arrowImageView.image = Assets.image(named: "icnArrowRight")
        self.arrowImageView.accessibilityIdentifier = AccessibilitySecuritySectionPersonalArea.icnArrowRight
    }

    func configureLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.selectedLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.selectedLabel.textColor = UIColor.darkTorquoise
    }

    func configureTooltip() {
        self.tooltipImageView.image = Assets.image(named: "icnSmallInfo")
        self.tooltipImageView.contentMode = .scaleAspectFill
        self.tooltipBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooltipDidPressed)))
        self.tooltipBackgroundView.isUserInteractionEnabled = true
        self.tooltipImageView.accessibilityIdentifier = AccessibilitySecuritySectionPersonalArea.securitySectionBtnTooltip
    }

    func setInfoText(_ text: String) {
        self.infoText = text
        self.tooltipImageView.isHidden = false
        self.tooltipBackgroundView.isHidden = false
    }

    @objc func tooltipDidPressed() {
        guard let associated = self.tooltipBackgroundView else { return }
        BubbleLabelView.startWith(associated: associated, text: self.infoText, position: .automatic)
    }

    func resetView() {
        self.titleLabel.text = ""
        self.selectedLabel.text = ""
        self.tooltipImageView.isHidden = true
        self.tooltipBackgroundView.isHidden = true
    }
    
    func setAccessibilityIdentifiers(_ info: GenericCellModel) {
        self.accessibilityIdentifier = info.accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = info.titleKey
        self.selectedLabel.accessibilityIdentifier = info.valueInfo?.1
        self.tooltipImageView.accessibilityIdentifier = info.tooltipInfo?.accessibilityIdentifier
    }
}
