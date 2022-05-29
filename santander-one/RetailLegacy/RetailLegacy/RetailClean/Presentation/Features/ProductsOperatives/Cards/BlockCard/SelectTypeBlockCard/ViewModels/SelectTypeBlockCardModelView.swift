import UIKit
import CoreFoundationLib

class SelectTypeBlockCardModelView: RadioTableModelView {
    let statusType: BlockCardStatus
    let field = CustomTextField()
    
    init(statusType: BlockCardStatus, radio: RadioTable, privateComponent: PresentationComponent, inputIdentifier: String? = nil) {
        self.statusType = statusType
        let text: String
        var preffixIdentifier = inputIdentifier ?? "option"
        switch statusType {
        case .stolen:
            text = "blockCard_input_stole"
            field.setOnPlaceholder(localizedStylableText: privateComponent.stringLoader.getString("blockCard_hint_commentary"))
            preffixIdentifier += "_stolen"
        case .deterioration:
            text = "blockCard_input_wear"
            field.setOnPlaceholder(localizedStylableText: privateComponent.stringLoader.getString("blockCard_hint_commentary"))
            preffixIdentifier += "_deterioration"
        }
        let info = RadioTableInfo(title: privateComponent.stringLoader.getString(text), view: field, insets: UIEdgeInsets(top: 8, left: 45, bottom: 23, right: 13), height: 50, auxiliaryImage: nil, auxiliaryTag: 0, isInitialIndex: false)
        super.init(info: info, radioTable: radio, privateComponent, inputIdentifier: preffixIdentifier)
        configureField(textField: field, identifier: preffixIdentifier)
    }
    
    private func configureField(textField: UITextField, identifier: String? = nil) {
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
        if let identifier = identifier { textField.accessibilityIdentifier = identifier } 
    }
}
