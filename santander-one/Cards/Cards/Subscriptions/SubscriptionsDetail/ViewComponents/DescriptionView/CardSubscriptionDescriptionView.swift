//
//  CardSubscriptionDescriptionView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol DidTapInCardSubscriptionDescriptionDelegate: AnyObject {
    func didTapInSubscriptionSwitch(_ isOn: Bool)
}

public final class CardSubscriptionDescriptionView: XibView {
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var descriptionHeader: CardSubscriptionDetailHeaderView!
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var descriptionStack: UIStackView!

    weak var delegate: DidTapInCardSubscriptionDescriptionDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        removeDescriptionStackIfNeeded()
        addHeaderView(viewModel)
        addDateView(viewModel)
        addDottedSeparatorView()
        addCardDetailView(viewModel)
        addSubscriptionPaymentView(viewModel)
    }
}

private extension CardSubscriptionDescriptionView {
    // MARK: init View
    func setupView() {
        descriptionStack.backgroundColor = .clear
        backgroundColor = .white
        topSeparatorView.backgroundColor = .lightSkyBlue
        setDescriptionContentView()
        setAccessibilityIds()
    }
    
    func setDescriptionContentView() {
        descriptionView.layer.masksToBounds = true
        descriptionView.drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        descriptionView.drawShadow(offset: 1, opaticity: 0.8, color: .lightSanGray, radius: 3)
        descriptionView.backgroundColor = .white
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailBaseView
        descriptionView.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailContentView
    }
    
    // MARK: Config ContentView
    func addHeaderView(_ viewModel: CardSubscriptionViewModel) {
        descriptionHeader.heightAnchor.constraint(equalToConstant: 84).isActive = true
        descriptionHeader.configView(viewModel)
    }
    
    func addDateView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionDateView()
        view.configView(viewModel)
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        descriptionStack.addArrangedSubview(view)
    }
    
    func addCardDetailView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionCardDetailView()
        view.configView(viewModel)
        view.heightAnchor.constraint(equalToConstant: 62).isActive = true
        descriptionStack.addArrangedSubview(view)
    }
    
    func addSubscriptionPaymentView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionPaymentView()
        view.delegate = self
        view.configView(viewModel)
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        descriptionStack.addArrangedSubview(view)
    }
    
    func addDottedSeparatorView() {
        let view = CardSubscriptionDetailSeparatorDottedView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        descriptionStack.addArrangedSubview(view)
    }
    
    func removeDescriptionStackIfNeeded() {
        if !self.descriptionStack.arrangedSubviews.isEmpty {
            self.descriptionStack.removeAllArrangedSubviews()
        }
    }
}

extension CardSubscriptionDescriptionView: DidTapInCardSubscriptionPaymentDelegate {
    public func didTapInSubscriptionSwitch(_ isOn: Bool) {
        delegate?.didTapInSubscriptionSwitch(isOn)
    }
}
