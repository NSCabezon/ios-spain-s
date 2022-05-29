//
//  CardSubscriptionDetailHistoricView.swift
//  Cards
//
//  Created by Ignacio González Miró on 15/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol DidTapInHistoricSeeMorePaymentsDelegate: AnyObject {
    func didTapInSeeMorePayments(_ isOpen: Bool)
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel)
}

public final class CardSubscriptionDetailHistoricView: XibView {
    @IBOutlet private weak var historicTitleLabel: UILabel!
    @IBOutlet private weak var historicStackView: UIStackView!
    @IBOutlet private weak var baseStackView: UIView!
    
    weak var delegate: DidTapInHistoricSeeMorePaymentsDelegate?
    var isOpenSeeMoreView: Bool?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool) {
        self.isOpenSeeMoreView = isOpen
        historicTitleLabel.text = localized("m4m_label_payHistory")
        removeArrangedSubviewsIfNeeded()
        updateHistoricPillsIfNeeded(viewModels, isOpen: isOpen)
    }
}

private extension CardSubscriptionDetailHistoricView {
    // MARK: Setup
    func setupView() {
        backgroundColor = .white
        setTitleLabel()
        setHistoricContentView()
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        let font = UIFont.santander(family: .text, type: .bold, size: 16)
        let configuration = LocalizedStylableTextConfiguration(font: font, alignment: .left, lineHeightMultiple: 0.75, lineBreakMode: .byTruncatingTail)
        historicTitleLabel.configureText(withKey: localized("m4m_label_payHistory"), andConfiguration: configuration)
        historicTitleLabel.textColor = .lisboaGray
    }
    
    func setHistoricContentView() {
        baseStackView.layer.masksToBounds = true
        baseStackView.drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        baseStackView.drawShadow(offset: 1, opaticity: 0.8, color: .lightSanGray, radius: 3)
        baseStackView.backgroundColor = .white
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicBaseView
        historicTitleLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicTitleLabel
        baseStackView.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicStackView
    }
    
    // MARK: ConfigView
    func removeArrangedSubviewsIfNeeded() {
        if !self.historicStackView.arrangedSubviews.isEmpty {
            self.historicStackView.removeAllArrangedSubviews()
        }
    }
    
    func updateHistoricPillsIfNeeded(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool) {
        removeArrangedSubviewsIfNeeded()
        guard !viewModels.isEmpty else {
            addSingleEmptyView()
            return
        }
        configureHistoricPills(viewModels, isOpen: isOpen)
    }
    
    func addSingleEmptyView() {
        let view = SingleEmptyView()
        view.centerView()
        view.titleFont(.santander(family: .headline, type: .regular, size: 18), color: .brownishGray)
        view.updateTitle(localized("generic_label_emptyError"))
        view.heightAnchor.constraint(equalToConstant: 193).isActive = true
        self.historicStackView.addArrangedSubview(view)
    }

    func addHistoricPill(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        let view = CardSubscriptionDetailHistoricStackPillView()
        view.delegate = self
        view.configView(viewModel)
        historicStackView.addArrangedSubview(view)
    }
    
    func addSeparatorView() {
        let view = UIView()
        view.backgroundColor = .mediumSkyGray
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        historicStackView.addArrangedSubview(view)
    }
    
    func addShowMoreView(_ text: String, isOpen: Bool) {
        let view = ShowCompletedMovementsView()
        let stylableText = LocalizedStylableText(text: text, styles: nil)
        view.setTitle(stylableText)
        view.isOpen(isOpen)
        addTapGestureInShowMoreView(view)
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        historicStackView.addArrangedSubview(view)
    }
    
    // MARK: View Configuration
    func configureHistoricPills(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool) {
        if viewModels.count <= 3 {
            setSmallList(viewModels)
        } else {
            setHistoricPills(viewModels, isOpen: isOpen)
        }
    }
    
    func setSmallList(_ viewModels: [CardSubscriptionDetailHistoricViewModel]) {
        viewModels.forEach { (viewModel) in
            addHistoricPill(viewModel)
        }
    }
    
    func setHistoricPills(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool) {
        viewModels.enumerated().forEach { (index, viewModel) in
            if !isOpen, index > 2 {
                return
            }
            addHistoricPill(viewModel)
            addSeparatorView()
        }
        addShowMoreView(localized("m4m_button_seeMorePay"), isOpen: isOpen)
    }

    // MARK: TapGesture
    func addTapGestureInShowMoreView(_ view: ShowCompletedMovementsView) {
        if let gestureRecognizers = view.gestureRecognizers, !gestureRecognizers.isEmpty {
            view.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInSeeMoreView))
        view.addGestureRecognizer(tap)
    }
    
    @objc func didTapInSeeMoreView() {
        guard let isOpen = self.isOpenSeeMoreView else {
            return
        }
        delegate?.didTapInSeeMorePayments(isOpen)
    }
}

extension CardSubscriptionDetailHistoricView: CardSubscriptionDetailHistoricStackPillViewDelegate {
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
}
