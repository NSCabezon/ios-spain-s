//
//  FractionedPaymentSectionView.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 23/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol FractionedPaymentSectionDelegate: AnyObject {
    func didSelectAccounts()
    func didSelectCards()
}

final class FractionedPaymentSectionView: DesignableView {

    @IBOutlet private weak var accountsFractionedPaymentView: FractionedPaymentView!
    @IBOutlet private weak var cardsFractionedPaymentView: FractionedPaymentView!
    
    weak var delegate: FractionedPaymentSectionDelegate?
    private var numberOfCards = 0
    private var numberOfAccounts = 0
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func configCardSection(_ numberOfCards: Int, _ totalAmount: NSAttributedString) {
        self.numberOfCards = numberOfCards
        let localizedDescriptionKey = numberOfCards == 1
            ? "whatsNew_label_payments_one"
            : "whatsNew_label_payments_other"
        let description: LocalizedStylableText = localized(localizedDescriptionKey, [
            StringPlaceholder(.value, totalAmount.string),
            StringPlaceholder(.number, String(numberOfCards))
        ])
        self.cardsFractionedPaymentView.configSection(image: Assets.image(named: "icnCardOperations1"),
                                                      title: localized("whatsNew_label_cards"),
                                                      description: description)
    }
    
    func configAccountSection(_ numberOfAccounts: Int, _ totalAmount: NSAttributedString) {
        self.numberOfAccounts = numberOfAccounts
        let localizedDescriptionKey = numberOfAccounts == 1
            ? "whatsNew_label_payments_one"
            : "whatsNew_label_payments_other"
        let description: LocalizedStylableText = localized(localizedDescriptionKey, [
            StringPlaceholder(.value, totalAmount.string),
            StringPlaceholder(.number, String(numberOfAccounts))
        ])
        self.accountsFractionedPaymentView.configSection(image: Assets.image(named: "icnEuroMoney"),
                                                         title: localized("whatsNew_label_accounts"),
                                                         description: description)
    }
}

private extension FractionedPaymentSectionView {
    func setupView() {
        let accountsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInAccounts))
        self.accountsFractionedPaymentView.addGestureRecognizer(accountsTapGesture)
        let cardsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInCards))
        self.cardsFractionedPaymentView.addGestureRecognizer(cardsTapGesture)
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
    @objc func didTapInAccounts() {
        if self.numberOfAccounts > 0 {
            delegate?.didSelectAccounts()
        }
    }
    
    @objc func didTapInCards() {
        if self.numberOfCards > 0 {
            delegate?.didSelectCards()
        }
    }
}
