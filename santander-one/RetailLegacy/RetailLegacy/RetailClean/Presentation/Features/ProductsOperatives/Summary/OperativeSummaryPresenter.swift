import CoreFoundationLib
import Operative
import PdfCommons

protocol MadridOperativeSummaryPresenterProtocol {
    var shareView: ShareViewController { get }
    func opinatorButtonTouched()
    func pdfButtonTouched()
    func continueButtonTouched()
}

class OperativeSummaryPresenter: OperativeStepPresenter<MadridOperativeSummaryViewController, OperativeSummaryNavigatorProtocol, MadridOperativeSummaryPresenterProtocol> {
    private let pdfCreator = PDFCreator()
    var candidateLocations: [PullOfferLocation: Offer] = [:]
    var offerConditions: [PullOfferLocation: Bool] = [:]
    var sharingText: String!
    var sharePresenter: SharePresenter! {
        didSet {
            sharePresenter.delegate = self
        }
    }
    
    var locations: [PullOfferLocation] {
        return []
    }
    
    override var shouldShowProgress: Bool {
        return false
    }
    
    // MARK: - Tracks
    override var screenId: String? {
        return container?.operative.screenIdSummary
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersSummary()
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        let title = stringLoader.getString("genericToolbar_title_summary")
        view.styledTitle = title
        view.titleIdentifier = AccessibilityOthers.summaryNavTitle.rawValue
        view.navigationBarTitleLabel.accessibilityIdentifier = AccessibilityOthers.summaryNavTitle.rawValue
        guard let container = container else { return }
        let operative = container.operative
        let isOpinator = operative.opinatorPage != nil
        let isPdf = operative.pdfContent != nil
        switch (isOpinator, isPdf) {
        case (false, false):
            view.notShowOpinatorAndPdf()
        case (true, true):
            view.showOpinatorAndPdf(opinator: stringLoader.getString("generic_button_improve"),
                                    pdf: stringLoader.getString("generic_label_seePdf"))
        case (false, true):
            view.showPdf(title: stringLoader.getString("generic_label_seePdf"))
        case (true, false):
            view.showOpinator(title: stringLoader.getString("generic_button_improve"))
        }
        
        view.continueButtonTitle = operative.getSummaryContinueButtonText() ?? stringLoader.getString("generic_button_continue")
        view.summaryTitle = operative.getSummaryTitle()
        view.summarySubtitle = operative.getSummarySubtitle()
        var info = [SummaryItemData]()
        if let data = operative.getSummaryInfo() {
            info = data
        }
        sharingText = info.reduce("", { (text, data) in
            if data.isShareable {
                return (text ?? "") + data.description + "\n"
            } else {
                return text
            }
        })
        
        if let subtitle = operative.getSummarySubtitle() {
            sharingText = operative.getSummaryTitle().text + "\n" + subtitle.text + "\n\n" + sharingText
        } else {
            sharingText = operative.getSummaryTitle().text + "\n\n" + sharingText
        }
        
        view.summaryInfo = getSummaryItems(from: info)
        if operative.isShareable {
            view.addSharingView()
        }
        view.additionalMessage = operative.getAdditionalMessage()
        
        switch operative.getSummaryState() {
        case .success:
            view.summaryIconImage = "icnCircleCheckOk"
            HapticTrigger.operativeSuccess()
        case .error:
            view.summaryIconImage = "circleKo"
            HapticTrigger.operativeError()
        case .pending:
            view.summaryIconImage = "circlePending"
            HapticTrigger.operativeError()
        }
        loadLocations()
    }
    
    func onLoadedLocations() {
        view.addLocations(buildLocations())
    }
    
    private func getSummaryItems(from info: [SummaryItemData]) -> [SummaryItem] {
        return info.map { $0.createSummaryItem() }
    }
}

extension OperativeSummaryPresenter: Presenter {}

extension OperativeSummaryPresenter: MadridOperativeSummaryPresenterProtocol {
    var shareView: ShareViewController {
        let shareIdentifiers = ShareIdentifiers(iconSMS: AccessibilityMobileRecharge.summaryBtnSMSIcon.rawValue,
                                                labelSMS: AccessibilityMobileRecharge.summaryBtnSMSLabel.rawValue,
                                                containerSMS: AccessibilityMobileRecharge.summaryBtnSMSContainer.rawValue,
                                                iconMail: AccessibilityMobileRecharge.summaryBtnMailIcon.rawValue,
                                                labelMail: AccessibilityMobileRecharge.summaryBtnMailLabel.rawValue,
                                                containerMail: AccessibilityMobileRecharge.summaryBtnMailContainer.rawValue,
                                                iconShare: AccessibilityMobileRecharge.summaryBtnShareIcon.rawValue,
                                                labelShare: AccessibilityMobileRecharge.summaryBtnShareLabel.rawValue,
                                                containerShare: AccessibilityMobileRecharge.summaryBtnShareContainer.rawValue)
        self.sharePresenter.setIdentifiers(shareIdentifiers)
        return sharePresenter.view
    }
    
    func opinatorButtonTouched() {
        guard let container = container, let opinatorPage = container.operative.opinatorPage else {
            return
        }
        self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.OtpPushOperativeSummary().page,
                                                    eventId: TrackerPagePrivate.OtpPushOperativeSummary.Action.helpToImprove.rawValue,
                                                    extraParameters: [:])
        openOpinator(forRegularPage: opinatorPage,
                     onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func continueButtonTouched() {
        container?.stepFinished(presenter: self)
    }
    
    func pdfButtonTouched() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        guard let html = container?.operative.pdfContent, let title = container?.operative.pdfTitle else {
            return
        }
        let pdfSource: PdfSource = container?.operative.pdfSource ?? .summary
        let parameters = getExtraTrackShareParameters() ?? [:]
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.pdf.rawValue, parameters: parameters)
        pdfCreator.createPDF(html: html, completion: { [weak self]  data in
            self?.hideAllLoadings {
                self?.navigator.goToPdf(with: data, title: title, pdfSource: pdfSource)
            }
        }, failed: { [weak self] in
            self?.hideAllLoadings {
                self?.showError(keyDesc: nil)
            }
        })
    }
}

extension OperativeSummaryPresenter: ShareDelegate {
    
    func getRichStringToShare() -> String? {
        return container?.operative.getRichSharingText()
    }
    
    func getStringToShare() -> String? {
        return sharingText
    }
    
    func getExtraTrackShareParameters() -> [String: String]? {
        return container?.operative.getExtraTrackShareParametersSummary()
    }
}

extension OperativeSummaryPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

extension OperativeSummaryPresenter: LocationsResolver, PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
    
    func loadLocations() {
        getCandidateOffers { [weak self] offers in
            guard let self = self else { return }
            self.candidateLocations = offers
            self.onLoadedLocations()
        }
    }
    
    private func buildLocations() -> [OperativeSummaryStandardLocationViewModel] {
        var entityOffers: [PullOfferLocation: OfferEntity] = [:]
        for (location, offer) in candidateLocations {
            entityOffers[location] = OfferEntity(offer.dto, location: location)
        }
        let builder = OperativeSummaryStandardLocationBuilder(offers: entityOffers, offerConditions: offerConditions)
        builder.addPaymentLocation(forceLabelsHeight: true,
                                   executeOfferAction: { [weak self] offer in
                                    self?.executeOffer(action: offer.action, offerId: offer.id, location: offer.location)
        })
        return builder.build()
    }
}
