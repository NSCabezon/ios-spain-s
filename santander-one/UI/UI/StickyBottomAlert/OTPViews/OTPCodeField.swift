//
//  OTPCodeField.swift
//  UI
//
//  Created by alvola on 24/06/2020.
//

import UIKit
import CoreFoundationLib

public final class OTPCodeField: UIView {
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.santander(type: .bold, size: 30.0)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.darkTorquoise
        addSubview(label)
        return label
    }()
    
    private let letterSpacing: CGFloat = 10.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func setCode(_ code: String) {
        let attributedCode = NSMutableAttributedString(string: code)
        attributedCode.addAttribute(NSAttributedString.Key.kern,
                                    value: letterSpacing,
                                    range: NSRange(location: 0, length: code.count))
        codeLabel.attributedText = attributedCode
    }
}

private extension OTPCodeField {
    func commonInit() {
        backgroundColor = .white
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor.silverDark.cgColor
        layer.borderWidth = 1.0
        
        codeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 5.0).isActive = true
        codeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: letterSpacing / 2.0).isActive = true
        codeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        configureAccessibilityIds()
    }
    
    func configureAccessibilityIds() {
        codeLabel.accessibilityIdentifier = "N143N393"
    }
}
