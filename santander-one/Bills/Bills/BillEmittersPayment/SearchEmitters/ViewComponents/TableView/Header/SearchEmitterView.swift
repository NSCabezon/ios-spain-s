//
//  SearchEmitterView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/21/20.
//

import Foundation
import UI
import CoreFoundationLib

enum SearchTermError: Error {
    case invalidSearchCodeLength
}

protocol SearchEmitterViewDelegate: AnyObject {
    func didSelectSeardch(term: String)
    func didSelectClear()
}

final class SearchEmitterView: XibView {
    @IBOutlet weak var searchTextField: WithoutTitleLisboaTextField!
    @IBOutlet weak var errorLabel: UILabel!
    private weak var delegate: SearchEmitterViewDelegate?
    private var style = LisboaTextFieldStyle.default
    
    lazy var clearEmage: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: Assets.image(named: "clearField"))
        view.addSubview(imageView)
        view.widthAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clear))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDelegate(_ delegate: SearchEmitterViewDelegate) {
        self.delegate = delegate
    }
    
    @objc func clear() {
        self.searchTextField.field.text = nil
        self.clearInvalidSearchError()
        self.clearEmage.removeFromSuperview()
        self.searchTextField.resignFirstResponder()
        self.delegate?.didSelectClear()
    }
    
    func setAllowOnlyAlphanumerics() {
        self.searchTextField.setAllowOnlyCharacters(.operative)
        self.searchTextField.field.keyboardType = .default
        self.searchTextField.field.returnKeyType = .search
    }
    
    func setAllowOnlySevenDigits() {
        self.searchTextField.setMaxCharacters(7)
        self.searchTextField.setAllowOnlyCharacters(.numbers)
        self.searchTextField.field.keyboardType = .numberPad
        self.searchTextField.field.returnKeyType = .search
    }
    
    func didChangeSearchType() {
        self.searchTextField.field.resignFirstResponder()
    }
}

private extension SearchEmitterView {
    func setAppearance() {
        self.style.visibleTitleLabelFont = UIFont.systemFont(ofSize: 0)
        self.searchTextField.setCustomStyle(style)
        self.searchTextField.field.accessibilityIdentifier = "areaInputTexts"
        self.errorLabel.textColor = .bostonRed
        self.errorLabel.isHidden = false
        self.errorLabel.text = " "
        self.configureTextField()
    }
    
    func configureTextField() {
        self.setAllowOnlySevenDigits()
        self.searchTextField.configure(
            with: nil,
            title: localized("receiptsAndTaxes_label_searchCode"),
            style: style,
            extraInfo: (image: Assets.image(named: "icnSearch"), action: doSearch))
        
        self.searchTextField.field.addTarget(
            self, action: #selector(textFieldDidChange),
            for: UIControl.Event.editingChanged
        )
        
        self.searchTextField.setRecturnAction { [weak self] in
            self?.doSearch()
        }
    }
    
    @objc func doSearch() {
        do {
            try self.doSearchTermValidateion()
            self.searchTextField.field.text = self.getSearchCode()
            self.searchTextField.resignFirstResponder()
            self.delegate?.didSelectSeardch(term: self.getSearchCode())
        } catch  SearchTermError.invalidSearchCodeLength {
            self.showInvalidSearchCodeError()
        } catch { }
    }
    
    func getSearchCode() -> String {
         let term = self.searchTextField.field.text ?? ""
         return term.trimmingCharacters(in: .whitespaces)
    }
    
    func showInvalidSearchCodeError() {
        self.errorLabel.isHidden = false
        self.errorLabel.configureText(withKey: "receiptsAndTaxes_error_emptyCode")
        self.style.verticalSeparatorBackgroundColor = .bostonRed
        self.searchTextField.configureFieldWith(style: style)
    }
    
    func clearInvalidSearchError() {
        self.errorLabel.isHidden = true
        self.style.verticalSeparatorBackgroundColor = .darkTurqLight
        self.searchTextField.configureFieldWith(style: style)
    }
    
    func doSearchTermValidateion() throws {
        try self.doSearchByCodeValidation()
    }
    
    func doSearchByCodeValidation() throws {
        let term = self.getSearchCode()
        guard !term.isEmpty else {
            throw SearchTermError.invalidSearchCodeLength
        }
    }
    
    @objc private func textFieldDidChange(sender: UITextField) {
        self.clearInvalidSearchError()
        self.addClearButton(text: sender.text)
    }
    
    func addClearButton(text: String?) {
        guard let text = text else {
           return self.clear()
        }
        guard !text.isEmpty else {
           return self.clear()
        }
        self.searchTextField.insertActionView(clearEmage, at: 1)
    }
}
