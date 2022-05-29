//
//  SearchAtmView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 01/09/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol SearchAtmViewDelegate: AnyObject {
    func didSelectedSearchAtm()
}

final class SearchAtmView: XibView {
    
    weak var delegate: SearchAtmViewDelegate?
    @IBOutlet weak var lisboaTextFieldView: LisboaTextFieldWithErrorView!
    @IBOutlet weak var searchButton: UIButton!
    
    public var textField: LisboaTextField {
        return lisboaTextFieldView.textField
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
     
    @IBAction func didTapOnSearch(_ sender: Any) {
        self.delegate?.didSelectedSearchAtm()
    }
}

private extension SearchAtmView {
    func setupView() {
        let configuration = LisboaTextField.ActionableTextField(type: .simple) {
            self.delegate?.didSelectedSearchAtm()
        }
        self.lisboaTextFieldView.textField.setEditingStyle(.actionable(configuration: configuration))
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textField.setRightAccessory(.image("icnSearch", action: { self.didTapOnSearch(self) }))
        self.textField.setText(localized("atm_hint_searchAtm"))
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.lisboaTextFieldView.textField.accessibilityIdentifier = AccessibilityAtm.atmInputSearch.rawValue
    }
}
