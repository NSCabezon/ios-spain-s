import CoreFoundationLib

class TransactionDetailPresenter: PrivatePresenter<TransactionDetailViewController, TransactionDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol, TransactionDetailPresenterProtocol> {
    
    let sharePresenter: SharePresenter
    var transactionDetailProfile: TransactionDetailProfile?

    var locations: [PullOfferLocation] {
        return transactionDetailProfile?.locations ?? []
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return transactionDetailProfile?.screenId
    }

    // MARK: -

    private var presenterOffers: [PullOfferLocation: Offer] = [:]

    init(share: SharePresenter, profile: TransactionDetailProfile, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: TransactionDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol) {
        self.sharePresenter = share
        self.transactionDetailProfile = profile
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        transactionDetailProfile?.completionActions = { [weak self] actions in
            self?.view.setActions(actions)
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        sharePresenter.delegate = self
        view.getInfo()
        
        if let location = transactionDetailProfile?.getLocation() {
             getCandidateOffers { [weak self] candidates in
                guard let strongSelf = self else { return }
                strongSelf.presenterOffers = candidates
                self?.transactionDetailProfile?.candidatesLocations(candidates)
                if let offer = candidates[location], let url = offer.banners.first?.url {
                    strongSelf.trackEvent(eventId: TrackerPagePrivate.Generic.Action.seeOffer.rawValue,
                                          parameters: [TrackerDimensions.offerId: offer.id ?? "",
                                                       TrackerDimensions.location: location.stringTag])
                    let model = ImageBannerViewModel(url: url, rightInset: 4, bottomInset: 4, isClosable: false, isRounded: true, actionDelegate: strongSelf, dependencies: strongSelf.dependencies)
                    model.configureView(in: strongSelf.view.bannerContainer)
                } else {
                    strongSelf.view.hideBannerView()
                }
                strongSelf.buttonTitle { [weak self] (text) in
                    self?.view.setButtonTitle(text)
                }
            }
        } else {
            view.hideBannerView()
            buttonTitle { [weak self] (text) in
                self?.view.setButtonTitle(text)
            }
        }
        
        transactionDetailProfile?.requestTransactionDetail(completion: { [weak self] (transactionDetailInfo) in
            guard let strongSelf = self else { return }
            strongSelf.view.loadedConfiguration()
            if let transactionDetailInfo = transactionDetailInfo {
                strongSelf.view.loadAllInfo(info: transactionDetailInfo)
            }
        })
    }
    
    func startLoading() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
}

extension TransactionDetailPresenter: Presenter {}
    
extension TransactionDetailPresenter: LocationsResolver {}

extension TransactionDetailPresenter: LocationBannerDelegate {
    
    func finishDownloadImage(newHeight: Float?) {
        view.onDrawFinished(newHeight: newHeight)
    }
    
    func selectedBanner() {
        if let location = transactionDetailProfile?.getLocation(), let offer = presenterOffers[location] {
            guard let offerAction = offer.action else { return }

            trackEvent(eventId: TrackerPagePrivate.Generic.Action.inOffer.rawValue,
                       parameters: [TrackerDimensions.offerId: offer.id ?? "",
                                    TrackerDimensions.location: location.stringTag])
            
            executeOffer(action: offerAction, offerId: offer.id, location: location)
        }
    }
}

extension TransactionDetailPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension TransactionDetailPresenter: TransactionDetailPresenterProtocol {
    
    func actionButton() {
        transactionDetailProfile?.actionButton()
    }
    
    func buttonTitle(completion: @escaping (LocalizedStylableText?) -> Void) {
        transactionDetailProfile?.actionTitle(completion: completion)
    }
    
    var sideTextTitle: LocalizedStylableText? {
        return transactionDetailProfile?.sideTitleText
    }
    
    var sideTextDescription: LocalizedStylableText? {
        return transactionDetailProfile?.sideDescriptionText
    }
    
    var pdfButtonText: LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_pdf")
    }
        
    var share: SharePresenter {
        return sharePresenter
    }
    
    var title: String? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let title = profile.title else { return nil }
        return title
    }
    
    var alias: String? {
        guard let profile = transactionDetailProfile else { return nil}
        guard let alias = profile.alias else { return nil }
        return alias.uppercased()
    }
    
    var amount: String? {
        guard let profile = transactionDetailProfile else { return nil}
        guard let amount = profile.amount else { return nil }
        return amount
    }
    
    var showSeePdf: Bool? {
        guard let profile = transactionDetailProfile else { return nil }
        return profile.showSeePdf
    }
    
    var titleLeft: LocalizedStylableText? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let titleLeft = profile.titleLeft else { return nil }
        return titleLeft
    }
    
    var infoLeft: String? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let infoLeft = profile.infoLeft else { return nil }
        return infoLeft
    }
    
    var titleRight: LocalizedStylableText? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let titleRight = profile.titleRight else { return nil }
        return titleRight
    }
    
    var infoRight: String? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let infoRight = profile.infoRight else { return nil }
        return infoRight
    }
    
    var nonDetailRows: [TransactionLine]? {
        return transactionDetailProfile?.nonDetailRowsToAppend
    }
    
    var singleInfoTitle: LocalizedStylableText? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let singleInfoTitle = profile.singleInfoTitle else { return nil }
        return singleInfoTitle
    }
    
    var balance: String? {
        guard let profile = transactionDetailProfile else { return nil }
        guard let balance = profile.balance else { return nil }
        return balance
    }
    
    var showLoading: Bool? {
        guard let profile = transactionDetailProfile else { return nil }
        return profile.showLoading
    }
    var showActions: Bool? {
        guard let profile = transactionDetailProfile else { return nil }
        return profile.showActions
    }
    
    var showShare: Bool? {
        guard let profile = transactionDetailProfile else { return nil }
        return profile.showShare
    }
    
    var stringToShare: String? {
        guard let profile = transactionDetailProfile else { return nil }
        return profile.stringToShare()
    }
    
    var showStatus: Bool? {
        guard let fundProfile = transactionDetailProfile as? FundTransactionProfileProtocol else { return false }
        return fundProfile.isShowStatus
    }
    
    var status: LocalizedStylableText? {
        guard let fundProfile = transactionDetailProfile as? FundTransactionProfileProtocol, let status = fundProfile.status else { return nil }
        return status
    }
    
    func pdfDidTouched() {
        guard let profile = transactionDetailProfile else { return }
        startLoading()
        
        profile.seePDFDidTouched { [weak self] (document, error, pdfSource) in
            self?.endLoading {
                guard let document = document else {
                    self?.showError(keyDesc: error?.getErrorDesc())
                    return
                }
                self?.navigator.goToPdfViewer(pdfData: document, pdfSource: pdfSource)
            }
        }
    }
}

extension TransactionDetailPresenter: ShareDelegate {
    func getStringToShare() -> String? {
        return stringToShare
    }
}

extension TransactionDetailPresenter: GenericTransactionDelegate {
    func reloadAlias() {
        view.reloadAlias()
    }
}
