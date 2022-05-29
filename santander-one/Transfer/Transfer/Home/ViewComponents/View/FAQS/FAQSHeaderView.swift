//
//  FAQSHeaderView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI
class FAQSHeaderView: XibView {
    @IBOutlet var headerView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel.configureText(withKey: "helpCenter_title_faqs",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0)))
    }
    
    private func addGradientLayer() {
        self.headerView.applyGradientBackground(colorStart: UIColor.darkTorquoise, colorFinish: UIColor.lightNavy)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientLayer()
    }
}
