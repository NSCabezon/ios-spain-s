//
//  DirectDebitView.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 03/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol DirectDebitViewDelegate: AnyObject {
    func didSelectDirectDebit()
    func didSelectOpenUrl(with url: String)
}

class DirectDebitView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: DirectDebitViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModels(_ viewModels: [DirectDebitActionViewModel]) {
        viewModels.forEach { viewModel in
            let directDebitActionView = DirectDebitActionView()
            directDebitActionView.setViewModel(viewModel)
            directDebitActionView.delegate = self
            self.stackView.addArrangedSubview(directDebitActionView)
        }
    }
}

private extension DirectDebitView {
    func setAppearance() {
        self.titleLabel.text = localized("receiptsAndTaxes_title_domicileOptions")
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_title_domicileOptions"
    }
}

extension DirectDebitView: DirectDebitActionDelegate {
    func didSelectDirectDebit() {
        self.delegate?.didSelectDirectDebit()
    }
    
    func didSelectOpenUrl(with url: String) {
        self.delegate?.didSelectOpenUrl(with: url)
    }
}
