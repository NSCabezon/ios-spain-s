//
//  VerticalExpenseInfoView.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 26/12/2019.
//

import UI
import CoreFoundationLib
class VerticalExpenseInfoView: DesignableView {
    
    @IBOutlet weak var amountLabel: BluringLabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var monthInfo: String = ""
    
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = .white
        monthLabel.backgroundColor = UIColor.darkTorquoise
        monthLabel.textColor = .white
        monthLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 13)
        amountLabel.textColor = .black
        amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 17)
        amountLabel.textAlignment = .center
        containerView.backgroundColor = .clear
        setAccessibilityIdentifiers()
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.bounds.size.width/2
        monthLabel.layer.masksToBounds = true
        monthLabel.layer.cornerRadius = monthLabel.bounds.size.width/2
        // rotate amount label
        amountLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
    
    private func setAccessibilityIdentifiers() {
        amountLabel.accessibilityIdentifier = "verticalExpense_amountLabel"
        monthLabel.accessibilityIdentifier = "verticalExpense_monthLabel"
        self.accessibilityIdentifier = "verticalExpense_view"
    }
}
