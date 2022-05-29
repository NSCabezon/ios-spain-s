//
//  ConfigureYourGPView.swift
//  GlobalPosition
//
//  Created by alvola on 31/03/2020.
//

import UI
import CoreFoundationLib
import UIKit

protocol ConfigureYourGPViewDelegate: AnyObject {
    func didPressConfigureGP()
}

final class ConfigureYourGPView: DesignableView {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ConfigureYourGPViewDelegate?
    
    // MARK: - privateMethods
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabels()
        iconImage?.image = Assets.image(named: "icnConfigPg")
        setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        backgroundColor = UIColor.lightGray40
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewDidPress)))
    }
    
    private func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, size: 14.0)
        titleLabel?.textColor = UIColor.darkTorquoise
        titleLabel?.text = localized("pg_link_setPg")
    }
    
    @objc private func viewDidPress() {
        self.blockingAction {
            delegate?.didPressConfigureGP()
        }
    }
    
    private func setAccessibilityIdentifiers() {
        iconImage.isAccessibilityElement = true
        titleLabel.accessibilityIdentifier = "configurePG_titleLabel"
        iconImage.accessibilityIdentifier = "configureIcn"
        setAccessibility { self.iconImage.isAccessibilityElement = false }
    }
}

extension ConfigureYourGPView: AccessibilityCapable { }
