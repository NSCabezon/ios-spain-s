//
//  EmitterElementTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit

class EmitterElementTableViewCell: UITableViewCell {
    static let identifier = "EmitterElementTableViewCell"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var boxView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBorder()
        self.boxView.backgroundColor = UIColor.skyGray
    }
    
    func setViewModel(_ viewModel: IncomeViewModel) {
        self.incomeLabel.text = viewModel.description
    }
}

private extension EmitterElementTableViewCell {
    func setBorder() {
        self.viewContainer.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.viewContainer.drawRoundedAndShadowedNew()
    }
}
