//
//  ReceiptCollectionViewCell.swift
//  Bills
//
//  Created by alvola on 04/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ReceiptCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView: BittenFrameView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var operationDateLabel: UILabel!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    @IBOutlet private weak var estimatedLabel: UILabel!
    @IBOutlet private weak var skeumorfismImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setInfo(_ info: FutureBillDetailViewModel) {
        titleLabel.text = info.personName
        aliasLabel.text = info.accountNumber
        operationDateLabel.configureText(withLocalizedString: info.dateLocalized,
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .bold, size: 14.0)))
        amountLabel.attributedText = info.amount
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        var size = super.systemLayoutSizeFitting(targetSize)
        if size.height < 196.0 {
            size.height = 196.0
        }
        return size
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        var size = super.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: horizontalFittingPriority,
                                                 verticalFittingPriority: verticalFittingPriority)
        if size.height < 196.0 {
            size.height = 196.0
        }
        
        return size
    }
}

private extension ReceiptCollectionViewCell {
    func commonInit() {
        configureView()
        configureLabels()
        configureAccessibilityIds()
    }
    
    func configureView() {
        containerView.biteCenterY = 98.0
        containerView.backgroundColor = .clear
        dottedLineView.strokeColor = .lightSkyBlue
        skeumorfismImageView.image = Assets.image(named: "imgTorn")
        
    }
    
    func configureLabels() {
        titleLabel.font = UIFont.santander(type: .bold, size: 18.0)
        titleLabel.textColor = .lisboaGray
        
        aliasLabel.font = UIFont.santander(size: 14.0)
        aliasLabel.textColor = .grafite
        
        amountLabel.font = UIFont.santander(type: .bold, size: 32.0)
        amountLabel.textColor = .lisboaGray
        
        operationDateLabel.textColor = .bostonRed
        
        estimatedLabel.text = localized("detailReceipt_label_estimated")
        estimatedLabel.font = UIFont.santander(size: 13.0)
        estimatedLabel.textColor = .grafite
    }
    
    func configureAccessibilityIds() {
        containerView.accessibilityIdentifier = "areaReceipt"
        skeumorfismImageView.accessibilityIdentifier = "Bitmap"
    }
}
