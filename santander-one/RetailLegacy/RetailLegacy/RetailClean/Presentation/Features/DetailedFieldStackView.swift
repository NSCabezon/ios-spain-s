import UI

class DetailedFieldStackView: StackItemView, RoundCapableView {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    var isFirst = false
    var isLast = false {
        didSet {
            separatorView.isHidden = isLast == true
        }
    }
    var optionClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        roundedView.backgroundColor = .uiWhite
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .left))
        detailLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16), textAlignment: .left))
        optionButton.setImage(Assets.image(named: "icShareIban"), for: .normal)
        optionButton.addTarget(self, action: #selector(didTouch(sender:)), for: .touchUpInside)
        separatorView.backgroundColor = .lisboaGray
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedStyle()
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setDetail(_ detail: LocalizedStylableText) {
        detailLabel.set(localizedStylableText: detail)
    }

    func setOptionClosure(_ closure: (() -> Void)?) {
        optionClosure = closure
        optionButton.isHidden = closure == nil
    }

    @objc func didTouch(sender: ResponsiveButton) {
        optionClosure?()
    }
    
    func setDetailLineBreakMode(_ lineBreakMode: NSLineBreakMode) {
        detailLabel.lineBreakMode = lineBreakMode
    }
}

protocol RoundCapableView {
    var roundedView: UIView! { get }
    var isFirst: Bool { get }
    var isLast: Bool { get }
}

extension RoundCapableView {
    
    func applyRoundedStyle() {
        switch (isFirst, isLast) {
        case (true, false):
            StylizerNonCollapsibleViewCells.applyHeaderOpenViewCellStyle(view: roundedView)
        case (false, true):
            StylizerNonCollapsibleViewCells.applyBottomViewCellStyle(view: roundedView)
        case (true, true):
            StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: roundedView)
        case (false, false):
            StylizerNonCollapsibleViewCells.applyMiddleViewCellStyle(view: roundedView)
        }
    }
    
}
