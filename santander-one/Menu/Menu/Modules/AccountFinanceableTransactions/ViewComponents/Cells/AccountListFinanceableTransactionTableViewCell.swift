//
//  AccountListFinanceableTransactionTableViewCell.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import UIKit
import UI

class AccountListFinanceableTransactionTableViewCell: UITableViewCell {
    static let identifier = "AccountListFinanceableTransactionTableViewCell"
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var pointLineDivider: PointLine!
    @IBOutlet weak var dividerView: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func setViewModel(_ viewModel: AccountListFinanceableTransactionViewModel) {
        self.descriptionLabel.text = viewModel.title
        self.amountLabel.attributedText = viewModel.amount
    }
}
