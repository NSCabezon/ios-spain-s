//
//  EmptySettlementButtonView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 08/10/2020.
//

import CoreFoundationLib
import UI

protocol EmptySettlementButtonViewDelegate: AnyObject {
    func emptySettlementButtonTapped()
}

final class EmptySettlementButtonView: BaseInformationButton {
    @IBOutlet private weak var buttonView: UIView!
    @IBOutlet private weak var noSettlementsLabel: UILabel!
    @IBOutlet private weak var moreInformationLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    weak var delegate: EmptySettlementButtonViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EmptySettlementButtonView {
    func setupView() {
        addGesture()
        configureView()
        configureLabels()
        configureImage()
    }
    
    func configureView() {
        self.backgroundColor = .clear
        buttonView.backgroundColor = UIColor.darkTorquoise.withAlphaComponent(0.12)
        buttonView.layer.cornerRadius = 5.0
        self.accessibilityIdentifier = AccessibilityCardsHome.cardHomeBtnNextSettlement
    }
    
    func configureLabels() {
        noSettlementsLabel.textColor = .lisboaGray
        noSettlementsLabel.configureText(withKey: "card_label_notSettlement",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        noSettlementsLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.notSettlement
        moreInformationLabel.textColor = .darkTorquoise
        moreInformationLabel.adjustsFontSizeToFitWidth = true
        moreInformationLabel.configureText(withKey: "generic_label_moreInfo",
                                           andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12)))
        moreInformationLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.moreInfo
    }
    
    func configureImage() {
        arrowImageView.image = Assets.image(named: "icnArrowRight")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .darkTorquoise
        arrowImageView.accessibilityIdentifier = AccessibilityCardsNextSettlementButton.icnArrowRight
    }
    
    func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.emptySettlementButtonTapped()
    }
}
