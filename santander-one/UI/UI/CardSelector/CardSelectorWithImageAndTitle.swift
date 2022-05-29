//
//  CardSelectorWithImageAndTitle.swift
//  UI
//
//  Created by Ignacio González Miró on 19/10/2020.
//

import UIKit
import CoreFoundationLib

public protocol DidTapInCardPickerSelectorDelegate: AnyObject {
    func didTapInSelector(_ isCollapsed: Bool)
}

public final class CardSelectorWithImageAndTitle: UIDesignableView {
    @IBOutlet private weak var cardSelectorView: UIView!
    @IBOutlet private weak var selectorImage: UIImageView!
    @IBOutlet private weak var selectorLabel: UILabel!
    @IBOutlet private weak var selectorNumberLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var collapsedImage: UIImageView!
    @IBOutlet private weak var separatorPickerView: UIView!
    @IBOutlet private weak var separatorToBottomConstraint: NSLayoutConstraint!
    
    weak public var delegate: DidTapInCardPickerSelectorDelegate?
    private var isCollapsed: Bool = true
    
    override public func getBundleName() -> String {
        return "UI"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    public func configCardSelector(_ ownerCard: OwnerCards, numberOfCards: String, isCollapsed: Bool) {
        self.selectorImage.loadImage(urlString: ownerCard.urlString, placeholder: Assets.image(named: "defaultCard"))
        self.selectorLabel.text = ownerCard.text
        let numberLabel = localized("nextSettlement_label_titularCardPosition", [StringPlaceholder(.number, ownerCard.position.description), StringPlaceholder(.number, numberOfCards)])
        self.selectorNumberLabel.configureText(withLocalizedString: numberLabel)
        self.selectorNumberLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.isCollapsed = isCollapsed
        self.updateCollapsedArrow()
        self.updateSeparatorColor()
    }
    
    public func updateSeparatorColor() {
        self.separatorPickerView.backgroundColor = isCollapsed ? .clear : .darkTorquoise
    }
    
    public func getBottomHeight() -> CGFloat {
        return self.separatorToBottomConstraint.constant
    }
}

private extension CardSelectorWithImageAndTitle {
    func setupView() {
        self.setAccessibilityIds()
        self.setSelectorView()
        self.addTapGesture()
        self.heightAnchor.constraint(equalToConstant: 84.0).isActive = true
    }
    
    func setSelectorView() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.cardSelectorView.backgroundColor = .veryLightGray
        self.cardSelectorView.layer.cornerRadius = 5
        self.selectorLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        self.selectorNumberLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInSelector))
        self.cardSelectorView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapInSelector() {
        let updatedIsCollapsed = !isCollapsed
        self.isCollapsed = updatedIsCollapsed
        self.updateCollapsedArrow()
        delegate?.didTapInSelector(updatedIsCollapsed)
    }
    
    func updateCollapsedArrow() {
        let collapsedImageNamed = isCollapsed ? "icnArrowDown" : "icnArrowUp"
        self.collapsedImage.image = Assets.image(named: collapsedImageNamed)?.withRenderingMode(.alwaysTemplate)
        self.collapsedImage.tintColor = .darkTorquoise
    }
    
    func setAccessibilityIds() {
        let collapsedImageIdentifier = isCollapsed ? AccessibilityPickerWithImageAndTitle.collapsedArrow.rawValue : AccessibilityPickerWithImageAndTitle.noCollapsedArrow.rawValue
        self.collapsedImage.accessibilityIdentifier = collapsedImageIdentifier
        self.selectorImage.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.cardImage.rawValue
        self.selectorLabel.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.pickerTitle.rawValue
        self.cardSelectorView.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.baseView.rawValue
    }
}
