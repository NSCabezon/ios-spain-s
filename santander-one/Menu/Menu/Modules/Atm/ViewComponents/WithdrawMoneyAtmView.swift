//
//  WithdrawMoneyAtmView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 31/08/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol WithdrawMoneyAtmViewDelegate: AnyObject {
    func didSelectedGetMoneyWithCode()
}

final class WithdrawMoneyAtmView: XibView {
    
    @IBOutlet weak var containerView: UIView!
    weak var delegate: WithdrawMoneyAtmViewDelegate?
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var withdrawMoneyButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawShadows()
    }
 
    @IBAction func didTapOnGetMoneyWithCode(_ sender: Any) {
        self.delegate?.didSelectedGetMoneyWithCode()
    }
}

private extension WithdrawMoneyAtmView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.image = Assets.image(named: "icnCodeWithdraw")
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: "atm_button_codeWithdraw",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20)))
        self.arrowImageView.image = Assets.image(named: "icnArrowRight")
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.iconImageView.accessibilityIdentifier = AccessibilityAtm.icnWithDraw.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.titleLabelGetMoneyWithCode.rawValue
        self.arrowImageView.accessibilityIdentifier = AccessibilityAtm.arrowImageRight.rawValue
        self.withdrawMoneyButton.accessibilityIdentifier = AccessibilityAtm.getMoneyWithCodeCell.rawValue
    }
    
    func drawShadows() {
        self.containerView.drawShadow(offset: (x: 1, y: 2), color: .shadesWhite)
    }
}
