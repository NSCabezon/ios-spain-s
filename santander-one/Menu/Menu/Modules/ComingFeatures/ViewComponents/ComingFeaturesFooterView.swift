//
//  ComingFeaturesFooterView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 20/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ComingFeaturesFooterViewDelegate: AnyObject {
    func didSelectNewFeature()
}

class ComingFeaturesFooterView: XibView {
    @IBOutlet weak var newFeatureButton: WhiteLisboaButton!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: ComingFeaturesFooterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        self.newFeatureButton.setTitle(localized("shortly_button_add"), for: .normal)
        self.newFeatureButton.addSelectorAction(target: self, #selector(didSelectNewFeature))
        self.drawShadowTop(offset: -2, opaticity: 0.2, color: .lisboaGray, radius: 1)
        self.newFeatureButton.accessibilityIdentifier = "btnAddIdea"
    }
    
    private func drawShadowTop(offset: CGFloat = 3.0, opaticity: Float = 1.0, color: UIColor, radius: CGFloat = 0.0) {
        self.layer.shadowOffset = CGSize(width: 0, height: offset)
        self.layer.shadowOpacity = opaticity
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
    }
    
    @objc private func didSelectNewFeature() {
        self.delegate?.didSelectNewFeature()
    }
}
