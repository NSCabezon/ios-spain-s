//
//  LastMovementsFooterView.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol LastMovementsFooterDelegate: AnyObject {
    func didTapInSeeMoreMovements()
}

class LastMovementsFooterView: DesignableView {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var seeMoreMovementsView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImage: UIImageView!
    
    weak var delegate: LastMovementsFooterDelegate?
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func config(_ title: LocalizedStylableText) {
        let arrowImg = Assets.image(named: "icnArrowRedRight")
        self.arrowImage.image = arrowImg
        self.titleLabel.configureText(withLocalizedString: title)
    }
}

private extension LastMovementsFooterView {
    func setupView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapInSeeMoreMovements))
        self.addGestureRecognizer(gesture)
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.setAppearance()
        self.setIdentifiers()
    }
    
    @objc func didTapInSeeMoreMovements() {
        delegate?.didTapInSeeMoreMovements()
    }
    
    func setAppearance() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = .santanderRed
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setIdentifiers() {
        self.seeMoreMovementsView.accessibilityIdentifier = AccesibilityLastMovementsList.seeMoreFooter
        self.titleLabel.accessibilityIdentifier = AccesibilityLastMovementsList.titleFooter
        self.arrowImage.accessibilityIdentifier = AccesibilityLastMovementsList.arrowFooter
    }
}
