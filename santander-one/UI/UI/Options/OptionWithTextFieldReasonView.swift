//
//  OptionWithTextFieldReasonView.swift
//  UI
//
//  Created by Iván Estévez Nieto on 27/5/21.
//

import Foundation

protocol OptionWithTextFieldReasonViewDelegate: AnyObject {
    func textFieldUpdated(text: String)
}

final class OptionWithTextFieldReasonView: XibView {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var textField: LisboaTextField!
    private weak var delegate: OptionWithTextFieldReasonViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDelegate(_ delegate: OptionWithTextFieldReasonViewDelegate) {
        self.delegate = delegate
    }
    
    func setViewModel(_ viewModel: OptionWithTextFieldReasonViewModel) {
        self.descriptionLabel.text = viewModel.description
        self.textField.setPlaceholder(viewModel.placeholderText)
        self.textField.textFieldPlaceholder = viewModel.placeholderText
    }
}

private extension OptionWithTextFieldReasonView {
    func setAppearance() {
        self.descriptionLabel.font = .santander(family: .text, type: .light, size: 16)
        self.descriptionLabel.textColor = .lisboaGray
        let configuration = LisboaTextField.WritableTextField(type: .floatingTitle)
        self.textField.setEditingStyle(.writable(configuration: configuration))
        self.textField.fieldDelegate = self
    }
}

extension OptionWithTextFieldReasonView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.delegate?.textFieldUpdated(text: updatedText)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view?.endEditing(true)
        return true
    }
}
