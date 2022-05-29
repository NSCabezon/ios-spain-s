//

import UIKit
import UI

protocol StockDetailPresenterProtocol {
    var contentTitle: LocalizedStylableText { get }
    var moreInfo: LocalizedStylableText { get }
    var cancelOrder: LocalizedStylableText { get }
    
    func buyButtonTouched()
    func sellButtonTouched()
    func toggleSideMenu()
}

public enum StockDetailImageType: String {
    case icnBag
}

class StockDetailViewController: BaseViewController<StockDetailPresenterProtocol> {

    @IBOutlet weak var upperContentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stockNameLabel: UILabel!
    @IBOutlet weak var stockValueLabel: UILabel!
    @IBOutlet weak var stockArrow: UIImageView!
    @IBOutlet weak var stockVariationLabel: UILabel!
    @IBOutlet weak var currentStockSharesContainer: UIView!
    @IBOutlet weak var currentStockImage: UIImageView!
    @IBOutlet weak var currentStockLabel: UILabel!
    @IBOutlet weak var currentStockSeparator: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lowerContentView: UIView!
    @IBOutlet weak var rmvLoadingView: UIImageView!
    @IBOutlet weak var rmvTableView: UITableView!
    @IBOutlet weak var rmvTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButton: RedWhiteButton!
    @IBOutlet weak var sellButton: RedWhiteButton!
    
    let indexLabel = "[index]"

    var buyButtonTitle: LocalizedStylableText? {
        didSet {
            if let text = buyButtonTitle {
                buyButton.set(localizedStylableText: text, state: .normal)
            } else {
                buyButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    var sellButtonTitle: LocalizedStylableText? {
        didSet {
            if let text = sellButtonTitle {
                sellButton.set(localizedStylableText: text, state: .normal)
            } else {
                sellButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    var dateLabelText: String {
        get {
            return dateLabel.text ?? ""
        }
        set {
            dateLabel.text = newValue
        }
    }
    
    var stockNameLabelText: String {
        get {
            return stockNameLabel.text ?? ""
        }
        set {
            stockNameLabel.text = newValue
        }
    }
    
    var stockValueLabelText: String {
        get {
            return stockValueLabel.text ?? ""
        }
        set {
            stockValueLabel.text = newValue
            stockValueLabel.scaleDecimals()
        }
    }
    
    func setVariation (variation: String?, compareZero: ComparisonResult) {
        stockArrow.setVariation(variation: variation, compareZero: compareZero)
        stockVariationLabel.setVariation(variation: variation, compareZero: compareZero)
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
            tableViewHeightConstraint.constant = tableView.contentSize.height
            currentStockSeparator.isHidden = false
        }
    }
    
    var rmvSections: [TableModelViewSection] = [] {
        didSet {
            rmvDataSource.addSections(rmvSections)
            rmvTableView.reloadData()
            rmvTableView.layoutIfNeeded()
            rmvTableViewHeightConstraint.constant = rmvTableView.contentSize.height
        }
    }
    
    var buttonsHidden: Bool {
        get {
            if let container = self.buyButton.superview {
                return container.isHidden
            }
            return false
        }
        set {
            if let container = self.buyButton.superview {
                container.isHidden = newValue
                buttonsContainerHeightConstraint.constant = newValue ? 0 : 80
            }
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    private lazy var rmvDataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    override class var storyboardName: String {
        return "StockDetail"
    }
    
    override func prepareView() {
        super.prepareView()
        
        self.setupAccessibilityIds()
        
        upperContentView.drawRoundedAndShadowed()
        dateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16), textAlignment: .center))
        stockNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16), textAlignment: .center))
        stockValueLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoMedium(size: 48), textAlignment: .right))
        stockVariationLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .left))
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "StockDetailInfoWithoutImageTableViewCell", bundle: .module), forCellReuseIdentifier: "StockDetailInfoWithoutImageTableViewCell")
        tableView.register(UINib(nibName: "StockDetailInfoTwoElementsTableViewCell", bundle: .module), forCellReuseIdentifier: "StockDetailInfoTwoElementsTableViewCell")
        tableView.register(UINib(nibName: "StockDetailInfoOneElementTableViewCell", bundle: .module), forCellReuseIdentifier: "StockDetailInfoOneElementTableViewCell")
        tableView.backgroundColor = .clear
        tableView.dataSource = dataSource
        tableView.isScrollEnabled = false
        
        rmvTableView.separatorStyle = .none
        rmvTableView.register(UINib(nibName: "StockDetailRMVTableViewCell", bundle: .module), forCellReuseIdentifier: "StockDetailRMVTableViewCell")
        rmvTableView.backgroundColor = .clear
        rmvTableView.dataSource = rmvDataSource
        rmvTableView.isScrollEnabled = false

        loadingView.isHidden = true
        rmvLoadingView.isHidden = true
    }
    
    func setupAccessibilityIds() {
        self.navigationBarTitleLabel.accessibilityIdentifier = "toolbar_title_stocksDetail"
    }
    
    public func configureTwoButtons() {
        buyButton.configureHighlighted(font: .latoMedium(size: 14), isRed: false)
        sellButton.configureHighlighted(font: .latoMedium(size: 14))
    }
    
    public func configureOneButton(type: OrderType) {
        let buttonToShow: RedWhiteButton
        let buttonToHide: RedWhiteButton
        switch type {
        case .buy:
            buttonToShow = buyButton
            buttonToHide = sellButton
        case .sale:
            buttonToShow = sellButton
            buttonToHide = buyButton
        }
        buttonToShow.configureHighlighted(font: .latoMedium(size: 16), isRed: true)
        buttonToHide.isHidden = true
    }
    
    func setEmptyCurrentStockShares() {
        currentStockLabel.text = nil
        currentStockImage.image = nil
    }
    
    public func setCurrentStockShares(titleInfo: LocalizedStylableText, imageType: StockDetailImageType) {
        currentStockLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoRegular(size: 16),
                                           textAlignment: .left))
        currentStockLabel.set(localizedStylableText: titleInfo)
        currentStockImage.contentMode = .scaleAspectFit
        currentStockImage.image = Assets.image(named: imageType.rawValue)
        currentStockSeparator.isHidden = true
    }
    
    func onDetailLoadError() {
        self.loadingView.isHidden = true
        self.loadingView.removeLoader()
        self.tableView.isHidden = true
        self.tableViewHeightConstraint.constant = tableView.contentSize.height
        self.dateLabelText = ""
    }
    
    func onRMVLoadError() {
        self.rmvLoadingView.isHidden = true
        self.rmvLoadingView.removeLoader()
        self.rmvTableView.isHidden = true
        self.rmvTableViewHeightConstraint.constant = rmvTableView.contentSize.height
    }
    
    public func setLoadingViewVisibility(visible: Bool) {
        if visible {
            self.loadingView.isHidden = false
            self.loadingView.setSecondaryLoader(scale: 2.0)
            self.tableView.isHidden = true
        } else {
            self.loadingView.isHidden = true
            self.loadingView.removeLoader()
            self.tableView.isHidden = false
        }
    }
    
    public func setRMVLoadingViewVisibility(visible: Bool) {
        if visible {
            self.rmvLoadingView.isHidden = false
            self.rmvLoadingView.setSecondaryLoader(scale: 2.0)
            self.rmvTableView.isHidden = true
        } else {
            self.rmvLoadingView.isHidden = true
            self.rmvLoadingView.removeLoader()
            self.rmvTableView.isHidden = false
        }
    }
    
    override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @IBAction func onBuyButtonClick(_ sender: Any) {
        presenter.buyButtonTouched()
    }
    
    @IBAction func onSellButtonClick(_ sender: Any) {
        presenter.sellButtonTouched()
    }
}
