//
//  SummaryCodeDetailView.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 25/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib

class SummaryCodeDetailView: DesignableView {
    
    @IBOutlet weak var areaCodeView: UIView!
    
    @IBOutlet weak var titleCodeLabel: UILabel!
    @IBOutlet weak var titleAmountLabel: UILabel!
    @IBOutlet weak var titleExpiryDateLabel: UILabel!
    @IBOutlet weak var titleCommissionLabel: UILabel!
    @IBOutlet weak var titlePhoneLabel: UILabel!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func commonInit() {
        super.commonInit()
        
        configureViews()
        configureTitleLabels()
        configureDataLabels()
    }
    
    func configureViews() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
        
        areaCodeView.backgroundColor = .darkTorquoise
        areaCodeView.layer.cornerRadius = 5
    }
    
    func configureTitleLabels() {
        titleCodeLabel.text = localized("summary_item_code")
        titleAmountLabel.text = localized("summary_item_amount")
        titleExpiryDateLabel.text = localized("summary_item_expiryDate")
        titleCommissionLabel.text = localized("summary_item_commission")
        titlePhoneLabel.text = localized("summary_item_phone")
        
        titleCodeLabel.textColor = .white
        titleAmountLabel.textColor = .mediumSanGray
        titleExpiryDateLabel.textColor = .mediumSanGray
        titleCommissionLabel.textColor = .mediumSanGray
        titlePhoneLabel.textColor = .mediumSanGray
    }
    
    func configureDataLabels() {
        codeLabel.textColor = .white
        amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        amountLabel.textColor = .lisboaGrayNew
        expiryDateLabel.textColor = .lisboaGrayNew
        commissionLabel.textColor = .lisboaGrayNew
        phoneLabel.textColor = .lisboaGrayNew
    }
    
    func setAccessibilityIdentifiers(identifier: String? = nil) {
        if let identifier = identifier {
            titleCodeLabel.accessibilityIdentifier = identifier + "_titleCode"
            titleAmountLabel.accessibilityIdentifier = identifier + "_titleAmount"
            titleExpiryDateLabel.accessibilityIdentifier = identifier + "_titleExpiryDate"
            titleCommissionLabel.accessibilityIdentifier = identifier + "_titleCommission"
            titlePhoneLabel.accessibilityIdentifier = identifier + "_titlePhone"
            codeLabel.accessibilityIdentifier = identifier + "_code"
            amountLabel.accessibilityIdentifier = identifier + "_amount"
            expiryDateLabel.accessibilityIdentifier = identifier + "_expiryDate"
            commissionLabel.accessibilityIdentifier = identifier + "_commission"
            phoneLabel.accessibilityIdentifier = identifier + "_phone"
        }
    }
}
