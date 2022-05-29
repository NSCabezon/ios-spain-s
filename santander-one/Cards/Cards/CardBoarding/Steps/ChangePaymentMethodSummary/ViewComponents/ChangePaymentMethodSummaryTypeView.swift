//
//  ChangePaymentMethodSummaryTypeView.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 13/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ChangePaymentMethodSummaryTypeView: XibView {
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var typeViewContainer: UIView!

    func setPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.image.image = Assets.image(named: "icnChangeWayToPay")
        let factory = ViewFactory(paymentMethod: paymentMethod)
        let view = factory.get()
        self.typeViewContainer.addSubview(view)
        view.fullFit()
    }
}

private extension ChangePaymentMethodSummaryTypeView {
    
    struct ViewFactory {
        
        let paymentMethod: PaymentMethodCategory
        
        func get() -> UIView {
            switch self.paymentMethod {
            case .monthlyPayment:
                let view = TitledView()
                view.setupWithTitle(localized("changeWayToPay_label_monthly"), accessibilityIdentifier: AccessibilityCardBoarding.ChangePaymentMethod.Summary.monthly)
                return view
            case .fixedFee(let amount):
                let view = TitleAndSubtitledView()
                view.setupWithTitle(localized("changeWayToPay_label_fixedFee"), description: "\(amount?.getStringValue(withDecimal: 0) ?? "")", titleAccessibilityIdentifier: AccessibilityCardBoarding.ChangePaymentMethod.Summary.fixedFee, descriptionAccessibilityIdentifier: AccessibilityCardBoarding.ChangePaymentMethod.Summary.fixedFeeValue)
                return view
            case .deferredPayment(let amount):
                let view = TitleAndSubtitledView()
                view.setupWithTitle(localized("changeWayToPay_label_postpone"), description: "\(amount?.getFormattedValue(withDecimals: 0) ?? "")%", titleAccessibilityIdentifier: AccessibilityCardBoarding.ChangePaymentMethod.Summary.postpone, descriptionAccessibilityIdentifier: AccessibilityCardBoarding.ChangePaymentMethod.Summary.postponeValue)
                return view
            }
        }
    }
    
    class TitledView: UIView {
        
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.setSantanderTextFont(size: 24, color: .lisboaGray)
            return label
        }()
        
        func setupWithTitle(_ title: LocalizedStylableText, accessibilityIdentifier: String) {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.titleLabel)
            self.titleLabel.fullFit()
            self.titleLabel.accessibilityIdentifier = accessibilityIdentifier
            self.titleLabel.configureText(withLocalizedString: title)
        }
    }
    
    class TitleAndSubtitledView: UIView {
        
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.setSantanderTextFont(size: 15, color: .lisboaGray)
            return label
        }()
        private lazy var descriptionLabel: UILabel = {
            let label = UILabel()
            label.setSantanderTextFont(size: 24, color: .black)
            return label
        }()
        
        func setupWithTitle(_ title: LocalizedStylableText, description: String, titleAccessibilityIdentifier: String, descriptionAccessibilityIdentifier: String) {
            self.translatesAutoresizingMaskIntoConstraints = false
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.addArrangedSubview(self.titleLabel)
            stackView.addArrangedSubview(self.descriptionLabel)
            self.addSubview(stackView)
            stackView.fullFit()
            self.titleLabel.accessibilityIdentifier = titleAccessibilityIdentifier
            self.titleLabel.configureText(withLocalizedString: title,
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 15),
                                                                                               lineHeightMultiple: 0.85))
            self.descriptionLabel.accessibilityIdentifier = descriptionAccessibilityIdentifier
            self.descriptionLabel.text = description
        }
    }
}
