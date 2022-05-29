//
//  ProductsView.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 28/11/2019.
//

import Foundation
import CoreFoundationLib
import UI

protocol ProductsViewDelegate: AnyObject {
    func productsViewDidPressed()
}

class ProductsView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet var separationViews: [UIView]?
    @IBOutlet private weak var orderView: UIImageView?
    @IBOutlet private weak var arrowLabel: UILabel?
    @IBOutlet private weak var arrowImageView: UIImageView?
    @IBOutlet private weak var navigationView: UIView?
    weak var productsViewDelegate: ProductsViewDelegate?

    override func internalInit() {
        super.internalInit()
        self.commonInit()
    }
        
    func setDelegate(_ delegate: ProductsViewDelegate?) {
        self.productsViewDelegate = delegate
    }
}

private extension ProductsView {
    func commonInit() {
        self.configureLabels()
        self.configureViews()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.setTitleLabel()
        self.setSubTitleLabel()
        self.setArrowLabel()
    }
    
    func setTitleLabel() {
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: "pgCustomize_label_products",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                                       alignment: .left,
                                                                                       lineHeightMultiple: 0.8))
    }
    
    func setSubTitleLabel() {
        self.subtitleLabel?.textColor = .lisboaGray
        self.subtitleLabel?.configureText(withKey: "displayOptions_text_seeOrder",
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 14),
                                                                                          alignment: .left,
                                                                                          lineHeightMultiple: 0.82))
        self.subtitleLabel?.numberOfLines = 0
    }
    
    func setArrowLabel() {
        self.arrowLabel?.textColor = .lisboaGray
        self.arrowLabel?.configureText(withKey: "pgCustomize_label_orderAndChange",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                       alignment: .left))
    }
    
    func configureViews() {
        self.backgroundColor = .white
        self.separationViews?.forEach { $0.backgroundColor = .mediumSkyGray }
        self.arrowImageView?.image = Assets.image(named: "icnArrowRight")
        self.navigationView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        self.navigationView?.isUserInteractionEnabled = true
        self.orderView?.image = Assets.image(named: "imgOrderOption")
    }
    
    @objc private func goToDidPressed() {
        self.productsViewDelegate?.productsViewDidPressed()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.productsViewTitle
        self.subtitleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.productsViewSubTitle
        self.arrowLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.productsViewArrow
        self.arrowImageView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.productOrderArrowImage
        self.orderView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.productsViewOrderView
    }
}
