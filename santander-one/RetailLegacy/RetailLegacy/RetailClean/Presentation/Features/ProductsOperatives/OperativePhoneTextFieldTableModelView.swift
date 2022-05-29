import UIKit

class OperativePhoneTextFieldTableModelView: TableModelViewItem<OperativePhoneTextFieldTableViewCell> {
    
    private let phone: String?
    var placeholder: LocalizedStylableText?
    weak var delegate: (UITextViewDelegate & ChangeTextViewDelegate)?
    
    init(phone: String?, placeholder: LocalizedStylableText?, delegate: (UITextViewDelegate & ChangeTextViewDelegate)? = nil, privateComponent: PresentationComponent) {
        self.phone = phone
        self.placeholder = placeholder
        self.delegate = delegate
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativePhoneTextFieldTableViewCell) {
        viewCell.textView.delegate = delegate
        viewCell.placeholder = placeholder
        viewCell.phone = phone
    }
}
