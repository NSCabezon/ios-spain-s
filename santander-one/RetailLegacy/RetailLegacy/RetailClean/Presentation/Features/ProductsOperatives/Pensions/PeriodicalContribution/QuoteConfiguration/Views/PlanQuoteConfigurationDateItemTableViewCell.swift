//

import UI

class PlanQuoteConfigurationDateItemTableViewCell: BaseViewCell {
    
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                fieldTitleLabel.set(localizedStylableText: title)
            } else {
                fieldTitleLabel.text = nil
            }
        }
    }
    
    var date: String? {
        get {
            return dateTextField.text
        }
        set {
            dateTextField.text = newValue
        }
    }
    
    var order: RoundedContainerItemOrder = .middle {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fieldTitleLabel: UILabel!
    @IBOutlet weak var dateTextField: KeyboardTextField!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var iconArrowRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: .latoSemibold(size: 16)))
        (dateTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanRed,
                                                                   font: .latoLight(size: 16),
                                                                   textAlignment: .right))
        separator.backgroundColor = .lisboaGray
        iconArrowRight.image = Assets.image(named: "icnArrowRightGray")
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBorders()
    }
    
    func drawBorders() {
        switch order {
        case .head:
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        case .middle:
            StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
        case .tail:
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        }
        clipsToBounds = order != .tail
        separator.isHidden = order == .tail
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            dateTextField.becomeFirstResponder()
        }
    }
}

extension PlanQuoteConfigurationDateItemTableViewCell: DatePickerCell {
    var dateField: UITextField {
        return self.dateTextField
    }
}
