//
//  HistoricalEmittedTableViewCell.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 01/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class HistoricalTransferTableViewCell: UITableViewCell {
    @IBOutlet private weak var transferTypeImageView: UIImageView!
    @IBOutlet private weak var initialsLabel: UILabel!
    @IBOutlet private weak var bankIconImageView: UIImageView!
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var bankIconWidth: NSLayoutConstraint!
    @IBOutlet private weak var bankIconHeight: NSLayoutConstraint!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    @IBOutlet private weak var completeLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bankIconImageView.image = nil
    }
    
    func setup(withViewModel viewModel: TransferEmittedWithColorViewModel, section: Int, index: Int) {
        self.nameView.backgroundColor = viewModel.colorsByNameViewModel.color
        self.nameLabel.attributedText = NSAttributedString(string: viewModel.viewModel.beneficiary ?? "")
        self.nameLabel.set(lineHeightMultiple: 0.75)
        self.accountLabel.attributedText = NSAttributedString(string: viewModel.viewModel.account.getIBANShort)
        if let highlightedText = viewModel.highlightedText, !highlightedText.isEmpty {
            self.nameLabel.attributedText = self.nameLabel.attributedText?.highlight(highlightedText)
            self.accountLabel.attributedText = self.accountLabel.attributedText?.highlight(highlightedText)
        }
        self.amountLabel.attributedText = viewModel.viewModel.amount
        self.initialsLabel.text = viewModel.viewModel.avatarName
        if let iconUrl = viewModel.viewModel.bankIconUrl {
            self.bankIconImageView.loadImage(urlString: iconUrl) { [weak self] in
                self?.adjustBankIconWidth()
            }
        }
        if viewModel.viewModel.transferType == .emitted {
            self.setTransferTypeIcon(imageKey: "icnArrowSendRed")
            self.setAccessibilityIdentifiers(typeTransferIconIdentifier: "Red")
        } else {
            self.setTransferTypeIcon(imageKey: "icnArrowReceivedGreen")
            self.setAccessibilityIdentifiers(typeTransferIconIdentifier: "Green")
        }
        self.layoutIfNeeded()
    }
    
    func dottedHidden(isLast: Bool) {
        self.dottedLineView.isHidden = isLast
        self.completeLineView.isHidden = !isLast
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var size = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        if size.height < 74.0 {
            size.height = 74.0
        }
        return size
    }
}

private extension HistoricalTransferTableViewCell {
    func commonInit() {
        self.nameView.layer.cornerRadius = self.nameView.bounds.height / 2
        self.nameView.backgroundColor = .clear
        self.nameLabel.textColor = .lisboaGray
        self.nameLabel.font = .santander(type: .bold, size: 16.0)
        self.accountLabel.textColor = .lisboaGray
        self.accountLabel.font = .santander(size: 14.0)
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(type: .bold, size: 20.0)
        self.initialsLabel.textColor = .white
        self.initialsLabel.font = .santander(type: .bold, size: 15.0)
        self.dottedLineView.strokeColor = .mediumSkyGray
        self.completeLineView.backgroundColor = .mediumSkyGray
        self.completeLineView.isHidden = true
        self.selectionStyle = .none
    }
    
    func setTransferTypeIcon(imageKey: String) {
        self.transferTypeImageView.image = Assets.image(named: imageKey)
    }
    
    func adjustBankIconWidth() {
        guard let image = self.bankIconImageView.image else { return bankIconWidth.constant = 0.0 }
        let imageAspectRatio = image.size.width / image.size.height
        let scaledWidth = self.bankIconHeight.constant * imageAspectRatio
        self.bankIconWidth.constant = scaledWidth
    }
    
    func setAccessibilityIdentifiers(typeTransferIconIdentifier: String) {
        self.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCell
        self.transferTypeImageView.accessibilityIdentifier = "\(AccessibilityTransferHistorical.historicalTransferCellTypeIcn)\(typeTransferIconIdentifier)"
        self.initialsLabel.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferInitial
        self.bankIconImageView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellViewBankImage
        self.nameView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellViewInitialsCircle
        self.nameLabel.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellLabelDestinationUser
        self.accountLabel.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellLabelDestinationAccount
        self.amountLabel.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellLabelAmount
        self.dottedLineView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellViewDottedLine
        self.completeLineView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferCellViewSeparator
    }
}
