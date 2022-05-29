import UIKit

class FundSubscriptionModelView: RadioTableModelView {
    
    let type: FundSubscriptionType
    let field: UITextField
    
    init(type: FundSubscriptionType, radio: RadioTable, privateComponent: PresentationComponent) {
        self.type = type
        let text: String
        let field: UITextField
        let tag: Int
        let fieldToUse = FormattedTextField()
        fieldToUse.keyboardType = .decimalPad
        switch type {
        case .amount:
            text = "foundSubscription_radiobutton_amount"
            fieldToUse.textFormatMode = FormattedTextField.FormatMode.defaultCurrency(12, 2)
            fieldToUse.delegate = fieldToUse.parser
            field = fieldToUse
            tag = 0
        case .participation:
            text = "foundSubscription_radiobutton_participations"
            fieldToUse.textFormatMode = FormattedTextField.FormatMode.numeric(12, 5)
            fieldToUse.delegate = fieldToUse.parser
            field = fieldToUse
            field.setOnPlaceholder(localizedStylableText: privateComponent.stringLoader.getString("operation_input_quantity"))
            tag = 1
        }
        let info = RadioTableInfo(title: privateComponent.stringLoader.getString(text), view: field, insets: UIEdgeInsets(top: 8, left: 45, bottom: 23, right: 13), height: 50, auxiliaryImage: nil, auxiliaryTag: tag, isInitialIndex: false)
        self.field = field
        super.init(info: info, radioTable: radio, privateComponent)
        configureField(textField: field)
    }
    
    private func configureField(textField: UITextField) {
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
