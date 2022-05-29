import UI

class DetailItemTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var copyButtonContainer: UIView!
    weak var toolTipDisplayer: ToolTipDisplayer?
    weak var shareDelegate: ShareInfoHandler?
    
    var isFirst = false
    var isLast = false {
        didSet {
            separatorView.isHidden = isLast
        }
    }
    
    var subtitleLines: Int = 1 {
        didSet {
            subtitleLabel.numberOfLines = subtitleLines
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0)))
        copyButton.addTarget(self, action: #selector(sharePressed(_:)), for: .touchUpInside)
        copyButton.setImage(Assets.image(named: "icShareIban"), for: .normal)
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }

    func setSubtitle(_ subtitle: String?) {
        subtitleLabel.text = subtitle
    }
    
    func setCopyButtonHidden(_ isHidden: Bool) {
        copyButtonContainer.isHidden = isHidden
    }
    
    func setAccessibilityIdentifiers(titleAccessibilityIdentifier: String, subtitleAccessibilityIdentifier: String, copyButtonAccessibilityIdentifier: String, imgCopyButtonAccessibilityIdentifier: String) {
        titleLabel.accessibilityIdentifier = titleAccessibilityIdentifier
        subtitleLabel.accessibilityIdentifier = subtitleAccessibilityIdentifier
        copyButton.accessibilityIdentifier = copyButtonAccessibilityIdentifier
        copyButton.imageView?.accessibilityIdentifier = imgCopyButtonAccessibilityIdentifier
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyRoundedStyle()
    }
    
    private func applyRoundedStyle() {
        switch (isFirst, isLast) {
        case (true, false):
            StylizerNonCollapsibleViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        case (false, true):
            StylizerNonCollapsibleViewCells.applyBottomViewCellStyle(view: containerView)
        case (true, true):
            StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: containerView)
        case (false, false):
            StylizerNonCollapsibleViewCells.applyMiddleViewCellStyle(view: containerView)
        }
    }
    
    @objc func sharePressed(_ sender: Any) {
        shareDelegate?.shareInfoWithCode(self.tag)
    }
}
