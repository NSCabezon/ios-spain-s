import UIKit

class FundTransferTypeSelectionModelView: RadioTableModelView {
    
    let type: FundTransferType
    let field: UITextField?
    
    init(type: FundTransferType, radio: RadioTable, privateComponent: PresentationComponent) {
        self.type = type
        let text: String
        var newField: UITextField?
        let tag: Int
        let fieldToUse = FormattedTextField()
        fieldToUse.keyboardType = .decimalPad
        
        switch type {
        case .total:
            text = "foundTransfer_radiobutton_total"
            tag = 0
        case .partialAmount:
            text = "foundTransfer_radiobutton_parcialAmount"
            fieldToUse.textFormatMode = FormattedTextField.FormatMode.defaultCurrency(12, 2)
            fieldToUse.delegate = fieldToUse.parser
            newField = fieldToUse
            tag = 1
        case .partialShares:
            text = "foundTransfer_radiobutton_parcialNumberOperation"
            fieldToUse.textFormatMode = FormattedTextField.FormatMode.numeric(12, 5)
            fieldToUse.delegate = fieldToUse.parser
            newField = fieldToUse
            newField!.setOnPlaceholder(localizedStylableText: privateComponent.stringLoader.getString("operation_input_quantity"))
            tag = 2
        }
        
        let info = RadioTableInfo(title: privateComponent.stringLoader.getString(text), view: newField, insets: newField != nil ? UIEdgeInsets(top: 8, left: 45, bottom: 23, right: 13) : nil, height: newField != nil ? 50 : 0, auxiliaryImage: nil, auxiliaryTag: tag, isInitialIndex: false)
        self.field = newField
        super.init(info: info, radioTable: radio, privateComponent)
        configureField(textField: newField)
    }
    
    private func configureField(textField: UITextField?) {
        
        guard let textField = textField else {
            return
        }
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = .latoRegular(size: 16)
        textField.textColor = .sanGreyDark
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lisboaGray.cgColor
        textField.layer.borderWidth = 1
    }
}
