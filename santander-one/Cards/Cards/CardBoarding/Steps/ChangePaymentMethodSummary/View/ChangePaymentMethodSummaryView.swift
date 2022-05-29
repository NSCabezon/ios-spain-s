//
//  ChangePaymentMethodSummaryView.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 13/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol ChangePaymentMethodSummaryViewDelegate: AnyObject {
    func didSelectNextStep()
    func didSelectClose()
}

final class ChangePaymentMethodSummaryView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var topSuccessImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var paymentView: UIView!
    @IBOutlet private weak var continueContainerView: UIView!
    @IBOutlet private weak var continueLabel: UILabel!
    @IBOutlet private weak var nextStepButton: RedLisboaButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    private let paymentMethod: PaymentMethodCategory
    private weak var delegate: ChangePaymentMethodSummaryViewDelegate?
    
    init(delegate: ChangePaymentMethodSummaryViewDelegate, paymentMethod: PaymentMethodCategory) {
        self.paymentMethod = paymentMethod
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension ChangePaymentMethodSummaryView {
    
    func setupView() {
        self.setupViewBackground()
        self.setupClose()
        self.setupTopSuccessImage()
        self.setupTitle()
        self.setupDescription()
        self.setupPaymentMethod()
        self.setupContinue()
        self.setupNextStepButton()
        self.setupAccessibilityIdentifiers()
    }
    
    func setupViewBackground() {
        self.view?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.drawRoundedAndShadowedNew(radius: 5, borderColor: .mediumSkyGray, widthOffSet: 0, heightOffSet: 2)
    }
    
    func setupTopSuccessImage() {
        self.topSuccessImage.image = Assets.image(named: "icnCheckAlert")
    }
    
    func setupTitle() {
        self.titleLabel.setSantanderTextFont(type: .bold, size: 22, color: .lisboaGray)
        self.titleLabel.configureText(withLocalizedString: localized("summe_title_perfect"))
    }
    
    func setupDescription() {
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "summary_text_changePayment",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20),
                                                                                                 lineHeightMultiple: 0.85))
    }
    
    func setupPaymentMethod() {
        let paymentMethodView = ChangePaymentMethodSummaryTypeView(frame: .zero)
        paymentMethodView.setPaymentMethod(self.paymentMethod)
        self.paymentView.addSubview(paymentMethodView)
        self.paymentView.drawBorder(color: .mediumSky)
        paymentMethodView.fullFit()
    }
    
    func setupContinue() {
        self.continueContainerView.backgroundColor = .whitesmokes
        self.continueLabel.textColor = .lisboaGray
        self.continueLabel.configureText(withKey: "summary_text_continueProcessSigning",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14),
                                                                                              lineHeightMultiple: 0.85))
    }
    
    func setupNextStepButton() {
        self.nextStepButton.setTitle(localized("cardBoarding_button_next"), for: .normal)
        self.nextStepButton.addAction { [weak self] in
            self?.removeFromSuperview()
            self?.delegate?.didSelectNextStep()
        }
    }
    
    func setupClose() {
        self.closeButton.setTitle(nil, for: .normal)
        self.closeButton.setImage(Assets.image(named: "icnCloseGrey"), for: .normal)
    }
    
    func setupAccessibilityIdentifiers() {
        self.topSuccessImage.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.icnCheck
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.title
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.description
        self.continueLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.continueText
        self.nextStepButton.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.nextStepButton
        self.closeButton.accessibilityIdentifier = AccessibilityCardBoarding.ChangePaymentMethod.Summary.icnClose
    }
    
    @IBAction func closeSelected() {
        self.removeFromSuperview()
        self.delegate?.didSelectClose()
    }
}
