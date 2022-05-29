//
//  MonthTransfersTableViewCell.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import CoreFoundationLib
import UI

final class MonthTransfersTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var transferTypeImageView: UIImageView!
    @IBOutlet private weak var initialsLabel: UILabel!
    @IBOutlet private weak var bankIconImageView: UIImageView!
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var acount: UILabel!
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
    
    func setup(withViewModel viewModel: TransferEmittedWithColorViewModel) {
        self.nameView.backgroundColor = viewModel.colorsByNameViewModel.color
        self.name.attributedText = NSAttributedString(string: viewModel.transferEmitted.beneficiary ?? "")
        self.name.set(lineHeightMultiple: 0.75)
        self.acount.attributedText = NSAttributedString(string: viewModel.transferEmitted.iban)
        if let highlightedText = viewModel.highlightedText, !highlightedText.isEmpty {
            self.name.attributedText = self.name.attributedText?.highlight(highlightedText)
            self.acount.attributedText = self.acount.attributedText?.highlight(highlightedText)
        }
        
        self.amountLabel.attributedText = viewModel.transferEmitted.amount
        self.initialsLabel.text = viewModel.transferEmitted.avatarName
        
        if let iconUrl = viewModel.transferEmitted.bankIconUrl {
            bankIconImageView.loadImage(urlString: iconUrl) { [weak self] in
                self?.adjustBankIconWidth()
            }
        }
        
        let imageName = viewModel.transferEmitted.transferType == .emitted ? "icnIssued" : "icnReceived"
        self.transferTypeImageView.image = Assets.image(named: imageName)
        layoutIfNeeded()
    }
    
    func dottedHidden(isLast: Bool) {
        self.dottedLineView.isHidden = isLast
        self.completeLineView.isHidden = !isLast
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var size = super.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: horizontalFittingPriority,
                                                 verticalFittingPriority: verticalFittingPriority)
        if size.height < 74.0 {
            size.height = 74.0
        }
        
        return size
    }
}

private extension MonthTransfersTableViewCell {
    func commonInit() {
        self.nameView.layer.cornerRadius = self.nameView.bounds.height / 2
        self.nameView.backgroundColor = .clear
        
        self.name.textColor = .lisboaGray
        self.name.font = .santander(type: .bold, size: 16.0)
        
        self.acount.textColor = .lisboaGray
        self.acount.font = .santander(size: 14.0)
        
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(type: .bold, size: 20.0)
        
        self.initialsLabel.textColor = .white
        self.initialsLabel.font = .santander(type: .bold, size: 15.0)
        
        self.dottedLineView.strokeColor = .mediumSkyGray
        self.completeLineView.backgroundColor = .mediumSkyGray
        self.completeLineView.isHidden = true
        
        self.selectionStyle = .none
    }
    
    func adjustBankIconWidth() {
        guard let image = bankIconImageView.image else { return bankIconWidth.constant = 0.0 }
        let imageAspectRatio = image.size.width / image.size.height
        let scaledWidth = bankIconHeight.constant * imageAspectRatio
        
        bankIconWidth.constant = scaledWidth
    }
}
