//
//  EcommerceDateView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceDateView: XibView {
    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var dateImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ info: EcommerceViewModel) {
        self.hourLabel.text = info.formattedTime
    }
}

private extension EcommerceDateView {
    func setupView() {
        self.backgroundColor = .clear
        self.dateImageView.image = Assets.image(named: "icnClockGray20")
        self.setDateLabel()
        self.setAccessibilityIds()
    }
    
    func setDateLabel() {
        self.hourLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        self.hourLabel.textAlignment = .right
        self.hourLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceDateView.baseView
        self.hourLabel.accessibilityIdentifier = AccessibilityEcommerceDateView.hourLabel
        self.dateImageView.accessibilityIdentifier = AccessibilityEcommerceDateView.dateImageView
    }
}
