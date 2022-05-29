//
//  MonthReceiptTableViewCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import UIKit
import CoreFoundationLib
import UI

class MonthReceiptTableViewCell: UITableViewCell {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var receiptImg: UIImageView!    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var entityImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var entityImageConstraint: NSLayoutConstraint!
    static let identifier = "MonthReceiptTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func config(_ viewModel: ReceiptsViewModel) {
        self.titleLabel.text = viewModel.title.capitalized
        self.ibanLabel.text = viewModel.shortIban
        self.amountLabel.attributedText = viewModel.amount
        if let iconUrl = viewModel.iconUrl {
            self.receiptImg.loadImage(urlString: iconUrl) { [weak self] in
                if let iconUrlSize = self?.receiptImg?.image?.size {
                    let height = self?.entityImageHeightConstraint.constant
                    let newWidth = (iconUrlSize.width * (height ?? 25)) / iconUrlSize.height
                    self?.entityImageConstraint.constant = newWidth
                    self?.receiptImg.contentMode = .scaleAspectFit
                } else {
                    self?.receiptImg.image = nil
                    self?.entityImageConstraint.constant = 0
                }
            }
        } else {
            self.receiptImg.image = nil
            self.entityImageConstraint.constant = 0
        }
    }
}

private extension MonthReceiptTableViewCell {
    func setupView() {
        self.backgroundColor = .clear
        self.setLabels()
        self.setAppeareance()
    }
    
    func setLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.textAlignment = .left
        self.titleLabel.numberOfLines = 0
        self.ibanLabel.font = UIFont.santander(family: .text, type: .light, size: 13.0)
        self.ibanLabel.textColor = .grafite
        self.ibanLabel.textAlignment = .left
        self.amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.textAlignment = .right
    }
    
    func setAppeareance() {
        let shadowConfiguration = ShadowConfiguration(color: UIColor.lightSanGray.withAlphaComponent(0.35), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.baseView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
    }
}
