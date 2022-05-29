//

import Foundation

class TextFieldCellViewModel: TableModelViewItem<TextFieldTableViewCell>, InputIdentificable {
    
    var inputIdentifier: String
    var dataEntered: String?
    var placeholder: LocalizedStylableText?
    var value: String?
    var maxLength: Int?
    let type: KeyboardTextFieldResponderOrder?
    var newDataEntered: String?
    var insets: Insets?
    
    private weak var cell: TextFieldTableViewCell?
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText?, privateComponent: PresentationComponent, maxLength: Int? = nil, nextType: KeyboardTextFieldResponderOrder? = nil, insets: Insets? = nil) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.type = nextType
        self.maxLength = maxLength
        self.insets = insets
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: TextFieldTableViewCell) {
        viewCell.setInstes(insets: self.insets)
        viewCell.setText(text: dataEntered)
        viewCell.textField.formattedDelegate.maxLength = maxLength
        viewCell.styledPlaceholder = placeholder
        viewCell.newTextFieldValue = { [weak self] value in
            self?.value = value
            self?.dataEntered = value
        }
        if let type = type {
            viewCell.textField.reponderOrder = type
        }
        if let text = newDataEntered {
            viewCell.textField.text = text
            dataEntered = viewCell.textField.text
            newDataEntered = nil
        }
    }
}
