//
//  MonthDebtsTableViewCell.swift
//  Menu
//
//  Created by Laura González on 05/06/2020.
//

import CoreFoundationLib
import UI

final class MonthDebtsTableViewCell: UITableViewCell {
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    @IBOutlet private weak var completeLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(withViewModel viewModel: MonthDebtsViewModel) {
        self.descriptionLabel.text = viewModel.concept?.capitalized
        self.ibanLabel.attributedText = NSAttributedString(string: viewModel.iban)
        self.amountLabel.attributedText = viewModel.amount
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

private extension MonthDebtsTableViewCell {
    func commonInit() {
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.font = .santander(type: .bold, size: 16.0)
        
        self.ibanLabel.textColor = .grafite
        self.ibanLabel.font = .santander(type: .light, size: 16.0)
        
        self.feeLabel.textColor = .grafite
        self.feeLabel.font = .santander(type: .regular, size: 10.0)
        self.feeLabel.text = localized("analysis_label_instalment")
        
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(type: .bold, size: 20.0)
        
        self.dottedLineView.strokeColor = .mediumSkyGray
        self.completeLineView.backgroundColor = .mediumSkyGray
        self.completeLineView.isHidden = true
        self.selectionStyle = .none
    }
}
