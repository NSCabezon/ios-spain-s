//
//  DefaultMoneyBox.swift
//  Menu
//
//  Created by Ignacio González Miró on 04/06/2020.
//

import UIKit
import UI

class DefaultMoneyBox: UIDesignableView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var moneyBoxImg: UIImageView!
    @IBOutlet weak private var arrowImg: UIImageView!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func configView(_ title: NSAttributedString, _ detail: String) {
        self.titleLabel.attributedText = title
        self.detailLabel.text = detail
    }
}

private extension DefaultMoneyBox {
    func setupView() {
        self.backgroundColor = .clear
        self.setLabels()
        self.setImages()
    }
    
    func setLabels() {
        self.detailLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.detailLabel.textColor = .santanderRed
        self.detailLabel.textAlignment = .left
    }
    
    func setImages() {
        self.arrowImg.image = Assets.image(named: "icnArrowRightRedBig")
        self.moneyBoxImg.image = Assets.image(named: "group22")
    }
}
