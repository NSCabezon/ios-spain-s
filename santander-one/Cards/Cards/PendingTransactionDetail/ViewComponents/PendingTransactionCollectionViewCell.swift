//
//  PendingTransactionCollectionViewCell.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//

import UI
import UIKit

class PendingTransactionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PendingTransactionCollectionViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardAliasLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var operationDateTitleLabel: UILabel!
    @IBOutlet weak var operationDateLabel: UILabel!
    @IBOutlet weak var operationTimeTitle: UILabel!
    @IBOutlet weak var operationTimeLabel: UILabel!
    @IBOutlet weak var dividerView: PointLine!
    var state: ResizableState = .colapsed
    private let stimatedSize: CGFloat = 192
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
    }
    
    func configure(_ viewModel: PendingTransactionDetailViewModel) {
        self.titleLabel.text = viewModel.description
        self.cardAliasLabel.text = viewModel.cardAlias
        self.amountLabel.attributedText = viewModel.amount
        self.operationDateTitleLabel.configureText(withKey: "transaction_label_operationDate")
        self.operationTimeTitle.configureText(withKey: "transaction_label_hour")
        self.operationDateLabel.text = viewModel.annotationDate
        self.operationTimeLabel.text = viewModel.operationTime
        self.contentView.accessibilityIdentifier = "detailsCardsListMovPendingLiquidate"
        self.dividerView.accessibilityIdentifier = "DivH"
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.contentView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
    }
    
    func toggleState() { }
}

extension PendingTransactionCollectionViewCell: Resizable {
    func getExpandedHeight() -> CGFloat {
        return .zero
    }
    
    func getCollapsedHeight() -> CGFloat {
        let text = self.titleLabel.text ?? ""
        let width = self.contentView.bounds.width - 24
        let font = self.titleLabel.font ?? .santander(family: .text, type: .bold, size: 18)
        let textHeight = text.height(withConstrainedWidth: width, font: font)
        let height = (164 + textHeight)
        return height > stimatedSize ? height : stimatedSize
    }
    
    func getOfferHeight() -> CGFloat {
        return .zero
    }
}
