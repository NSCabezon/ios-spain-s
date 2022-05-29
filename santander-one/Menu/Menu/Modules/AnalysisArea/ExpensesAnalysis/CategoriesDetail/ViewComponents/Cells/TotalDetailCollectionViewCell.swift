//
//  TotalDetailCollectionViewCell.swift
//  Menu
//
//  Created by David Gálvez Alonso on 06/07/2021.
//

import UIKit
import UI

final class TotalDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setViewModel(_ titleText: String, amountText: String, isSelected: Bool) {
        self.titleLabel.text = titleText
        self.amountLabel.text = amountText
        self.setupSelected(isSelected)
    }
}

private extension TotalDetailCollectionViewCell {
    func setupView() {
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderWidth = 1
        self.checkImageView.image = Assets.image(named: "icnCheckOvalGreen")
    }
    
    func setupSelected(_ selected: Bool) {
        guard selected else {
            self.containerView.layer.borderColor = UIColor.coolGray.cgColor
            self.containerView.backgroundColor = UIColor.white
            self.titleLabel.setSantanderTextFont(type: .regular, size: 12, color: .lisboaGray)
            self.amountLabel.setSantanderTextFont(type: .bold, size: 12, color: .lisboaGray)
            self.checkImageView.isHidden = true
            return
        }
        self.containerView.layer.borderColor = UIColor.darkTorquoise.cgColor
        self.containerView.backgroundColor = UIColor.darkTorquoise.withAlphaComponent(0.06)
        self.titleLabel.setSantanderTextFont(type: .bold, size: 12, color: .darkTorquoise)
        self.amountLabel.setSantanderTextFont(type: .bold, size: 12, color: .darkTorquoise)
        self.checkImageView.isHidden = false
    }
}

extension TotalDetailCollectionViewCell {
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        self.sizeToFit()
        return self.bounds.size
    }
}
