//

import UIKit
import UI

class StockViewCell: BaseViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var labelName: UILabel!
    @IBOutlet private weak var labelTitles: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelChangeInfo: UILabel!
    @IBOutlet private weak var labelChange: UILabel!
    @IBOutlet private weak var imageChange: UIImageView!
    @IBOutlet private weak var buttonBuy: StateButton!
    @IBOutlet private weak var buttonSell: StateButton!
    @IBOutlet private weak var managedPortfolioLabel: UILabel!
    @IBOutlet private var viewsExtraInfo: [UIView]!
    @IBOutlet private weak var loadingView: UIImageView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    private var state: StockState?
    private let indexLabel = "[index]"
    
    public var managedPortfolioText: LocalizedStylableText? {
        didSet {
            if let text = managedPortfolioText {
                managedPortfolioLabel.set(localizedStylableText: text)
            }
        }
    }
    
    public var isManaged: Bool = false {
        didSet {
            updateManagedState()
        }
    }
    
    public var isBuyActive: Bool = false {
        didSet {
            updateManagedState()
        }
    }
    
    public var isSellActive: Bool = false {
        didSet {
            updateManagedState()
        }
    }
    
    public var isDetailLoaded: Bool = false {
        didSet {
            updateManagedState()
        }
    }
    
    private func updateManagedState() {

        if state == .done || state == .error {
            managedPortfolioLabel.isHidden = !isManaged
            buttonBuy.isHidden = !isBuyActive || !isDetailLoaded
            buttonSell.isHidden = !isSellActive || !isDetailLoaded
            containerHeightConstraint.constant = (isBuyActive && isDetailLoaded) || (isSellActive && isDetailLoaded) || isManaged ? 170 : 110
        } else {
            managedPortfolioLabel.isHidden = true
            buttonBuy.isHidden = true
            buttonSell.isHidden = true
            containerHeightConstraint.constant = 170
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 5
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lisboaGray.cgColor
        containerView.layer.masksToBounds = false
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.uiBlack.withAlphaComponent(0.5).cgColor
        containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        buttonBuy.layer.cornerRadius = 15
        buttonBuy.clipsToBounds = true
        buttonSell.layer.cornerRadius = 15
        buttonSell.clipsToBounds = true
        labelName.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 14)))
        labelTitles.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 13)))
        let size: CGFloat = UIScreen.main.isIphone4or5 ? 33: 37
        labelAmount.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: size)))
        labelChangeInfo.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: 13), textAlignment: .right))
        labelChange.applyStyle(LabelStylist(textColor: .uiBlack, font: UIFont.latoRegular(size: 16), textAlignment: .right))
        let styleButton = ButtonStylist(textColor: .sanRed, font: UIFont.latoSemibold(size: 13), borderColor: .sanRed, borderWidth: 1, backgroundColor: .uiWhite)
        let styleButtonSelected = ButtonStylist(textColor: .uiWhite, font: UIFont.latoSemibold(size: 13), borderColor: .sanRed, borderWidth: 1, backgroundColor: .sanRed)
        buttonBuy.applyHighlightedStylist(normal: styleButton, selected: styleButtonSelected)
        buttonSell.applyHighlightedStylist(normal: styleButton, selected: styleButtonSelected)
        managedPortfolioLabel.applyStyle(LabelStylist(textColor: .darkGray, font: .latoSemibold(size: 13), textAlignment: .center))
        updateManagedState()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonSell.removeTarget(nil, action: nil, for: .allEvents)
        buttonBuy.removeTarget(nil, action: nil, for: .allEvents)
        containerHeightConstraint.constant = 170
    }

    var name: String? {
        get {
            return labelName.text
        }
        set {
            labelName.text = newValue
        }
    }
    
    // MARK: - Public Methods
    
    func setState (state: StockState) {
        self.state = state
        switch state {
        case .loading:
            showLoading()
            hideExtraInfo()
        case .done:
            hideLoading()
            showExtraInfo()
        case .error:
            hideLoading()
            hideExtraInfo()
        }
        
        updateManagedState()
    }
    
    func setTitles (titles: LocalizedStylableText) {
        labelTitles.set(localizedStylableText: titles)
    }
    
    func setVariation (variation: String?, info: LocalizedStylableText, compareZero: ComparisonResult) {
        imageChange.setVariation(variation: variation, compareZero: compareZero)
        labelChange.setVariation(variation: variation, compareZero: compareZero, withParenthesis: true)
        if variation == nil {
            labelChangeInfo.isHidden = true
        }
        labelChangeInfo.set(localizedStylableText: info)
    }
    
    func setAmount (amount: String?) {
        labelAmount.text = amount
        labelAmount.scaleDecimals()
    }
    
    func setTitleLeftButton(text: LocalizedStylableText, selector: Selector, target: Any) {
        buttonBuy.set(localizedStylableText: text, state: .normal)
        buttonBuy.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func setTitleRightButton(text: LocalizedStylableText, selector: Selector, target: Any) {
        buttonSell.set(localizedStylableText: text, state: .normal)
        buttonSell.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    // MARK: - Private Methods
    
    private func showLoading () {
        loadingView.setSecondaryLoader(scale: 2.0)
        loadingView.isHidden = false
    }
    
    private func hideLoading () {
        loadingView.removeLoader()
        loadingView.isHidden = true
    }
    
    private func hideExtraInfo () {
        for view in viewsExtraInfo {
            view.isHidden = true
        }
    }
    
    private func showExtraInfo () {
        for view in viewsExtraInfo {
            view.isHidden = false
        }
    }
}
