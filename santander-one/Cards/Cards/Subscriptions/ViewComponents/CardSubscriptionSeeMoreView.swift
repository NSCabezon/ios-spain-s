//
//  CardSubscriptionSeeMoreView.swift
//  Cards
//
//  Created by Ignacio González Miró on 9/4/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidTapInSeeMoreViewDelegate: AnyObject {
    func didTapInSeeMoreView()
}

public final class CardSubscriptionSeeMoreView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailImage: UIImageView!
    
    weak var delegate: DidTapInSeeMoreViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ type: CardSubscriptionSeeMoreType) {
        let text = configText(type)
        titleLabel.text = text
        detailImage.image = Assets.image(named: "icnArrowRightBlack")
    }
}

private extension CardSubscriptionSeeMoreView {
    func setupView() {
        backgroundColor = .clear
        setTitle()
        addTapGesture()
        setAccessibiliyIds()
    }
    
    func setTitle() {
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        titleLabel.textColor = .darkTorquoise
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .right
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setAccessibiliyIds() {
        accessibilityIdentifier = AccessibilityCardSubscription.seeMoreBaseView
        titleLabel.accessibilityIdentifier = AccessibilityCardSubscription.seeMoreTitleLabel
        detailImage.accessibilityIdentifier = AccessibilityCardSubscription.seeMoreImageView
    }
    
    func configText(_ type: CardSubscriptionSeeMoreType) -> String {
        var text = ""
        switch type {
        case .payments:
            text = localized("m4m_button_seeMorePay")
        case .historic:
            text = localized("m4m_button_seePayHistory")
        }
        return text
    }
    
    func addTapGesture() {
        if let gestureRecognizers = gestureRecognizers, !gestureRecognizers.isEmpty {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInSeeMoreView))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInSeeMoreView() {
        delegate?.didTapInSeeMoreView()
    }
}
