//

import UIKit
import UI
import CoreFoundationLib

enum TooltipInTitleWithTextFieldAuxiliaryAction {
    case toolTip(delegate: ToolTipDisplayer?)
    case none
}

protocol TooltipInTitleWithTextFieldActionDelegate: class {
    func auxiliaryButtonAction(completion: (_ action: TooltipInTitleWithTextFieldAuxiliaryAction) -> Void)
}

class TooltipInTitleWithTextFieldViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var formattedTextField: FormattedTextField!
    @IBOutlet weak var tooltipButton: UIButton!
    weak var actionDelegate: TooltipInTitleWithTextFieldActionDelegate?
    weak var toolTipDelegate: ToolTipDisplayer?
    var newTextFieldValue: ((String?) -> Void)?
    
    var dataEntered: String? {
        didSet {
            formattedTextField.text = dataEntered
        }
    }
    
    var textFormatMode: FormattedTextField.FormatMode? {
        didSet {
            guard let formatMode = textFormatMode else { return }
            formattedTextField.textFormatMode = formatMode
        }
    }
    
    var style: TextFieldStylist? {
        didSet {
            guard let style = style else { return }
            (formattedTextField as UITextField).applyStyle(style)
        }
    }
    
    var tooltipTitle: LocalizedStylableText? {
        didSet {
            guard let tooltip = tooltipTitle else { return }
            tooltipTitle = tooltip
        }
    }
    
    var tooltipText: LocalizedStylableText? {
        didSet {
            guard let tooltip = tooltipText else { return }
            tooltipText = tooltip
        }
    }
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            titleLabel.text = nil
            return
        }
        titleLabel.set(localizedStylableText: title)
    }
    
    func setAccessibilityIdentifiers() {
        let accessibilityIdentifier = accessibilityIdentifier ?? ""
        self.titleLabel.accessibilityIdentifier = accessibilityIdentifier + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewTitleLabel
        self.formattedTextField.accessibilityIdentifier = accessibilityIdentifier + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewFormattedTextFieldLabel
        self.formattedTextField.setRightImageIdentifier(identifier: accessibilityIdentifier + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewFormattedTextFieldImage)
        self.tooltipButton.accessibilityIdentifier = accessibilityIdentifier + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewTooltipButton
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoBold(size: 16),
                                           textAlignment: .left))
        tooltipButton.setImage(Assets.image(named: "icnInfoGrayBig"), for: .normal)
        tooltipButton?.addTarget(self, action: #selector(showToolTip), for: .touchUpInside)
        
        formattedTextField.keyboardType = .decimalPad
        formattedTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        formattedTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
    }
    
    @objc func showToolTip() {
        actionDelegate?.auxiliaryButtonAction(completion: { [weak self] (action) in
            switch action {
            case .toolTip(let delegate):
                if let cell = self {
                    cell.toolTipDelegate = delegate
                    guard let tooltipButton = cell.tooltipButton else { return }
                    cell.toolTipDelegate?.displayPermanentToolTip(with: tooltipTitle, descriptionLocalized: tooltipText, inView: tooltipButton, withSourceRect: tooltipButton.bounds, forcedDirection: .up)
                }
            default:
                break
            }
        })
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}
