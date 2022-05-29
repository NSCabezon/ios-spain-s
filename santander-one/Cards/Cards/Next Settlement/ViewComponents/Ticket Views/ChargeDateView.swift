//
//  ChargeDateView.swift
//  Cards
//
//  Created by Laura González on 06/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class ChargeDateView: UIDesignableView {
    
    @IBOutlet private weak var iconInfoImage: UIImageView!
    @IBOutlet private weak var chargeDateLabel: UILabel!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
        setAccessibilityIdentifiers()
    }
    
    func setInfo(_ chargeDateText: LocalizedStylableText) {
        chargeDateLabel.configureText(withLocalizedString: chargeDateText)
    }
}

private extension ChargeDateView {
    func setupView() {
        self.iconInfoImage.image = Assets.image(named: "icnInfo")
        self.backgroundColor = .clear
        chargeDateLabel.setSantanderTextFont(type: .light, size: 14.0, color: .black)
    }
    
    func setAccessibilityIdentifiers() {
        iconInfoImage.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.iconInfoImage.rawValue
        chargeDateLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.chargeDateLabel.rawValue
    }
}
