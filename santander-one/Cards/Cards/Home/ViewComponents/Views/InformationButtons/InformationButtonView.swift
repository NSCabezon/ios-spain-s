//
//  InformationButtonView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/25/19.
//

import UIKit
import UI
import CoreFoundationLib

enum CardInformationButton {
    case liquidation
    case map
    case cashDisposition
    case changePaymentMethod
    case settlementDetail
}

protocol InformationButtonViewProtocol: AnyObject {
    func informationButtonTapped(button: CardInformationButton)
}

class InformationButtonView: XibView {
    @IBOutlet weak var leftButtonView: UIView?
    @IBOutlet weak var rightButtonView: UIView?
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    weak var informationButtonDelegate: InformationButtonViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.setAppearance()
    }
    
    public func updateButtons() {
        self.buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.buttonsStackView.addArrangedSubview(leftButtonView ?? UIView())
        self.buttonsStackView.addArrangedSubview(rightButtonView ?? UIView())
        self.setAppearance()
    }
    
    private func setAppearance() {
        self.addBorder(forView: leftButtonView)
        self.addShadow(forView: leftButtonView)
        self.addBorder(forView: rightButtonView)
        self.addShadow(forView: rightButtonView)
    }
    
    private func addBorder(forView view: UIView?) {
        view?.layer.borderWidth = 1
        view?.layer.cornerRadius = 5
        view?.backgroundColor = UIColor.skyGray
        view?.layer.borderColor = UIColor.mediumSkyGray.cgColor
    }
    
    private func addShadow(forView view: UIView?) {
        view?.layer.shadowOffset = CGSize(width: 1, height: 2)
        view?.layer.shadowRadius = 5
        view?.layer.shadowOpacity = 0.7
        view?.layer.shadowColor = UIColor.mediumSkyGray.cgColor
        view?.layer.masksToBounds = false
        view?.clipsToBounds = false
    }
}
extension InformationButtonView: LiquidationButtonViewProtocol, MapButtonViewProtocol, CashDispositionButtonViewProtocol, ChangePaymentMethodFailViewDelegate, ChangePaymentMethodSuccessViewDelegate, SettlementDetailButtonViewDelegate, EmptySettlementButtonViewDelegate {
        
    func liquidationButtonTapped() {
        informationButtonDelegate?.informationButtonTapped(button: .liquidation)
    }
    
    func mapButtonTapped() {
        informationButtonDelegate?.informationButtonTapped(button: .map)
    }
    
    func cashDispositionWithCodeButtonTapped() {
        self.informationButtonDelegate?.informationButtonTapped(button: .cashDisposition)
    }
    
    func changePaymentMethodWithCodeButtonTapped() {
        self.informationButtonDelegate?.informationButtonTapped(button: .changePaymentMethod)
    }
    
    func settlementDetailButtonTapped() {
        self.informationButtonDelegate?.informationButtonTapped(button: .settlementDetail)
    }
    
    func emptySettlementButtonTapped() {
        self.informationButtonDelegate?.informationButtonTapped(button: .settlementDetail)
    }
}
