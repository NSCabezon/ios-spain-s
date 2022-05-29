//
//  EmptyCardsFinanceableView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 25/06/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol EmptyCardsFinanceableViewDelegate: AnyObject {
    func didSelectHireCard(_ location: PullOfferLocation?)
}

class EmptyCardsFinanceableView: XibView {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hireCardButton: WhiteLisboaButton!
    @IBOutlet weak var offerButtonContainer: UIView!
    
    weak var delegate: EmptyCardsFinanceableViewDelegate?
    private var viewModel: EmptyCardsFinanceableViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: EmptyCardsFinanceableViewModel) {
        self.viewModel = viewModel
        self.offerButtonContainer.isHidden = viewModel.isOfferButtonHidden
    }
}

private extension EmptyCardsFinanceableView {
    func setAppearance() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.cardImageView.image = Assets.image(named: "icnCardOperations")
        self.setLabels()
        self.setButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabels() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "financing_title_notYet",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.text = localized("financing_text_notYet")
    }
    
    func setButton() {
        self.hireCardButton.addSelectorAction(target: self, #selector(self.hireCardButtonPressed))
        self.hireCardButton.setTitle(localized("financing_button_interested"), for: .normal)
        self.hireCardButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        self.hireCardButton.contentInsets = UIEdgeInsets(top: 0, left: 14, bottom: 2, right: 14)
    }
    
    @objc func hireCardButtonPressed() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectHireCard(viewModel.location)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = "financing_title_notYet"
        self.descriptionLabel.accessibilityIdentifier = "financing_text_notYet"
        self.cardImageView.accessibilityIdentifier = "icnCardOperations"
        self.hireCardButton.accessibilityIdentifier = "financing_button_interested"
    }
}
