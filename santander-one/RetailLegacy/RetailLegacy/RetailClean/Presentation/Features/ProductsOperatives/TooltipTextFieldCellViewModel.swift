import Foundation

class TooltipTextFieldCellViewModel: TableModelViewItem<TooltipTextFieldViewCell>, InputIdentificable {
    var inputIdentifier: String
    var dataEntered: String?
    private let titleText: LocalizedStylableText?
    private var textFormatMode: FormattedTextField.FormatMode?
    private let style: TextFieldStylist?
    weak var delegate: TooltipTextFieldActionDelegate?
    private let tooltipText: LocalizedStylableText?
    
    init(inputIdentifier: String, titleText: LocalizedStylableText? = nil, textFormatMode: FormattedTextField.FormatMode? = .numericInteger(6), style: TextFieldStylist? = nil, delegate: TooltipTextFieldActionDelegate?, tooltipText: LocalizedStylableText? = nil, dependencies: PresentationComponent) {
        self.titleText = titleText
        self.textFormatMode = textFormatMode
        self.style = style
        self.delegate = delegate
        self.tooltipText = tooltipText
        self.inputIdentifier = inputIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: TooltipTextFieldViewCell) {
        viewCell.textFormatMode = textFormatMode
        viewCell.style = style
        viewCell.setTitle(titleText)
        viewCell.actionDelegate = delegate
        viewCell.tooltipText = tooltipText
        viewCell.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
        }
    }
}
