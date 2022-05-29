//
//  QuickBalanceSectionView.swift
//  Login
//
//  Created by Iván Estévez on 02/04/2020.
//

import CoreFoundationLib
import UIKit
import UI

final class QuickBalanceSectionView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setAccessibility()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setAccessibility()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

private extension QuickBalanceSectionView {
    func setupView() {
        titleLabel.font = .santander(family: .text, type: .bold, size: 14)
        titleLabel.textColor = .black
    }
    
    func setAccessibility() {
        titleLabel?.accessibilityIdentifier = AccessibilityQuickBalanceSectionView.sectionTitleLabel.rawValue
    }
}
