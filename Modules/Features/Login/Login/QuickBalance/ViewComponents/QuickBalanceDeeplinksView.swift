//
//  QuickBalanceDeeplinksView.swift
//  Login
//
//  Created by Iván Estévez on 06/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol QuickBalanceDeeplinksViewDelegate: AnyObject {
    func didTapButtonWithAction(_ action: QuickBalanceAction)
}

final class QuickBalanceDeeplinksView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: QuickBalanceDeeplinksViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViewModel(_ viewModel: QuickBalanceDeeplinksViewModel) {
        viewModel.buttons.forEach { (element) in
            let actionButton = ActionButton()
            actionButton.setAppearance(withStyle: .defaultStyleWithGrayBackground)
            actionButton.setViewModel(element)
            actionButton.addSelectorAction(target: self, #selector(buttonDidPressed(_:)))
            actionButton.accessibilityIdentifier = element.action.accessibilityIdentifier
            stackView.addArrangedSubview(actionButton)
        }
    }
}

private extension QuickBalanceDeeplinksView {
    @objc func buttonDidPressed(_ gesture: UIGestureRecognizer) {
        guard
            let button = gesture.view as? ActionButton,
            let model = button.getViewModel() as? QuickBalanceDeeplinkButtonModel
            else { return }
        delegate?.didTapButtonWithAction(model.action)
    }
}
