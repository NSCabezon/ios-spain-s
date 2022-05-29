//
//  BankableCardReceiptSeeMoreCollectionViewCell.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 14/1/22.
//

import UIKit
import UI

final class BankableCardReceiptSeeMoreCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BankableCardReceiptSeeMoreCollectionViewCell"

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
    }
}

private extension BankableCardReceiptSeeMoreCollectionViewCell {
    func setupCard() {
        containerView.backgroundColor = .darkTorquoise
        containerView.layer.cornerRadius = 8
        cardImageView.image = Assets.image(named: "icnFinancingCards")?.withRenderingMode(.alwaysOriginal)
        let font: UIFont = .santander(family: .micro, type: .bold, size: 13.0)
        let configuration = LocalizedStylableTextConfiguration(font: font)
        infoLabel.textColor = .white
        infoLabel.configureText(withKey: "financing_label_seeMoreCards", andConfiguration: configuration)
    }
}
