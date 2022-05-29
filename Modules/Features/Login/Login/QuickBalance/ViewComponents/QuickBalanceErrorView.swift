//
//  QuickBalanceErrorView.swift
//  Login
//
//  Created by Iván Estévez on 03/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol QuickBalanceErrorViewDelegate: AnyObject {
    func didTapButton()
}

final class QuickBalanceErrorView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var button: RedLisboaButton!
    
    weak var delegate: QuickBalanceErrorViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setViewModel(_ viewModel: QuickBalanceErrorViewModel) {
        titleLabel.isHidden = viewModel.errorTitle.isEmpty && viewModel.stylableErrorTitle == nil
        if let stylableErrorTitle = viewModel.stylableErrorTitle {
            titleLabel.set(localizedStylableText: stylableErrorTitle)
        } else {
            titleLabel.text = viewModel.errorTitle
        }
        descriptionLabel.text = viewModel.errorDescription
        button.setTitle(viewModel.titleButton, for: .normal)
        self.button.accessibilityIdentifier = AccessibilityQuickBalance.btnEnter.rawValue
    }
}

private extension QuickBalanceErrorView {
    func setupView() {
        titleLabel.font = .santander(family: .text, type: .regular, size: 20)
        titleLabel.textColor = .lisboaGray
        descriptionLabel.font = .santander(family: .text, type: .regular, size: 14)
        descriptionLabel.textColor = .lisboaGray
        button.addAction { [weak self] in
            self?.delegate?.didTapButton()
        }
    }
}
