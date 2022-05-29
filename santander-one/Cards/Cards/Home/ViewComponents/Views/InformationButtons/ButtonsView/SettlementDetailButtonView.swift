//
//  SettlementDetailButtonView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 06/10/2020.
//

import UI
import CoreFoundationLib

protocol SettlementDetailButtonViewDelegate: AnyObject {
    func settlementDetailButtonTapped()
}

final class SettlementDetailButtonView: BaseInformationButton {
    
    @IBOutlet private weak var buttonView: UIView!
    @IBOutlet private weak var nextReceiptLabel: UILabel!
    @IBOutlet private weak var inputDateLabel: UILabel!
    @IBOutlet private weak var receivedAmountLabel: UILabel!
    @IBOutlet private weak var fromTextLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    weak var delegate: SettlementDetailButtonViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: CardViewModel) {
        if let fromDateToDate = viewModel.settlementeFromDateToDate {
            fromTextLabel.configureText(withLocalizedString: fromDateToDate)
        }
        if let ascriptionDate = viewModel.ascriptionDate {
            inputDateLabel.text = ascriptionDate
        }
        if let receivedAmount = viewModel.settlementAmount {
            receivedAmountLabel.attributedText = receivedAmount
        }
        if viewModel.settlementInTime {
            buttonView.backgroundColor = .bostonRedLight
            fromTextLabel.textColor = .white
            receivedAmountLabel.textColor = .white
            arrowImageView.tintColor = .white
            nextReceiptLabel.textColor = .white
            inputDateLabel.textColor = .white
            fromTextLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.viewAndDeferBill
        }
    }
}

private extension SettlementDetailButtonView {
    func setupView() {
        addGesture()
        configureView()
        configureLabels()
        configureImage()
        setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    func configureView() {
        self.backgroundColor = .clear
        buttonView.backgroundColor = UIColor.darkTorquoise.withAlphaComponent(0.12)
        buttonView.layer.cornerRadius = 5.0
        self.accessibilityIdentifier = AccessibilityCardsHome.cardHomeBtnNextSettlement
    }
    
    func configureLabels() {
        nextReceiptLabel.textColor = .lisboaGray
        nextReceiptLabel.configureText(withKey: "card_label_nextSettlement",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        nextReceiptLabel.adjustsFontSizeToFitWidth = true
        nextReceiptLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.nextSettlement
        inputDateLabel.textColor = .brownishGray
        inputDateLabel.font = .santander(family: .text, type: .bold, size: 10)
        inputDateLabel.adjustsFontSizeToFitWidth = true
        inputDateLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.cardHomeLabelSettlementDate
        receivedAmountLabel.textColor = .lisboaGray
        receivedAmountLabel.adjustsFontSizeToFitWidth = true
        receivedAmountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.valueEuro
        fromTextLabel.textColor = .darkTorquoise
        fromTextLabel.font = .santander(family: .text, type: .regular, size: 12)
        fromTextLabel.adjustsFontSizeToFitWidth = true
        fromTextLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.datesPeriod
    }
    
    func configureImage() {
        arrowImageView.image = Assets.image(named: "icnArrowRight")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .darkTorquoise
        arrowImageView.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.icnArrowRight
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.settlementDetailButtonTapped()
    }
    
    func setAccessibilityInfo() {
        self.isAccessibilityElement = true
    }
}

extension SettlementDetailButtonView: AccessibilityCapable {}
