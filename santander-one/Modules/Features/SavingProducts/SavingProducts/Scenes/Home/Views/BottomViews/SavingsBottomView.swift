//
//  SavingsBottomView.swift
//  SavingProducts
//
//  Created by Jose Camallonga on 16/3/22.
//

import Foundation
import CoreFoundationLib
import UI
import UIOneComponents
import UIKit

final class SavingsBottomView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.scaledFont = .typography(fontName: .oneH300Bold)
        label.textColor = .oneLisboaGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.scaledFont = .typography(fontName: .oneB400Regular)
        label.textColor = .oneLisboaGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewsConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviewsConstraints()
    }
    
    func configure(titleKey: String, infoKey: String) {
        titleLabel.configureText(withKey: titleKey)
        infoLabel.configureText(withKey: infoKey)
        setAccessibilityIds()
    }
}

private extension SavingsBottomView {
    func addSubviewsConstraints() {
        addSubview(titleLabel)
        addSubview(infoLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            infoLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -56)
        ])
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = "savingsInfoPopup"
        titleLabel.accessibilityIdentifier = "savingsInfoPopupTitle"
        infoLabel.accessibilityIdentifier = "savingsInfoPopupDescription"
    }
}
