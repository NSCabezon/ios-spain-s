//
//  MapButtonView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/4/19.
//

import Foundation
import UI
import CoreFoundationLib

protocol MapButtonViewProtocol: AnyObject {
    func mapButtonTapped()
}

class MapButtonView: BaseInformationButton {
    weak var delegate: MapButtonViewProtocol?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.descriptionLabel.configureText(withKey: "generic_button_map")
        self.mapImageView.image = Assets.image(named: "imgPurchaseModule")
        self.setAccessibility(setViewAccessibility: setAccessibility)
        self.setAccessibilityIdentifiers()
    }
    
    private func setAccessibility() {
        self.isAccessibilityElement = true
    }

    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "cardsHomeBtnMap"
        self.descriptionLabel.accessibilityIdentifier = "genetic_button_map_label"
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.mapButtonTapped()
    }
}

extension MapButtonView: AccessibilityCapable { }
