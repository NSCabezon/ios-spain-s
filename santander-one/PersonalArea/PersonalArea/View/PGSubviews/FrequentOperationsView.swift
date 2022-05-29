//
//  FrequentOperationsView.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 28/11/2019.
//

import Foundation
import CoreFoundationLib
import UI

protocol FrequentOperationsViewDelegate: AnyObject {
    func frequentOperationsViewDidPressed()
}

class FrequentOperationsView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private var separationViews: [UIView]?
    @IBOutlet private weak var operativeView: UIImageView?
    @IBOutlet private weak var arrowLabel: UILabel?
    @IBOutlet private weak var arrowImageView: UIImageView?
    @IBOutlet private weak var navigationView: UIView?
    weak var frequentOperationsViewDelegate: FrequentOperationsViewDelegate?

    override func internalInit() {
        super.internalInit()
        self.commonInit()
    }
    
    func setDelegate(_ delegate: FrequentOperationsViewDelegate?) {
        self.frequentOperationsViewDelegate = delegate
    }
}

private extension FrequentOperationsView {
    func commonInit() {
        self.configureLabels()
        self.configureViews()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.setTitleLabel()
        self.setArrowLabel()

    }
    
    func setTitleLabel() {
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.textAlignment = .left
        self.titleLabel?.configureText(withKey: "personalArea_label_frequentOperative",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                                       alignment: .left,
                                                                                       lineHeightMultiple: 0.8))
    }
    
    func setArrowLabel() {
        self.arrowLabel?.textColor = .lisboaGray
        self.arrowLabel?.configureText(withKey: "pgCustomize_label_directAccess",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                       alignment: .left))
    }
    
    func configureViews() {
        self.backgroundColor = .white
        self.separationViews?.forEach { $0.backgroundColor = .mediumSkyGray }
        self.arrowImageView?.image = Assets.image(named: "icnArrowRight")
        self.navigationView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        self.navigationView?.isUserInteractionEnabled = true
        self.operativeView?.image = Assets.image(named: "imgFrequentOperative")
    }
    
    @objc private func goToDidPressed() {
        self.frequentOperationsViewDelegate?.frequentOperationsViewDidPressed()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.frequentOperationsTitle
        self.arrowLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.frequentOperationsArrow
        self.arrowImageView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.frequentOperationsArrowImage
        self.operativeView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.frequentOperationOperativeView
    }
}
