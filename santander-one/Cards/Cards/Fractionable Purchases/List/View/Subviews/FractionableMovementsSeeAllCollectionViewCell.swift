//
//  FractionableMovementsSeeAllCollectionViewCell.swift
//  Cards
//
//  Created by alvola on 18/02/2021.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionableMovementsSeeAllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var frameView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
}

private extension FractionableMovementsSeeAllCollectionViewCell {
    func commonInit() {
        configureView()
        configureLabel()
        configureIcon()
    }
    
    func configureView() {
        frameView.backgroundColor = .darkTorquoise
        frameView.layer.cornerRadius = 5.0
    }
    
    func configureLabel() {
        titleLabel.font = UIFont.santander(type: .bold, size: 15.0)
        titleLabel.textColor = .white
        titleLabel.text = localized("fractionatePurchases_label_allPurchasesFractionate")
    }
    
    func configureIcon() {
        iconImage.image = Assets.image(named: "icnFractionablePurchases")?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = .white
    }
}
