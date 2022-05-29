import UIKit

class ProductCreditCardCollectionViewCell: UICollectionViewCell, ToolTipCompatible {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountDetailLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var cardButtonView: ResponsiveButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var wrapperBarView: UIView!
    @IBOutlet weak var redBarView: UIView!
    @IBOutlet weak var copyButton: CoachmarkUIButton!
    @IBOutlet weak var redBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var botomSeparator: UIView!
    
    weak var toolTipDelegate: ToolTipDisplayer?

    private let grayedOutAlpha = CGFloat(0.5)
    private let noGrayedOut = CGFloat(1.0)
    private let smallCardWidth = CGFloat(90)
    private let bigCardWidth = CGFloat(112)
    private weak var eventDelegate: GenericCardCellEventsDelegate?
    private weak var shareDelegate: ShareInfoHandler?
    
    var copyButtonCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.copyButton.coachmarkId
        } set {
            self.copyButton.coachmarkId = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.latoBold(size: 14)
        titleLabel.textColor = .sanGreyDark
        subtitleLabel.font = UIFont.latoLight(size: 14)
        subtitleLabel.textColor = .sanGreyDark
        amountLabel.textColor = .sanGreyDark
        if UIScreen.main.isIphone4or5 {
            amountLabel.font = UIFont.latoBold(size: 30)
            amountDetailLabel.font = UIFont.latoBold(size: 11)
        } else {
            amountLabel.font = UIFont.latoBold(size: 37)
            amountDetailLabel.font = UIFont.latoBold(size: 14)
        }
        amountDetailLabel.textColor = .sanGreyMedium
        availabilityLabel.font = UIFont.latoRegular(size: 14)
        availabilityLabel.textColor = .sanGreyMedium
        limitLabel.font = UIFont.latoRegular(size: 14)
        limitLabel.textColor = .sanGreyMedium
        botomSeparator.backgroundColor = .lisboaGray
        
        setupCardSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        wrapperBarView.layer.cornerRadius = wrapperBarView.bounds.height / 2
        redBarView.layer.cornerRadius = redBarView.bounds.height / 2
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        shareDelegate?.shareInfoWithCode(sender.tag)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        eventDelegate?.moreInfo { (title, description) in
            toolTipDelegate?.displayPermanentToolTip(with: title, descriptionLocalized: description, inView: self, withSourceRect: infoButton.frame, forcedDirection: nil)
        }
    }
    
    fileprivate func setupCardSize() {
        let isSmallScreen = UIScreen.main.isIphone4or5
        imageWidthConstraint.constant = isSmallScreen ? smallCardWidth : bigCardWidth
    }
}

extension ProductCreditCardCollectionViewCell: ConfigurableCell {
    
    func configure(data: ProductCreditCardHeader) {
        displayMode(mode: data.cardState)
        eventDelegate = data.cellEventsHandler
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        amountLabel.text = data.amount
        amountLabel.scaleDecimals()
        amountDetailLabel.set(localizedStylableText: data.availableDescription)
        availabilityLabel.set(localizedStylableText: data.availableAmount)
        limitLabel.set(localizedStylableText: data.limitAmount)
        data.imageLoader.load(relativeUrl: data.cardImage, button: cardButtonView, placeholder: "defaultCard")
        cardButtonView.onTouchAction = { _ in
            data.action?()
        }
        redBarWidthConstraint.constant = wrapperBarView.bounds.width * CGFloat(data.percentageBar)
        shareDelegate = data.shareDelegate
        copyButton.tag = data.copyTag ?? 0
    }

    private func displayMode(mode: CardState) {
        let alpha: CGFloat
        switch mode {
        case .active:
            alpha = noGrayedOut
        case .blocked:
            alpha = grayedOutAlpha
        case .disabled:
            alpha = grayedOutAlpha
        }
        amountLabel.isHidden = false
        amountDetailLabel.isHidden = false
        availabilityLabel.isHidden = false
        limitLabel.isHidden = false
        wrapperBarView.isHidden = false
        infoButton.isHidden = false
        titleLabel.alpha = alpha
        subtitleLabel.alpha = alpha
        amountLabel.alpha = alpha
        amountDetailLabel.alpha = alpha
        availabilityLabel.alpha = alpha
        limitLabel.alpha = alpha
        cardButtonView.alpha = alpha
        infoButton.alpha = alpha
        wrapperBarView.alpha = alpha
        redBarView.alpha = alpha
        copyButton.alpha = alpha
    }
}
