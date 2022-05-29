class FormatedTextFieldCellViewModel: TableModelViewItem<FormatedTextFieldTableViewCell> {
    var placeholder: LocalizedStylableText?
    var textFormatMode: FormattedTextField.FormatMode
    var value: String?
    let type: KeyboardTextFieldResponderOrder?
    
    private weak var cell: FormatedTextFieldTableViewCell?
    
    init(_ placeholder: LocalizedStylableText?, _ textFormatMode: FormattedTextField.FormatMode, _ privateComponent: PresentationComponent, nextType: KeyboardTextFieldResponderOrder? = nil) {
        self.placeholder = placeholder
        self.textFormatMode = textFormatMode
        self.type = nextType
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: FormatedTextFieldTableViewCell) {
        viewCell.styledPlaceholder = placeholder
        viewCell.textFormatMode = textFormatMode
        viewCell.newTextFieldValue = { [weak self] value in
            self?.value = value
        }
        if let type = type {
            viewCell.textField.reponderOrder = type
        }
    }
}
