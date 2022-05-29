import CoreFoundationLib

protocol HistoricalDispensationDetailPresenterDelegate: class {
    func userDidTouchCancel()
}

class HistoricalDispensationDetailPresenter: PrivatePresenter<HistoricalDispensationDetailViewController, VoidNavigator, HistoricalDispensationDetailPresenterProtocol> {
    let dispensationDetailInfo: (ProductDetailInfoPresenter & ProductDetailProfileSeteable)
    var dispensation: Dispensation?
    var card: Card?
    var cardDetail: CardDetail?
    var account: Account?
    weak var delegate: HistoricalDispensationDetailPresenterDelegate?
    
    init(dispositionDetailInfo: (ProductDetailInfoPresenter & ProductDetailProfileSeteable), dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: VoidNavigator) {
        self.dispensationDetailInfo = dispositionDetailInfo
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        barButtons = [.close]
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.HistoricCashWithdrawlCodeDetail().page
    }

    override func loadViewData() {
        super.loadViewData()
        
        guard let dispensation = dispensation, let card = card, let cardDetail = cardDetail else {
            return
        }
        
        dispensationDetailInfo.productDetailProfile = DispensationDetailProfile(dispensation: dispensation, card: card, cardDetail: cardDetail, account: account, errorHandler: genericErrorHandler, dependencies: dependencies, shareDelegate: self)
        view.styledTitle = dispensationDetailInfo.productDetailProfile?.productTitle
    }
}

extension HistoricalDispensationDetailPresenter: HistoricalDispensationDetailPresenterProtocol {}

extension HistoricalDispensationDetailPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        delegate?.userDidTouchCancel()
    }
}
