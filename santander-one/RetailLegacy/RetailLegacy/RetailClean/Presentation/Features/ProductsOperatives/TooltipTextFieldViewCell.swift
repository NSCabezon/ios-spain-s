//

import UIKit
import UI

enum TooltipTextFieldAuxiliaryAction {
    case toolTip(delegate: ToolTipDisplayer?)
    case none
}

protocol TooltipTextFieldActionDelegate: class {
    func auxiliaryButtonAction(completion: (_ action: TooltipTextFieldAuxiliaryAction) -> Void)
}

class TooltipTextFieldViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var formattedTextField: FormattedTextField!
    weak var actionDelegate: TooltipTextFieldActionDelegate?
    weak var toolTipDelegate: ToolTipDisplayer?
    var tooltipButton: UIButton?
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoBold(size: 16),
                                           textAlignment: .left))
        
        self.tooltipButton = UIButton()
        self.tooltipButton?.setImage(Assets.image(named: "icnInfoGrayBig"), for: .normal)
        self.tooltipButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        self.tooltipButton?.sizeToFit()
        self.tooltipButton?.addTarget(self, action: #selector(showToolTip), for: .touchUpInside)
        
        formattedTextField.rightView = self.tooltipButton
        formattedTextField.rightViewMode = .always
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
                    cell.toolTipDelegate?.displayPermanentToolTip(with: nil, descriptionLocalized: tooltipText, inView: tooltipButton, withSourceRect: tooltipButton.bounds, forcedDirection: .right)
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
