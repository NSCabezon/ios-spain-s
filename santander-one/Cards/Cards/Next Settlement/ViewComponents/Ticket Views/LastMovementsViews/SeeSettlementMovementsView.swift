//
//  SeeSettlementMovementsCell.swift
//  Cards
//
//  Created by Laura González on 07/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class SeeSettlementMovementsView: UIDesignableView {
    @IBOutlet private weak var seeMovementsLabel: UILabel!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet weak var seeMovementsButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
        setAccessibilityIdentifiers()
    }
}

private extension SeeSettlementMovementsView {
    func setupView() {
        self.backgroundColor = .clear
        self.seeMovementsLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .santanderRed)
        self.arrowImage.image = Assets.image(named: "icnBack")
        self.seeMovementsLabel.text = localized("generic_button_viewMovements")
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setAccessibilityIdentifiers() {
        seeMovementsLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.seeMovementsLabel.rawValue
        arrowImage.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.arrowImage.rawValue
        seeMovementsButton.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementBtnViewMovements.rawValue
    }
}
