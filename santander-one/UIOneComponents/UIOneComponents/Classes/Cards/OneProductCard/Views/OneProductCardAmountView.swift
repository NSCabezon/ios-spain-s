//
//  OneProductCardAmountView.swift
//  UIOneComponents
//
//  Created by Jose Javier Montes Romero on 14/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine

private extension OneProductCardAmountView {}

final class OneProductCardAmountView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setupProductCard(_ model: OneProductCardAmountRepresentable) {
        configureAmountView(model: model)
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }

}

private extension OneProductCardAmountView {
    
    func setupView() {
        configureLabels()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.titleLabel.textColor = .oneBrownishGray
        self.amountLabel.font = .typography(fontName: .oneB300Regular)
        self.amountLabel.textColor = .oneLisboaGray
    }
    
    func configureAmountView(model: OneProductCardAmountRepresentable) {
        self.titleLabel.text = model.title
        let decorator = AmountRepresentableDecorator(model.amount, font: .typography(fontName: .oneB300Regular), decimalFontSize: 14)
        self.amountLabel.attributedText = decorator.formattedCurrencyWithoutMillion
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardAmountTitleLabel + (suffix ?? "")
        self.amountLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardAmountLabel + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        accessibilityElements = [titleLabel, amountLabel].compactMap {$0}
    }
}

extension OneProductCardAmountView: AccessibilityCapable {}
