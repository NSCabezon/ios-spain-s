import UI

class PlanQuoteConfigurationItemTableViewCell: BaseViewCell {
    
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                fieldTitleLabel.set(localizedStylableText: title)
            } else {
                fieldTitleLabel.text = nil
            }
        }
    }
    
    var value: String? {
        get {
            return fieldValueLabel.text
        }
        set {
            fieldValueLabel.text = newValue
        }
    }
    
    var order: RoundedContainerItemOrder = .middle {
        didSet {
            bottomConstraint.constant = order == .tail ? 6.0 : 0.0
            setNeedsDisplay()
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var fieldTitleLabel: UILabel!
    @IBOutlet private weak var fieldValueLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var iconArrowRight: UIImageView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: .latoSemibold(size: 16)))
        fieldValueLabel.applyStyle(LabelStylist(textColor: .sanRed,
                                                font: .latoLight(size: 16),
                                                textAlignment: .right))
        iconArrowRight.image = Assets.image(named: "icnArrowRightGray")
        separator.backgroundColor = .lisboaGray
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
}
