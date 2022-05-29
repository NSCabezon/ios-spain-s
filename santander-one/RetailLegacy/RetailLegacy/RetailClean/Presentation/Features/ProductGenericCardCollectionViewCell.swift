//

import UIKit

protocol GenericCardCellEventsDelegate: class {
    func moreInfo(completion: (LocalizedStylableText?, LocalizedStylableText?) -> Void)
}

class ProductGenericCardCollectionViewCell: UICollectionViewCell, ToolTipCompatible {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: CoachmarkUILabel!
    @IBOutlet weak var cardButton: ResponsiveButton!
    @IBOutlet weak var extraInfoButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var botomSeparator: UIView!
    
    private let grayedOutAlpha = CGFloat(0.5)
    private let noGrayedOut = CGFloat(1.0)
    private let smallCardWidth = CGFloat(90)
    private let bigCardWidth = CGFloat(112)
    private weak var eventDelegate: GenericCardCellEventsDelegate?
    weak var toolTipDelegate: ToolTipDisplayer?
    weak var shareDelegate: ShareInfoHandler?

    var amountLabelCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.amountLabel.coachmarkId
        } set {
            self.amountLabel.coachmarkId = newValue
        }
    }
    
    override func awakeFromNib() {
        titleLabel.font = UIFont.latoBold(size: 14)
        subtitleLabel.font = UIFont.latoLight(size: 14)
        subtitleLabel.textColor = .sanGreyDark
        amountTitleLabel.textColor = .sanGreyMedium
        if UIScreen.main.isIphone4or5 {
            amountLabel.font = UIFont.latoBold(size: 30)
            amountTitleLabel.font = UIFont.latoBold(size: 11)
        } else {
            amountLabel.font = UIFont.latoBold(size: 37)
            amountTitleLabel.font = UIFont.latoBold(size: 14)
        }
        amountLabel.textColor = .sanGreyDark
        botomSeparator.backgroundColor = .lisboaGray
        
        setupCardSize()
    }
    
    // MARK: - Actions
    @IBAction func shareButtonAction(_ sender: UIButton) {
        shareDelegate?.shareInfoWithCode(sender.tag)
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        eventDelegate?.moreInfo { (title, description) in
            toolTipDelegate?.displayPermanentToolTip(with: title, descriptionLocalized: description, inView: self, withSourceRect: extraInfoButton.frame, forcedDirection: .up)
        }
    }
    
    fileprivate func setupCardSize() {
        let isSmallScreen = UIScreen.main.isIphone4or5
        imageWidthConstraint.constant = isSmallScreen ? smallCardWidth : bigCardWidth
    }
}

extension ProductGenericCardCollectionViewCell: ConfigurableCell {

    func configure(data: ProductGenericCardHeader) {
        displayMode(mode: data.cardState)
        eventDelegate = data.cellEventsHandler
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        amountLabel.text = data.amount
        amountLabel.scaleDecimals()
        amountLabelCoachmarkId = data.amountLabelCoachmarkId
        if let text = data.amountTitleText, !data.amount.isEmpty {
            amountTitleLabel.set(localizedStylableText: text)
            extraInfoButton.isHidden = data.cardState == CardState.disabled ? true : !data.isInfoAvailable
        } else {
            amountTitleLabel.text = nil
            extraInfoButton.isHidden = true
        }
        data.imageLoader.load(relativeUrl: data.cardImage, button: cardButton, placeholder: "defaultCard")
        cardButton.onTouchAction = { _ in
            data.action?()
        }
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
        amountTitleLabel.isHidden = false
        amountLabel.isHidden = false
        titleLabel.alpha = alpha
        subtitleLabel.alpha = alpha
        amountTitleLabel.alpha = alpha
        amountLabel.alpha = alpha
        cardButton.alpha = alpha
        extraInfoButton.alpha = alpha
        copyButton.alpha = alpha
    }
}
