import Foundation

protocol InputIdentificable {
    var inputIdentifier: String { get }
    var dataEntered: String? { get }
}

typealias AmountInputIdentifiers = (input: String?, title: String?, inputText: String?, inputRightImage: String?)

class AmountInputViewModel: TableModelViewItem<AmountInputTableViewCell>, InputIdentificable {
    private let titleText: LocalizedStylableText?
    private let placeholderText: LocalizedStylableText?
    var dataEntered: String?
    let inputIdentifier: String
    var textFormatMode: FormattedTextField.FormatMode?
    var inputValueDidChange: (() -> Void)?
    let style: TextFieldStylist?
    let titleIdentifier: String?
    let textInputIdentifier: String?
    let textInputRightImageIdentifier: String?
    
    init(inputIdentifier: String,
         titleText: LocalizedStylableText? = nil,
         placeholderText: LocalizedStylableText? = nil,
         textFormatMode: FormattedTextField.FormatMode? = .defaultCurrency(4, 0),
         style: TextFieldStylist? = nil,
         dependencies: PresentationComponent,
         titleIdentifier: String? = nil,
         textInputIdentifier: String? = nil,
         textInputRightImageIdentifier: String? = nil) {
        self.titleText = titleText
        self.placeholderText = placeholderText
        self.inputIdentifier = inputIdentifier
        self.textFormatMode = textFormatMode
        self.style = style
        self.titleIdentifier = titleIdentifier
        self.textInputIdentifier = textInputIdentifier
        self.textInputRightImageIdentifier = textInputRightImageIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: AmountInputTableViewCell) {
        viewCell.setAccessibilityIdentifiers(identifiers: (inputIdentifier, titleIdentifier, textInputIdentifier, textInputRightImageIdentifier))
        viewCell.textFormatMode = textFormatMode
        viewCell.style = style
        viewCell.setTitle(titleText)
        viewCell.dataEntered = dataEntered
        viewCell.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
            self?.inputValueDidChange?()
        }
        guard let placeholderText = placeholderText else { return }
        viewCell.formattedAmountTextField.setOnPlaceholder(localizedStylableText: placeholderText)
    }
}
