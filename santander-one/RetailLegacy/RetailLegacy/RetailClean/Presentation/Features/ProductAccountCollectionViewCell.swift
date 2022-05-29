//

import UIKit

protocol ProductAccountCollectionViewCellEventsDelegate: class {
    func showBalanceInfo(completion: (LocalizedStylableText?, LocalizedStylableText?) -> Void)
    func showRetentionsInfo(completion: @escaping (LocalizedStylableText?, String?) -> Void)
}

class ProductAccountCollectionViewCell: UICollectionViewCell, ToolTipCompatible, DynamicToolTipCompatible {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var copyButton: CoachmarkUIButton!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var rigthSeparatorLabelSubtileConstraint: NSLayoutConstraint!
    @IBOutlet weak var realBalanceLabel: UILabel!
    @IBOutlet weak var realBalanceValueLabel: UILabel!
    @IBOutlet weak var retentionsButton: UIButton!
    weak var toolTipDelegate: ToolTipDisplayer?
    weak var dynamicToolTipDelegate: DynamicToolTipDisplayer?
    private weak var shareDelegate: ShareInfoHandler?
    
    private weak var eventDelegate: ProductAccountCollectionViewCellEventsDelegate?
    
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
        }
    }
    
    func setStyleSubtitle(style: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: style)
    }
    
    var availableBalance: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
    }
    
    var realBalance: String? {
        get {
            return realBalanceValueLabel.text
        }
        set {
            realBalanceValueLabel.text = newValue
            realBalanceValueLabel.scaleDecimals()
        }
    }
    
    var copyButtonCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.copyButton.coachmarkId
        } set {
            self.copyButton.coachmarkId = newValue
        }
    }
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.latoBold(size: 14)
        titleLabel.textColor = .sanGreyDark
        subtitleLabel.font = UIFont.latoLight(size: 14)
        subtitleLabel.textColor = .sanGreyDark
        amountLabel.font = UIFont.latoBold(size: 37)
        availableBalanceLabel.textColor = .sanGreyMedium
        availableBalanceLabel.font = UIFont.latoBold(size: 14)
        realBalanceLabel.textColor = .sanGreyMedium
        realBalanceLabel.font = UIFont.latoRegular(size: 14)
        retentionsButton.applyStyle(ButtonStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: 14)))
        bottomSeparator.backgroundColor = .lisboaGray
        
        let tapAvailableBalanceLabel = UITapGestureRecognizer(target: self, action: #selector(showBalanceInfo))
        availableBalanceLabel.addGestureRecognizer(tapAvailableBalanceLabel)
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        shareDelegate?.shareInfoWithCode(sender.tag)
    }
    
    @IBAction func tooltipButtonPressed(_ sender: UIButton) {
        showBalanceInfo()
    }
    
    @IBAction func didTapRetentionsButton(_ sender: Any) {
        showRetentionsInfo()
    }
    
    @objc private func showBalanceInfo() {
        eventDelegate?.showBalanceInfo { (title, description) in
            toolTipDelegate?.displayPermanentToolTip(with: title, descriptionLocalized: description, inView: self, withSourceRect: tooltipButton.frame, forcedDirection: nil)
        }
    }
    
    @objc private func showRetentionsInfo() {
        dynamicToolTipDelegate?.displayDynamicPermanentToolTip(inView: self, withSourceRect: self.retentionsButton.frame, forcedDirection: .up)
        eventDelegate?.showRetentionsInfo { [weak self] (title, description) in
            self?.dynamicToolTipDelegate?.setTooltipTitleAndDescription(title: title ?? .empty, description: description ??  "")
        }
    }
}

extension ProductAccountCollectionViewCell: ConfigurableCell {
    func configure(data: ProductAccountHeader) {
        eventDelegate = data.cellEventsHandler
        title = data.title
        
        guard let retentionsTitle = data.styleRetentionsTitle else {
            return
        }
        retentionsButton.setTitle(retentionsTitle.text, for: .normal)
        retentionsButton.titleLabel?.underline()
        
        guard let realBalanceTitle = data.styleRealAmountTitle else {
            return
        }
        realBalanceLabel.set(localizedStylableText: realBalanceTitle)
        
        guard let availableBalanceTitle = data.styleAvailableAmountTitle else {
            return
        }
        availableBalanceLabel.set(localizedStylableText: availableBalanceTitle)
        
        availableBalance = data.amount?.getFormattedAmountUIWith1M()
        realBalance = data.realAmount?.getFormattedAmountUIWith1M()
        
        copyButtonCoachmarkId = data.copyButtonCoachmarkId
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
    }
}
