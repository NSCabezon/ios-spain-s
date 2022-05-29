import UI

class InsuranceGeneralDataTableViewCell: BaseViewCell, ToolTipCompatible {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonCopy: UIButton!
    var toolTipDelegate: ToolTipDisplayer?
    weak var shareDelegate: ShareInfoHandler?

    var isFirst: Bool = false {
        didSet {
            showSeparator()
        }
    }
    
    var isLast: Bool = false {
        didSet {
            bottomSpace()
        }
    }
    
    var isCopiable: Bool = false {
        didSet {
            showCopy()
        }
    }
    
    var infoTitle: LocalizedStylableText? {
        didSet {
            if let text = infoTitle {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var info: String? {
        get {
            return infoLabel.text
        }
        
        set {
            infoLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0)))
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18.0)))
        separator.backgroundColor = .lisboaGray
        backgroundColor = .white
        buttonCopy.setImage(Assets.image(named: "icShareIban"), for: .normal)
    }
    
    func showSeparator() {
        separator.isHidden = isFirst
    }
    
    func bottomSpace() {
        if isLast {
            bottomConstraint.constant = 50
        } else {
            bottomConstraint.constant = 13
        }
    }
    
    func showCopy() {
        buttonCopy.isHidden = !isCopiable
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        shareDelegate?.shareInfoWithCode(self.tag)
    }
}
