//
//  OneSeeAllCardView.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 15/9/21.
//

import UI
import CoreFoundationLib

public protocol OneSeeAllCardViewDelegate: AnyObject {
    func didSelectOneSeeAllCard()
}

public final class OneSeeAllCardView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var seeAllLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    public weak var delegate: OneSeeAllCardViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: OneSeeAllCardViewModel) {
        self.seeAllLabel.text = localized(viewModel.descriptionKey)
        self.iconImageView.image = Assets.image(named: viewModel.imageKey)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    @IBAction private func didSelectOneSeeAllCard(_ sender: UIButton) {
        self.delegate?.didSelectOneSeeAllCard()
    }
}

private extension OneSeeAllCardView {
    func setupView() {
        self.view?.backgroundColor = .clear
        self.setLabel()
        self.setContainerView()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabel() {
        self.seeAllLabel.font = .typography(fontName: .oneB300Bold)
        self.seeAllLabel.textColor = .oneWhite
        self.seeAllLabel.numberOfLines = 3
    }
    
    func setContainerView() {
        self.containerView.backgroundColor = .oneDarkTurquoise
        self.containerView.setOneCornerRadius(type: .oneShRadius8)
        self.containerView.setOneShadows(type: .oneShadowLarge)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneSeeAllCardView + (suffix ?? "")
        self.seeAllLabel.accessibilityIdentifier = AccessibilityOneComponents.oneSeeAllCardTitle + (suffix ?? "")
        self.iconImageView.accessibilityIdentifier = AccessibilityOneComponents.oneSeeAllCardImg + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.seeAllLabel.isAccessibilityElement = false
    }
}

extension OneSeeAllCardView: AccessibilityCapable {}
