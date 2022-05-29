import Foundation

class TooltipInTitleWithTextFieldViewModel: TableModelViewItem<TooltipInTitleWithTextFieldViewCell>, InputIdentificable {
    var inputIdentifier: String
    var dataEntered: String?
    private let titleText: LocalizedStylableText?
    private var textFormatMode: FormattedTextField.FormatMode?
    private let style: TextFieldStylist?
    weak var delegate: TooltipInTitleWithTextFieldActionDelegate?
    private let tooltipTitle: LocalizedStylableText?
    private let tooltipText: LocalizedStylableText?
    
    init(inputIdentifier: String, titleText: LocalizedStylableText? = nil, textFormatMode: FormattedTextField.FormatMode? = .numericInteger(6), style: TextFieldStylist? = nil, delegate: TooltipInTitleWithTextFieldActionDelegate?, tooltipTitle: LocalizedStylableText? = nil, tooltipText: LocalizedStylableText? = nil, dependencies: PresentationComponent) {
        self.titleText = titleText
        self.textFormatMode = textFormatMode
        self.style = style
        self.delegate = delegate
        self.tooltipTitle = tooltipTitle
        self.tooltipText = tooltipText
        self.inputIdentifier = inputIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: TooltipInTitleWithTextFieldViewCell) {
        viewCell.textFormatMode = textFormatMode
        viewCell.style = style
        viewCell.setTitle(titleText)
        viewCell.setAccessibilityIdentifiers()
        viewCell.actionDelegate = delegate
        viewCell.tooltipTitle = tooltipTitle
        viewCell.tooltipText = tooltipText
        viewCell.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
        }
    }
}
