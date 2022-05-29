//

import Foundation
import UIKit

class ConfirmationTextFieldViewModel: TableModelViewItem<ConfirmationTextFieldTableViewCell>, InputIdentificable {
    
    let inputIdentifier: String
    let placeholder: LocalizedStylableText?
    let title: LocalizedStylableText?
    let keyboardType: UIKeyboardType
    var dataEntered: String?
    
    private weak var cell: TextFieldTableViewCell?
    
    init(inputIdentifier: String, title: LocalizedStylableText? = nil, placeholder: LocalizedStylableText? = nil, keyboardType: UIKeyboardType, privateComponent: PresentationComponent) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.title = title
        self.keyboardType = keyboardType
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ConfirmationTextFieldTableViewCell) {
        viewCell.setText(text: dataEntered)
        viewCell.styledPlaceholder = placeholder
        viewCell.setTitle(title: title)
        viewCell.newTextFieldValue = { [weak self] value in
            self?.dataEntered = value
        }
    }
}
