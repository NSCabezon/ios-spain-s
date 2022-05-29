//
//  BankConfigDetailFooterView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 15/7/21.
//

import UI
import CoreFoundationLib

protocol BankConfigDetailFooterDelegate: AnyObject {
    func didPressSaveChanges()
}

final class BankConfigDetailFooterView: XibView {
    @IBOutlet private weak var saveChangesButton: RedLisboaButton!
    weak var delegate: BankConfigDetailFooterDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension BankConfigDetailFooterView {
    func setupView() {
        self.saveChangesButton.set(localizedStylableText: localized("displayOptions_button_saveChanges"), state: .normal)
        self.saveChangesButton.addSelectorAction(target: self, #selector(didPressSaveChanges))
        self.saveChangesButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @objc func didPressSaveChanges() {
        self.delegate?.didPressSaveChanges()
    }
}
