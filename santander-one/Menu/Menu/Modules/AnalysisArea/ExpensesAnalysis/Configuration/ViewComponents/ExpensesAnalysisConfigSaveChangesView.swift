//
//  ExpensesAnalysisConfigSaveChangesView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 8/7/21.
//

import UI
import CoreFoundationLib

protocol ExpensesAnalysisConfigSaveChangesDelegate: AnyObject {
    func didPressSaveChanges()
}

final class ExpensesAnalysisConfigSaveChangesView: XibView {
    @IBOutlet private weak var saveChangesButton: RedLisboaButton!
    weak var delegate: ExpensesAnalysisConfigSaveChangesDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension ExpensesAnalysisConfigSaveChangesView {
    func setupView() {
        self.saveChangesButton.set(localizedStylableText: localized("displayOptions_button_saveChanges"), state: .normal)
        self.saveChangesButton.addSelectorAction(target: self, #selector(didPressSaveChanges))
        self.saveChangesButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @objc func didPressSaveChanges() {
        self.delegate?.didPressSaveChanges()
    }
}
