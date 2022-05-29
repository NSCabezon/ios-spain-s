//
//  CardSubscriptionPurchaseImageView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionPurchaseImageView: XibView {
    
    @IBOutlet private weak var imageStack: UIStackView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        removeArrangedSubviewsIfNeeded()
        handleImageViewIfNeeded(viewModel)
    }
}

private extension CardSubscriptionPurchaseImageView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !imageStack.arrangedSubviews.isEmpty {
            imageStack.removeAllArrangedSubviews()
        }
    }
    
    // MARK: configViews
    func handleImageViewIfNeeded(_ viewModel: CardSubscriptionViewModel) {
        guard let imageUrl = viewModel.corpImageURL else {
            addInitialsView(viewModel)
            return
        }
        let image = UIImageView()
        image.loadImage(urlString: imageUrl) { [weak self] in
            guard image.image == nil else {
                self?.addInitialsView(viewModel)
                return
            }
        }
        if image.image == nil {
            addInitialsView(viewModel)
        }
        image.accessibilityIdentifier = AccessibilityCardSubscription.purchaseImageUrlImageView
        imageStack.addArrangedSubview(image)
    }
    
    func addInitialsView(_ viewModel: CardSubscriptionViewModel) {
        let view = UIView(frame: self.frame)
        view.backgroundColor = viewModel.logoColor
        view.layer.cornerRadius = view.frame.size.height / 2
        view.accessibilityIdentifier = AccessibilityCardSubscription.purchaseImageCircleView
        let label = UILabel(frame: CGRect(origin: .zero, size: view.frame.size))
        label.text = viewModel.initials
        label.textAlignment = .center
        label.textColor = .white
        label.font = .santander(family: .text, type: .bold, size: 15)
        label.accessibilityIdentifier = AccessibilityCardSubscription.purchaseImageInitialsLabel
        view.addSubview(label)
        imageStack.addArrangedSubview(view)
    }
}
