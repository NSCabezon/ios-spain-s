import UIKit

protocol TransactionDetailPresenterProtocol {
    var share: SharePresenter { get }
    var pdfButtonText: LocalizedStylableText? { get }
    var title: String? { get }
    var alias: String? { get }
    var amount: String? { get }
    var showSeePdf: Bool? { get }
    var titleLeft: LocalizedStylableText? { get }
    var infoLeft: String? { get }
    var titleRight: LocalizedStylableText? { get }
    var infoRight: String? { get }
    var singleInfoTitle: LocalizedStylableText? { get }
    var balance: String? { get }
    var showLoading: Bool? { get }
    var showActions: Bool? { get }
    var showShare: Bool? { get }
    var stringToShare: String? { get }
    var showStatus: Bool? { get }
    var nonDetailRows: [TransactionLine]? { get }
    var status: LocalizedStylableText? { get }
    var sideTextTitle: LocalizedStylableText? { get }
    var sideTextDescription: LocalizedStylableText? { get }
    func actionButton()
    func pdfDidTouched()
}

class TransactionDetailViewController: BaseViewController<TransactionDetailPresenterProtocol> {
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var transactionInfoView: DetailTransactionInfoView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareView: UIView!
    private lazy var buttonStackView: ButtonStackView = {
        let buttonStackView = ButtonStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return buttonStackView
    }()
    
    override class var storyboardName: String {
        return "TransactionDetail"
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiBackground
        customContentView.backgroundColor = .uiBackground
        bannerContainer.backgroundColor = .clear
        bannerContainer.clipsToBounds = false
        setShare(viewController: presenter.share.view)
        
        transactionInfoView.loadingView.setSecondaryLoader(scale: 2.0)
        transactionInfoView.loadingViewContainer.isHidden = true
        
        hideActions()
        shareView.isHidden = true
        
        transactionInfoView.statusLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: UIFont.latoRegular(size: 14), textAlignment: .center))
        transactionInfoView.statusLabel.backgroundColor = .sanGreyMedium
        transactionInfoView.statusLabel.layer.cornerRadius = 3
        transactionInfoView.sideTextTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14.0), textAlignment: .right))
        transactionInfoView.sideTextDescriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoItalic(size: 12.0), textAlignment: .right))
        transactionInfoView.sideTextDescriptionLabel.isHidden = true
        transactionInfoView.sideTextTitleLabel.isHidden = true       
        transactionInfoView.belowAmountButton.addTarget(self, action: #selector(buttonBelowAmountPressed), for: .touchUpInside)
        transactionInfoView.belowAmountButton.isHidden = true
        transactionInfoView.seePdf.isHidden = true
        
        transactionInfoView.delegate = self
        setupActionsView()
        
    }
        
    func setButtonTitle(_ buttonTitle: LocalizedStylableText?) {
        if let buttonTitle = buttonTitle {
            transactionInfoView.belowAmountButton?.set(localizedStylableText: buttonTitle, state: .normal)
            transactionInfoView.belowAmountButton.isHidden = false
        }
    }

    func setupActionsView() {
        buttonStackView.embedInto(container: actionsView)
    }
    
    func hideBannerView() {
        bannerHeightConstraint.constant = 0
        bannerContainer.isHidden = true
    }
    
    func getInfo() {
        if let text = presenter.pdfButtonText {
            transactionInfoView.seeLabel.set(localizedStylableText: text)
        } else {
            transactionInfoView.seeLabel.text = nil
        }
        transactionInfoView.transactionTitleLabel.text = presenter.title
        let titleSize: CGFloat = UIScreen.main.isIphone5 || UIScreen.main.isIphone4 ? 18 : 20
        transactionInfoView.transactionTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: titleSize), textAlignment: .left))
        
        transactionInfoView.aliasLabel.text = presenter.alias
        transactionInfoView.amountLabel.text = presenter.amount
        transactionInfoView.amountLabel.scaleDecimals()
        
        if let titleLeft = presenter.titleLeft, let infoLeft = presenter.infoLeft, let titleRight = presenter.titleRight, let infoRight = presenter.infoRight {
            let doubleLine = TransactionLine((titleLeft, infoLeft), (titleRight, infoRight))
            transactionInfoView.createInfoLine(info: doubleLine)
        }
        
        if let balance = presenter.balance, let singleInfoTitle = presenter.singleInfoTitle {
            let line = TransactionLine((singleInfoTitle, balance), nil)
            transactionInfoView.createInfoLine(info: line)
        }
        
        if let nonDetailRows = presenter.nonDetailRows {
            for line in nonDetailRows {
                let detailLine = TransactionLine(line.0, line.1)
                transactionInfoView.createInfoLine(info: detailLine)
            }
        }
        
        if let showLoading = presenter.showLoading {
            transactionInfoView.loadingViewContainer.isHidden = !showLoading
        }
        
        if let showActionsBool = presenter.showActions {
            showActionsBool ? showActions() : hideActions()
        }
        
        if let showShare = presenter.showShare {
            shareView.isHidden = !showShare
        }
    }
    
    func reloadAlias() {
        transactionInfoView.aliasLabel.text = presenter.alias
    }
    
    func loadAllInfo(info: [TransactionLine]) {
        if let sideTextTitle = presenter.sideTextTitle {
            transactionInfoView.sideTextTitleLabel.set(localizedStylableText: sideTextTitle)
            transactionInfoView.sideTextTitleLabel.isHidden = false
        }
        
        if let sideTextDescription = presenter.sideTextDescription {
            transactionInfoView.sideTextDescriptionLabel.set(localizedStylableText: sideTextDescription)
            transactionInfoView.sideTextDescriptionLabel.isHidden = false
        }
        
        if presenter.showStatus == true, let status = presenter.status {
            transactionInfoView.statusView.isHidden = false
            transactionInfoView.statusLabel.set(localizedStylableText: status)
        }
        
        for line in info {
            var infoLine = TransactionLine((line.0.title, line.0.info), nil)
            if let second = line.1 {
                infoLine.1 = second
            }
            transactionInfoView.createInfoLine(info: infoLine)
        }
    }
    
    func loadedConfiguration() {
        hideLoading()
        showShare()
        setupPDFIndicator()
    }
    
    func hideLoading() {
        transactionInfoView.loadingViewContainer.isHidden = true
    }
    
    func showActions() {
        actionsView.isHidden = false
    }
    
    func hideActions() {
        actionsView.isHidden = true
    }
    
    func showShare() {
        shareView.isHidden = false
    }
    
    func setupPDFIndicator() {
        if let showSeePdf = presenter.showSeePdf {
            transactionInfoView.seePdf.isHidden = !showSeePdf
        }
    }
    
    @objc private func buttonBelowAmountPressed() {
        presenter.actionButton()
    }

    func setActions(_ actions: [TransactionDetailActionType]) {
        buttonStackView.setOptions(actions)
    }

    private func setShare(viewController: UIViewController) {
        setViewController(viewController, to: .share)
    }
    
    func onDrawFinished(newHeight: Float?) {
        UIView.performWithoutAnimation {
            if let newHeight = newHeight, newHeight > 0 {
                self.bannerHeightConstraint.constant = CGFloat(newHeight)
                
                self.bannerContainer.setNeedsLayout()
                self.bannerContainer.layoutIfNeeded()
                self.bannerContainer.layoutSubviews()
            }
        }
    }
}

extension TransactionDetailViewController {
    
    enum ViewPosition {
        case actions
        case share
    }
    
    private func setViewController(_ viewController: UIViewController, to position: ViewPosition) {
        guard let newView = viewController.view,
            let destinationView = position == .actions ? actionsView : shareView else {
                return
        }
        addChild(viewController)
        newView.frame = destinationView.bounds
        destinationView.addSubview(newView)
        viewController.didMove(toParent: self)
    }
}

extension TransactionDetailViewController: DetailTransactionInfoViewDelegate {
    func seePdfDidTouched() {
        presenter.pdfDidTouched()
    }
}
