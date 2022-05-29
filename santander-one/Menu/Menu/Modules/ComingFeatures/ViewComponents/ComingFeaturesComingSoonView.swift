//
//  ComingFeaturesComingSoonView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 20/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ComingFeaturesComingSoonViewDelegate: AnyObject {
    func didSelectTryFeatures()
}

class ComingFeaturesComingSoonView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var shortlyLabel: UILabel!
    @IBOutlet weak var helpUsLabel: UILabel!
    @IBOutlet weak var tryFeaturesButton: UIButton!
    @IBOutlet weak var tryFeaturesView: UIView!
    @IBOutlet weak var shortlyNewButtonLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    weak var delegate: ComingFeaturesComingSoonViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.lightSky
        self.logoImageView.image = Assets.image(named: "imgComingSoon")
        self.configStyle(to: self.shortlyLabel, keyText: localized("shortly_text_help"), fontType: .regular)
        self.configStyle(to: self.helpUsLabel, keyText: localized("shortly_text_helpUs"), fontType: .bold)
        self.setupButton()
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setAccessibilityIdentifiers()
    }
    
    private func configStyle(to label: UILabel, keyText: String, fontType: FontType) {
        label.textColor = .lisboaGray
        label.text = localized(keyText)
        label.font = .santander(family: .text, type: fontType, size: 16)
    }
    
    private func setupButton() {
        self.tryFeaturesButton.backgroundColor = .clear
        self.tryFeaturesView.backgroundColor = .darkTorquoise
        self.tryFeaturesView.drawBorder(cornerRadius: 5, color: .darkTorquoise, width: 1)
        self.shortlyNewButtonLabel.textAlignment = .center
        self.shortlyNewButtonLabel.textColor = .white
        self.shortlyNewButtonLabel.text = localized("shortly_button_news")
        self.shortlyNewButtonLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.arrowImageView.image = Assets.image(named: "icnArrowRightWhite")
    }
    
    private func setAccessibilityIdentifiers() {
        self.logoImageView.accessibilityIdentifier = "imgComingSoon"
        self.shortlyLabel.accessibilityIdentifier = "shortly_text_help"
        self.helpUsLabel.accessibilityIdentifier = "shortly_text_helpUs"
        self.tryFeaturesButton.accessibilityIdentifier = "btnNews"
    }
    
    @IBAction func tryFeaturesButtonPressed(_ sender: Any) {
        self.delegate?.didSelectTryFeatures()
    }
}
