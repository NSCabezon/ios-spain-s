//
//  TransferPackageView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 8/6/21.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib

final class TransferPackageView: XibView {

    @IBOutlet weak private var tooltipSubtitleLabel: UILabel!
    @IBOutlet weak private var tooltipTitleLabel: UILabel!
    @IBOutlet weak private var tooltipsView: UIView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var packageLabel: UILabel!
    @IBOutlet weak private var packageNumberLabel: UILabel!
    @IBOutlet weak private var tooltipDownView: UIView!
    @IBOutlet weak var tooltipUpView: UIView!

    private(set) var viewModel: TransferPackageViewModel

    init(frame: CGRect, viewModel: TransferPackageViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.setup(viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setup(_ viewModel: TransferPackageViewModel) {
        for view in self.contentView.subviews where view is UILabel {
            if let label = view as? UILabel {
                label.text = nil
            }
        }
        self.contentView.backgroundColor = .bg
        self.contentView.layer.cornerRadius = 5.0
        self.titleLabel.text = viewModel.packageName
        self.titleLabel.accessibilityIdentifier = AccessibilityTransferSubTypes.totalTitle.rawValue + "_\(viewModel.packageName)"
        self.packageLabel.text = localized("sendMoney_label_remainingTransfers")
        self.packageNumberLabel.text = "\(String(viewModel.remainingTransfers))/\(String(viewModel.numberTransfers))"
        self.tooltipTitleLabel.text = localized("sendMoney_text_infoPaymentPacks")
        self.tooltipSubtitleLabel.text = localized("sendMoney_text_infoPaymentsCosts")
        self.titleLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.subtitleLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.subtitleLabel.configureText(withLocalizedString: localized("sendMoney_label_validDate",
                                                                        [StringPlaceholder(.date, viewModel.expirationDate)]))
        self.packageLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.packageNumberLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.tooltipTitleLabel.setSantanderTextFont(type: .regular, size: 12, color: .lisboaGray)
        self.tooltipSubtitleLabel.setSantanderTextFont(type: .regular, size: 12, color: .lisboaGray)
        self.setAccessibilityIds()
        setAccessibility()
        self.setupAccessibilityElements()
    }

    func setAccessibilityIds() {
        self.packageLabel.accessibilityIdentifier = AccessibilityTransferSubTypes.remaining.rawValue
        self.packageNumberLabel.accessibilityIdentifier = AccessibilityTransferSubTypes.remainingNumber.rawValue
        self.subtitleLabel.accessibilityIdentifier = AccessibilityTransferSubTypes.validDate.rawValue
        self.tooltipTitleLabel.accessibilityIdentifier = AccessibilityTransferSubTypes.infoPaymentPacks.rawValue
    }

    public func setTooltipWarning(typeValue: TransferSubType) {
        switch self.viewModel.transferTime {
        case .now:
            self.tooltipUpView.isHidden = true
        case .day, .periodic:
            if typeValue == .instant {
                self.tooltipUpView.isHidden = false
            } else {
                self.tooltipUpView.isHidden = true
            }
        }
    }
}

private extension TransferPackageView {
    func setAccessibility() {
        let tooltipText = "\(tooltipUpView.isHidden ? "" : (tooltipTitleLabel.text ?? "")). \(tooltipSubtitleLabel.text ?? "")"
        titleLabel.accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \(packageLabel.text ?? "") \(packageNumberLabel.text ?? "").\n\n\(tooltipText)"
        subtitleLabel.accessibilityElementsHidden = true
        packageLabel.accessibilityElementsHidden = true
        packageNumberLabel.accessibilityElementsHidden = true
        tooltipTitleLabel.accessibilityElementsHidden = true
        tooltipSubtitleLabel.accessibilityElementsHidden = true
    }
    
    func setupAccessibilityElements() {
        self.contentView.subviews.setAccessibilityHidden(true)
        self.accessibilityElementsHidden = false
        self.isAccessibilityElement = true
        self.accessibilityLabel = self.titleLabel.appendSpeechFromElements([subtitleLabel,
                                                                            packageLabel,
                                                                            packageNumberLabel,
                                                                            tooltipSubtitleLabel])
    }
}
