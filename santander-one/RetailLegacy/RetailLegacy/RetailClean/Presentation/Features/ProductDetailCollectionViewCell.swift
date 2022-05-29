import UIKit
import UI

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
}

protocol CopiableInfoHandler: class {
    func copyDescription(tag: Int?, completion: (LocalizedStylableText, String?) -> Void)
}

class ProductDetailCollectionViewCell: UICollectionViewCell, ToolTipCompatible {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var copyButton: CoachmarkUIButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rigthSeparatorLabelSubtileConstraint: NSLayoutConstraint!
    weak var shareDelegate: ShareInfoHandler?
    weak var toolTipDelegate: ToolTipDisplayer?
    
    private struct Constants {
        static let longSpace: CGFloat = 30.0
        static let shortSpace: CGFloat = 20.0
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var subtitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
            if titleTopConstraint != nil {
                titleTopConstraint.constant = newValue == "" ? Constants.longSpace : Constants.shortSpace
            }
        }
    }

    func setStyleSubtitle(style: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: style)
        if titleTopConstraint != nil {
            titleTopConstraint.constant = style.text == "" ? Constants.longSpace : Constants.shortSpace
        }
    }
    
    var amount: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
    }
    
    var copyButtonCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.copyButton.coachmarkId
        } set {
            self.copyButton.coachmarkId = newValue
        }
    }

    override func awakeFromNib() {
        titleLabel.font = UIFont.latoBold(size: 14)
        titleLabel.textColor = .sanGreyDark
        subtitleLabel.font = UIFont.latoLight(size: 14)
        subtitleLabel.textColor = .sanGreyDark
        amountLabel.font = UIFont.latoBold(size: 37)
        amountLabel.textColor = .sanGreyDark
        pendingLabel.font = UIFont.latoSemibold(size: 14)
        pendingLabel.textColor = .sanGreyMedium
        bottomSeparator.backgroundColor = .lisboaGray
        copyButton.setImage(Assets.image(named: "icShareIban"), for: .normal)
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        shareDelegate?.shareInfoWithCode(sender.tag)
    }
}

extension ProductDetailCollectionViewCell: ConfigurableCell {
    
    func configure(data: ProductHeader) {
        title = data.title
        setAmount(amount: data.amount, withFormat: data.amountFormat)
        copyButtonCoachmarkId = data.copyButtonCoachmarkId
        pendingLabel.isHidden = data.isPending == false
        if let text = data.pendingText {
            pendingLabel.set(localizedStylableText: text)
        } else {
            pendingLabel.text = nil
        }
        if data.isCopyButtonAvailable == true && !data.subtitle.isEmpty {
            copyButton.isHidden = false
            rigthSeparatorLabelSubtileConstraint.constant = 8
        } else {
            copyButton.isHidden = true
            rigthSeparatorLabelSubtileConstraint.constant = -copyButton.frame.size.width
        }
        
        if let styleSubtitle = data.styleSubtitle {
            setStyleSubtitle(style: styleSubtitle)
        } else {
            subtitle = data.subtitle
        }
        shareDelegate = data.shareDelegate
        copyButton.tag = data.copyTag ?? 0
        bottomSeparator.backgroundColor = data.isBigSeparator ? .sanGreyLight : .lisboaGray
        if bottomSeparatorHeightConstraint != nil {
            bottomSeparatorHeightConstraint.constant = data.isBigSeparator ? 6.0 : 1.0
        }
        copyButton.setImage(Assets.image(named: "icShareIban"), for: .normal)
    }
    
    func setAmount(amount: Amount?, withFormat format: ProductHeader.AmountFormat) {
        switch format {
        case .long:
             self.amount = amount?.getFormattedAmountUI()
        case .short:
            self.amount = amount?.getFormattedAmountUIWith1M()
        }
    }
}
