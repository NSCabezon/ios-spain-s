//
//  CardBoardingTabBar.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/6/20.
//

import Foundation
import CoreFoundationLib
import UI

final class CardBoardingTabBar: XibView {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: WhiteLisboaButton!
    @IBOutlet weak var topDivider: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.setButtonAppearance()
        self.view?.backgroundColor = .white
        self.topDivider.backgroundColor = .mediumSkyGray
        self.backButton.set(localizedStylableText: localized("generic_button_previous"), state: .normal)
        self.nextButton.set(localizedStylableText: localized("cardBoarding_button_next"), state: .normal)
        self.backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.backButton.titleLabel?.minimumScaleFactor = 0.7
        self.nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func setButtonAppearance() {
        self.backButton.tintColor = .santanderRed
        self.backButton.setImage(Assets.image(named: "icnArrowLeftRedNew"), for: .normal)
        self.backButton.setTitleColor(.santanderRed, for: .normal)
        self.backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 3, right: 0)
        self.backButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        self.backButton.accessibilityIdentifier = "cardBoardingBtnBack"
        self.nextButton.accessibilityIdentifier = "cardBoardingBtnNext"
    }
    
    func addBackAction(target: Any?, selector: Selector) {
        self.backButton.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func addNextAction(target: Any?, selector: Selector) {
        self.nextButton.addSelectorAction(target: target, selector)
    }
}
