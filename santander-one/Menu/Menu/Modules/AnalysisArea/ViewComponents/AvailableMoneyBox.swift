//
//  AvailableMoneyBox.swift
//  Menu
//
//  Created by Ignacio González Miró on 04/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

class AvailableMoneyBox: UIDesignableView {
    @IBOutlet weak private var moneyBoxImg: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var separatorTopView: UIView!
    @IBOutlet weak private var separatorBottomView: UIView!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
        self.setLabels()
        self.setIdentifiers()
    }
    
    func configView(_ title: String, _ detail: NSAttributedString) {
        self.titleLabel.text = title
        self.detailLabel.attributedText = detail
        self.detailLabel.accessibilityIdentifier = detail.string
    }
}

private extension AvailableMoneyBox {
    func setupView() {
        self.backgroundColor = .clear
        self.separatorTopView.backgroundColor = .mediumSkyGray
        self.separatorBottomView.backgroundColor = .mediumSkyGray
        self.moneyBoxImg.image = Assets.image(named: "imgPiggyBank02")
    }
    
    func setLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 21.0)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = .lisboaGray
        self.detailLabel.textAlignment = .right
        self.detailLabel.textColor = .lisboaPurple
    }
    
    func setIdentifiers() {
        self.separatorTopView.accessibilityIdentifier = AccessibilityAnalysisArea.separator.rawValue
        self.separatorBottomView.accessibilityIdentifier = AccessibilityAnalysisArea.separator.rawValue
        self.moneyBoxImg.accessibilityIdentifier = AccessibilityAnalysisArea.piggyLeftImg.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityAnalysisArea.piggyTitle.rawValue
    }
}
