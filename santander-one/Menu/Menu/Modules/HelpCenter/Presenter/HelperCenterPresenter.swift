import Foundation
import CoreFoundationLib
import UI

protocol HelperCenterPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: HelperCenterViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectSearch()
    func didSelectDismiss()
    func didSelectTip(_ viewModel: HelpCenterTipViewModel)
    func didTapVirtualAssistantView(fromOtherConsultations: Bool)
    func didSelectEmergency(action: HelpCenterEmergencyAction, cancelTransferAlert: Bool)
    func didTapSimpleView(action: ContactsSimpleViewModelAction)
    func phoneCall(_ phone: String)
    func phoneCall(_ action: HelpCenterEmergencyAction, _ cancelAlert: Bool)
    func getPhone(action: HelpCenterEmergencyAction) -> String?
    func didTapGlobalSearch()
    func didSelectFaqView()
    func tipCollectionViewDidEndDecelerating()
    func didSelectUnderstandButton()
    func didSelectSeeAllTips()
    func didSelectProductOneVIP()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class HelperCenterPresenter {
    
    weak var view: HelperCenterViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var commercialSegmentEntity: CommercialSegmentEntity?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var coordinator: HelperCenterCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: HelperCenterCoordinatorProtocol.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var helpCenterUseCase: GetHelpCenterUseCase {
        return self.dependenciesResolver.resolve(for: GetHelpCenterUseCase.self)
    }
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().helpCenter
    }
    private var offers: [PullOfferLocation: OfferEntity] = [:]
    private var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    private var hasOneProductsUseCase: GetHasOneProductsUseCase {
        return self.dependenciesResolver.resolve(for: GetHasOneProductsUseCase.self)
    }
}

private extension HelperCenterPresenter {
    func loadHelpCenter() {
        UseCaseWrapper(
            with: helpCenterUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.commercialSegmentEntity = result.commercialSegment
                let faqsViewModel = self?.getHelpCenterFaqsViewModel(result)
                let contactsViewModel = self?.getHelpCenterContactsViewModel(result)
                let emergencyViewModel = self?.getHelpCenterEmergencyViewModel(result)
                let helpCenterTipviewModels = result.helpCenterTips?.map {
                    return HelpCenterTipViewModel($0, baseUrl: self?.baseUrlProvider.baseURL)
                }
                self?.view?.showView(faqsViewModel: faqsViewModel,
                                     contactsViewModel: contactsViewModel,
                                     emergencyViewModel: emergencyViewModel,
                                     helpCenter: helpCenterTipviewModels,
                                     offerDateOffer: self?.getOfficeDateLocationViewModel())
            }, onError: { [weak self] _ in
                self?.view?.hideLoadingView(nil)
        })
    }

    func getHelpCenterFaqsViewModel(_ result: GetHelpCenterUseCaseOkOutput) -> HelpCenterFaqsViewModel? {
        guard let faqsEntity = result.faqsEntity else { return nil }
        let faqItemsViewModels = faqsEntity.map(HelpCenterFaqItemViewModel.init)
        let isVirtualAssistantEnabled = result.enableVirtualAssistant ?? false
        let faqsViewModel = HelpCenterFaqsViewModel(isVirtualAssistantEnabled: isVirtualAssistantEnabled, faqs: faqItemsViewModels)
        return faqsViewModel
    }
    
    func getHelpCenterContactsViewModel(_ result: GetHelpCenterUseCaseOkOutput) -> HelpCenterContactsViewModel? {
        let enableChatInbenta = result.enableChatInbenta
        guard enableChatInbenta || result.commercialSegment?.contact?.superlinea != nil || result.commercialSegment?.contact?.whatsAppContact != nil else { return nil }
        var superlineViewModel: HelpCenterContactsSupelineViewModel?
        var whatsAppViewModel: HelpCenterContactsWhatsAppViewModel?
        if let superline = result.commercialSegment?.contact?.superlinea {
            superlineViewModel = HelpCenterContactsSupelineViewModel(title: superline.title, description: superline.desc, numbers: superline.numbers ?? [])
        }
        if let whatsAppContact = result.commercialSegment?.contact?.whatsAppContact {
            whatsAppViewModel = HelpCenterContactsWhatsAppViewModel(hint: whatsAppContact.hint)
        }
        let permanentAttentionViewModel = self.getPermanentAttentionViewModel()
        let addSuperline = result.isUserSPB || result.hasVipPlanProducts
        let hasProductOneVIPOffer = self.getOfferForLocation(HelpCenterConstants.helpCenterVIP) != nil
        let addProductOneVIP = (result.hasVipPlanProducts || result.isUserSPB || result.isUserSmart || result.isUserSelect) && hasProductOneVIPOffer
        return HelpCenterContactsViewModel(
            superline: addSuperline ? superlineViewModel : nil,
            whatsApp: whatsAppViewModel,
            permanetAttention: permanentAttentionViewModel,
            isChatEnabled: enableChatInbenta,
            isUserSmart: result.isUserSmart,
            isProductOneVIP: addProductOneVIP
        )
    }
    
    func getHelpCenterEmergencyViewModel(_ result: GetHelpCenterUseCaseOkOutput) -> HelpCenterEmergencyViewModel {
        let enableChatInbenta = result.enableChatInbenta
        let isFraudEnabled = result.commercialSegment?.contact?.fraudFeedback != nil
        let isSuperlineEnabled = result.commercialSegment?.contact?.superlinea != nil
        var stolenViewModel: HelpCenterEmergencyStolenViewModel?
        if let stolen = result.commercialSegment?.contact?.cardBlock {
            stolenViewModel = HelpCenterEmergencyStolenViewModel(title: stolen.title, description: stolen.desc, phones: stolen.numbers ?? [])
        }
        return HelpCenterEmergencyViewModel(
            stolen: stolenViewModel,
            isFraudEnabled: isFraudEnabled,
            isSuperlineEnabled: isSuperlineEnabled,
            isChatEnabled: enableChatInbenta
        )
    }
    
    func getOfficeDateLocationViewModel() -> ContactsSimpleViewModel? {
        guard let offer = self.getOfferForLocation(HelpCenterConstants.officeDate) else { return nil }
        return ContactsSimpleViewModel(title: localized("helpCenter_button_officeDate"), subtitle: localized("helpCenter_text_officeDate"), icon: "icnCalendar", action: .officeDate, offer: offer)
    }
    
    func getPermanentAttentionViewModel() -> PermanentAttentionViewModel? {
        guard let offer = self.getOfferForLocation(HelpCenterConstants.permanentAttention) else { return nil }
        return PermanentAttentionViewModel(offer: offer) { [weak self] offer in
            self?.coordinator.didSelectOffer(offer)
        }
    }
    
    func loadPullOffers(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: locations)),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }, onError: {_ in
                completion()
        })
    }
    
    func getOfferForLocation(_ location: String) -> OfferEntity? {
        return self.offers.location(key: location)?.offer
    }
    
    func trackAction(_ action: HelpCenterEmergencyAction, cancelTransferAlert: Bool = false) {
        switch action {
        case .cancelTransfer:
            trackEvent(.invalidateTransfer, parameters: [:])
        case .sendMoney:
            trackEvent(.sendMoney, parameters: [:])
        case .cash:
            trackEvent(.withdrawMoney, parameters: [:])
        case .cvv:
            trackEvent(.cvv, parameters: [:])
        case .pin:
            trackEvent(.pin, parameters: [:])
        case .blockSign:
            trackEvent(.multichannelSign, parameters: [:])
        case .stolenCard(let phone, let pos):
            guard let phoneNumber = getPhone(action: .stolenCard(phoneNumber: phone, phonePos: pos)) else { return }
            trackEvent(.call, parameters: [.tfno: phoneNumber])
        case .reportFraud:
            guard let phoneNumber = getPhone(action: .reportFraud) else { return }
            trackEvent(.call, parameters: [.tfno: phoneNumber])
        case .superlinea:
            guard let phoneNumber = getPhone(action: .superlinea) else { return }
            if cancelTransferAlert { // from call button in cancel transfer alert
                trackerManager.trackEvent(screenId: CancelTransferHelpCenterPage().page, eventId: CancelTransferHelpCenterPage.Action.call.rawValue, extraParameters: [TrackerDimension.tfno.key: phoneNumber])
            } else {
                trackEvent(.call, parameters: [.tfno: phoneNumber])
            }
        default:
            break
        }
    }
}

extension HelperCenterPresenter: HelperCenterPresenterProtocol {
    func didTapVirtualAssistantView(fromOtherConsultations: Bool) {
        let event: HelpCenterPage.Action = fromOtherConsultations ? .otherConsultations : .virtualAssistant
        trackEvent(event, parameters: [:])
        coordinator.goToWebview()
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.view?.showLoadingView { [weak self] in
            self?.loadData()
        }
    }

    private func loadData() {
        self.loadPullOffers { [weak self] in
            self?.loadHelpCenter()
        }
    }

    func didSelectTip(_ viewModel: HelpCenterTipViewModel) {
        trackEvent(.tip, parameters: [:])
        coordinator.didSelectOffer(viewModel.entity.offer)
    }
    
    func didSelectSeeAllTips() {
        trackEvent(.allTips, parameters: [:])
        self.coordinator.goToHomeTips()
    }
    
    func didSelectMenu() {
        coordinator.didSelectMenu()
    }
    
    func didSelectDismiss() {
        coordinator.didSelectDismiss()
    }
    
    func didSelectSearch() {
        coordinator.didSelectSearch()
    }
    
    func didSelectEmergency(action: HelpCenterEmergencyAction, cancelTransferAlert: Bool = false) {
        trackAction(action, cancelTransferAlert: cancelTransferAlert)
        switch action {
        case .cancelTransfer:
            guard let phoneNumber = getPhone(action: .cancelTransfer) else { return }
            self.view?.cancelTransfer(phoneNumber)
        case .pin, .cvv, .cash, .sendMoney, .blockSign, .chat, .changeMagic:
            coordinator.didSelectEmergency(action: action)
        case .stolenCard(let phone, let pos):
            guard let phoneNumber = getPhone(action: .stolenCard(phoneNumber: phone, phonePos: pos)) else { return }
            coordinator.goToPhoneCall(phoneNumber)
        case .reportFraud:
            guard let phone = getPhone(action: .reportFraud) else { return }
            coordinator.goToPhoneCall(phone)
        case .superlinea:
            guard let phone = getPhone(action: .superlinea) else { return }
            coordinator.goToPhoneCall(phone)
        }
    }
    
    func didTapSimpleView(action: ContactsSimpleViewModelAction) {
        switch action {
        case .whatsapp:
            guard let phone = commercialSegmentEntity?.contact?.whatsAppContact?.appURL,
                let url = URL(string: phone) else { return }
            trackEvent(.whatsapp, parameters: [:])
            coordinator.goToWhatsapp(url)
        case .chat:
            coordinator.didSelectEmergency(action: .chat)
        case .officeDate:
            let offer = self.getOfferForLocation(HelpCenterConstants.officeDate)
            self.coordinator.didSelectOffer(offer)
        }
    }
    
    func phoneCall(_ phone: String) {
        trackEvent(.call, parameters: [.tfno: phone])
        coordinator.goToPhoneCall(phone)
    }
    
    func phoneCall(_ action: HelpCenterEmergencyAction, _ cancelAlert: Bool) {
        didSelectEmergency(action: action, cancelTransferAlert: cancelAlert)
    }
    
    func getPhone(action: HelpCenterEmergencyAction) -> String? {
        switch action {
        case .superlinea:
            return commercialSegmentEntity?.contact?.superlinea?.numbers?.first
        case .reportFraud:
            return commercialSegmentEntity?.contact?.fraudFeedback?.numbers?.first
        case .stolenCard:
            return nil
        case .cancelTransfer:
            return commercialSegmentEntity?.contact?.superlinea?.numbers?.first
        default:
            return nil
        }
    }
    
    func didTapGlobalSearch() {
        trackEvent(.search, parameters: [:])
        coordinator.goToGlobalSearch()
    }
    
    func didSelectFaqView() {
        trackEvent(.faq, parameters: [:])
    }
    
    func tipCollectionViewDidEndDecelerating() {
        trackEvent(.swipe, parameters: [:])
    }
    
    func didSelectUnderstandButton() {
        trackerManager.trackEvent(screenId: CancelTransferHelpCenterPage().page, eventId: CancelTransferHelpCenterPage.Action.cancel.rawValue, extraParameters: [:])
    }
    
    func didSelectProductOneVIP() {
        guard let offer = self.getOfferForLocation(HelpCenterConstants.helpCenterVIP) else { return }
        self.coordinator.didSelectOffer(offer)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        trackerManager.trackEvent(screenId: "help_center", eventId: eventId, extraParameters: dic)
    }
}

extension HelperCenterPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: HelpCenterPage {
        return HelpCenterPage()
    }
}
