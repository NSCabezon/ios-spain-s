import UIKit.UIPasteboard
import CoreFoundationLib

protocol CustomerServicePresenterProtocol: SideMenuCapable {
    var title: String? { get }
    func didSelect(_ indexPath: IndexPath)
}

enum SocialNetwork {
    case facebook(url: String?, appURL: String?)
    case twitter(url: String?, appURL: String?)
    case googlePlus(url: String?, appURL: String?)
}

typealias ContactData = (title: String?, subtitle: String?, phone1: String?, phone2: String?)

enum CustomerServiceOption {
    case contact([ContactData])
    case whatsApp(detail: String?, phone: String?)
    case email(detail: String?, email: String?)
    case chat(isSmart: Bool)
    case help
    case appointment
    case socialNetworks([SocialNetwork])
    
    var icon: GenericTextIconCellViewModel.Icon? {
        switch self {
        case .contact, .whatsApp, .socialNetworks:
            return nil
        case .email:
            return .email
        case .chat:
            return .chat
        case .help:
            return .help
        case .appointment:
            return .appointment
        }
    }
    
    var title: String? {
        switch self {
        case .contact, .socialNetworks:
            return nil
        case .whatsApp:
            return "support_title_whatsapp"
        case .email:
            return "support_title_email"
        case .chat:
            return "support_title_chat"
        case .help:
            return "support_title_helpYou"
        case .appointment:
            return "support_title_officeDate"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .contact, .socialNetworks:
            return nil
        case .whatsApp:
            return nil
        case .email:
            return "manager_label_descriptionSendEmail"
        case let .chat(isSmart):
            return isSmart ? "support_subtitle_chatSmart" : "support_subtitle_chat"
        case .help:
            return "support_subtitle_helpYou"
        case .appointment:
            return "support_subtitle_officeDate"
        }
    }
}

class CustomerServicePresenter: PrivatePresenter<CustomerServiceViewController, CustomerServiceNavigatorProtocol & PullOffersActionsNavigatorProtocol, CustomerServicePresenterProtocol> {

    typealias Contact = (title: String?, subtitle: String?, phone1: String?, phone2: String?)

    //TODO: (EMMA_REPLACE) replaces emma event IDs for the targes ids
    let customerServiceEventID = "37d188dd073c18e390e889bf5da3881d"
    
    override var screenId: String? {
        if sessionManager.isSessionActive {
            return TrackerPagePrivate.CustomerService(customerServiceEventID: customerServiceEventID).page
        } else {
            return TrackerPagePublic.CustomerService().page
        }
    }
    
    override var emmaScreenToken: String? {
        return TrackerPagePrivate.CustomerService(customerServiceEventID: customerServiceEventID).emmaToken
    }

    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().customerService
    }
    
    var coachmarksToBeSet = [CoachmarkIdentifier]()

    var title: String? {
        return stringLoader.getString("toolbar_title_support").text
    }

    private var whatsAppPhone: String?
    private var _viewPositions = [CoachmarkIdentifier: IntermediateRect]()
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var customerServiceOptions: LoadCustomerServiceOptionsSuperUseCase = {
        let isLoggedIn = sessionManager.isSessionActive
        return dependencies.useCaseProvider.getLoadCustomerServiceOptionsSuperUseCase(useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, isLoggedIn: isLoggedIn)
    }()
    
    override func loadViewData() {
        super.loadViewData()
        getLocationOption()
    }
    
    private func getOptions() {
        customerServiceOptions.build {[weak self] response in
            guard let strongSelf = self else { return }
            var sections = [TableModelViewSection]()
            sections.append(contentsOf: strongSelf.makeOptions(options: response))
            strongSelf.view.loadSections(sections) { [weak self] in
                self?.view.findCoachmarks(neededIds: self?.neededIdentifiers ?? []) { [weak self] coachmarks in
                    self?.setCoachmarks(coachmarks: coachmarks, isForcedCoachmark: false)
                }
            }
        }
    }
    
    private func getLocationOption() {
        let isLoggedIn = sessionManager.isSessionActive
        if isLoggedIn {
            getCandidateOffers { [weak self] candidates in
                self?.presenterOffers = candidates
                self?.getOptions()
            }
        } else {
            getOptions()
        }
    }
    
    private func makeOptions(options: [CustomerServiceOption]?) -> [TableModelViewSection] {
        guard let options = options else { return [] }
        var response = [TableModelViewSection]()
        for option in options {
            switch option {
            case let .contact(contacts):
                let section = TableModelViewSection()
                section.addAll(items: makePhoneCell(contacts))
                response.append(section)
            case let .whatsApp(detail, phone):
                guard let phone = phone else { continue }
                response.append(makeWhatsApp(detail, phone))
            case .email:
                response.append(makeGenericCellOption(option))
            case let .chat(isSmart):
                response.append(makeGenericCellOption(.chat(isSmart: isSmart)))
            case .help:
                response.append(makeGenericCellOption(.help))
            case .appointment:
                if presenterOffers[.CITA_OFICINA] != nil {
                    response.append(makeGenericCellOption(.appointment))
                }
            case let .socialNetworks(networks):
                response.append(makeSocialNetworks(networks))
            }
            
        }
        if let firstSection = response.first {
            let header = CustomerServiceTitleViewModel(title: stringLoader.getString("support_label_help"))
            firstSection.setHeader(modelViewHeader: header)
        }
        return response
    }

    private func makePhoneCell(_ contacts: ([Contact])) -> [PhoneCellViewModel] {
        var response = [PhoneCellViewModel]()
        for (index, content) in contacts.enumerated() {
            let item = PhoneCellViewModel(title: content.title, subtitle: content.subtitle, phone1: content.phone1?.tlfFormatted(), phone2: content.phone2?.tlfFormatted(), dependencies: dependencies)
            item.titleLabelCoachmarkId = .clientAttentionPhone
            item.isFirst = index == 0
            item.isLast = index == contacts.count - 1
            item.isSeparatorVisible = false
            item.didSelect = nil
            item.callPhone1 = { [weak self] in
                guard let phone = content.phone1 else { return }
                self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.call.rawValue, parameters: [TrackerDimensions.tfno: phone])
                self?.navigator.call(number: phone)
            }
            item.callPhone2 = { [weak self] in
                guard let phone = content.phone2 else { return }
                self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.call.rawValue, parameters: [TrackerDimensions.tfno: phone])
                self?.navigator.call(number: phone)
            }
            response.append(item)
        }
        return response
    }
    
    private func makeWhatsApp(_ detail: String?, _ phone: String) -> TableModelViewSection {
        let response = TableModelViewSection()
        let item = WhatsAppCellViewModel(title: stringLoader.getString("support_title_whatsapp"), subtitle: LocalizedStylableText(text: detail ?? "", styles: nil), phone: phone.tlfFormatted(), dependencies: dependencies, buttonTitle: stringLoader.getString("generic_button_copy"), copyDelegate: self)
        whatsAppPhone = phone
        item.tooltipDisplayer = self.view
        item.isFirst = true
        item.isLast = true
        item.isSeparatorVisible = false
        item.didSelect = nil
        response.add(item: item)
        return response
    }
    
    private func makeSocialNetworks(_ networks: [SocialNetwork]) -> TableModelViewSection {
        let response = TableModelViewSection()
        var socialNetworks = [IconButtonsCellViewModel.option]()
        
        for network in networks {
            let socialURL: String?
            let socialAppURL: String?
            let icon: IconButtonsTableViewCell.Icon
            let action: String
            switch network {
            case let .facebook(url: url, appURL: appURL):
                socialURL = url
                socialAppURL = appURL
                icon = IconButtonsTableViewCell.Icon.facebook
                action = TrackerPageCommon.CustomerService.Action.facebook.rawValue
            case let .googlePlus(url: url, appURL: appURL):
                socialURL = url
                socialAppURL = appURL
                icon = IconButtonsTableViewCell.Icon.googlePlus
                action = TrackerPageCommon.CustomerService.Action.google.rawValue
            case let .twitter(url: url, appURL: appURL):
                socialURL = url
                socialAppURL = appURL
                icon = IconButtonsTableViewCell.Icon.twitter
                action = TrackerPageCommon.CustomerService.Action.twitter.rawValue
            }
            socialNetworks.append((icon, { [weak self] in
                self?.trackEvent(eventId: action, parameters: [:])
                self?.navigator.tryOpen(stringUrl: socialAppURL, or: socialURL)
            }))
        }
        
        let item = IconButtonsCellViewModel(options: socialNetworks, dependencies: dependencies)
        response.add(item: item)
        return response
    }
    
    private func makeGenericCellOption(_ option: CustomerServiceOption) -> TableModelViewSection {
        let response = TableModelViewSection()
        let title = stringLoader.getString(option.title ?? "")
        let item = GenericTextIconCellViewModel(title: title, subtitle: stringLoader.getString(option.subtitle ?? ""), icon: option.icon, dependencies: dependencies, buttonTitle: stringLoader.getString("generic_button_write"), buttonAction: nil)
        item.isFirst = true
        item.isLast = true
        item.isSeparatorVisible = false
        switch option {
        case .appointment:
            item.subtitleLabelCoachmarkId = .clientAttentionDate
            item.didSelect = { [weak self] in
                self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.date.rawValue, parameters: [:])
                guard let offer = self?.presenterOffers[.CITA_OFICINA], let offerAction = offer.action else { return }
                self?.executeOffer(action: offerAction, offerId: offer.id, location: PullOfferLocation.CITA_OFICINA)
            }
        case .chat:
            item.didSelect = { [weak self] in
                self?.setupChatCell()
            }
        case let .email(_, email):
            item.didSelect = nil
            item.buttonAction = { [weak self] in
                self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.mail.rawValue, parameters: [:])
                guard let email = email else { return }
                guard let strongSelf = self else { return }
                let share: ShareCase = .mail(delegate: strongSelf.view, content: "", subject: nil, toRecipients: [email], isHTML: false)
                guard share.canShare() else {
                    strongSelf.showError(keyDesc: strongSelf.stringLoader.getString("generic_error_settingsMail").text)
                    return
                }
                share.show(from: strongSelf.view)
            }
        case .help:
            item.didSelect = { [weak self] in
                self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.help.rawValue, parameters: [:])
                self?.openVirtualAssistant()
            }
        default:
            break
        }
        response.add(item: item)
        return response
    }
    
    private func setupChatCell() {
        dependencies.inbentaManager.errorHandler = genericErrorHandler
        dependencies.inbentaManager.getChatInbentaWebViewConfiguration { [weak self] configuration, error in
            guard let configuration = configuration else {
                if error != nil {
                    self?.showError(keyDesc: nil)
                }
                return
            }
            guard let presenter = self else {
                return
            }
            self?.trackEvent(eventId: TrackerPageCommon.CustomerService.Action.chat.rawValue, parameters: [:])
            self?.navigator.goToWebView(with: configuration, linkHandlerType: .chatInbenta, dependencies: presenter.dependencies, errorHandler: presenter.genericErrorHandler, didCloseClosure: nil)
        }
    }
}

extension CustomerServicePresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension CustomerServicePresenter: LocationsResolver {}

extension CustomerServicePresenter: Presenter {}

extension CustomerServicePresenter: CustomerServicePresenterProtocol {
    func didSelect(_ indexPath: IndexPath) {
        let selectedAction = view.sections[indexPath.section].items[indexPath.row] as? Executable
        selectedAction?.execute()
    }
}

extension CustomerServicePresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension CustomerServicePresenter: CopiableInfoHandler {
    
    func copyDescription(tag: Int?, completion: (LocalizedStylableText, String?) -> Void) {
        trackEvent(eventId: TrackerPageCommon.CustomerService.Action.whatsapp.rawValue, parameters: [:])
        guard let whatsAppPhone = whatsAppPhone else { return }
        UIPasteboard.general.string = whatsAppPhone
        completion(stringLoader.getString("generic_label_copy"), whatsAppPhone.tlfFormatted())
    }
}

extension CustomerServicePresenter: CoachmarkPresenter {
    
    var viewPositions: [CoachmarkIdentifier: IntermediateRect] {
        get {
            return self._viewPositions
        }
        set {
            if newValue.count == 0 {
                self._viewPositions = [CoachmarkIdentifier: IntermediateRect]()
            } else {
                for (key, value) in newValue {
                    self._viewPositions[key] = value
                }
            }
        }
    }
    
    func resetCoachmarks() {
        self.viewPositions = [CoachmarkIdentifier: IntermediateRect]()
        self.coachmarksToBeSet = [CoachmarkIdentifier]()
    }
    
    func setCoachmarks(coachmarks: [CoachmarkIdentifier: IntermediateRect], isForcedCoachmark: Bool) {
        
        let callback: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewPositions.count == strongSelf.neededIdentifiers.count && strongSelf.viewPositions.filter({$0.value != IntermediateRect.zero}).count > 0 {
                UseCaseWrapper(with: strongSelf.useCaseProvider.setCoachmarkSeen(input: SetCoachmarkSeenInput(coachmarkIds: strongSelf.coachmarksToBeSet)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler)
                Coachmark.present(source: strongSelf.view, presenter: strongSelf)
                strongSelf.resetCoachmarks()
            }
        }
        
        if coachmarks.count > 0 {
            for coachmark in coachmarks {
                UseCaseWrapper(with: useCaseProvider.isCoachmarkSeen(input: GetCoachmarkStatusUseCaseInput(coachmarkId: coachmark.key)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
                    
                    guard let strongSelf = self else { return }
                    
                    if !result.status && coachmark.value != IntermediateRect.zero {
                        //NO SE HA PINTADO
                        if !strongSelf.coachmarksToBeSet.contains(coachmark.key) {
                            self?.coachmarksToBeSet.append(coachmark.key)
                        }
                        strongSelf.viewPositions[coachmark.key] = coachmark.value
                    } else {
                        strongSelf.viewPositions[coachmark.key] = IntermediateRect.zero
                    }
                    callback()
                })
            }
            
        } else {
            callback()
        }
    }
    
    var neededIdentifiers: [CoachmarkIdentifier] {
        return [.clientAttentionPhone, .clientAttentionDate]
    }
    
    var texts: [CoachmarkIdentifier: String] {
        var output = [CoachmarkIdentifier: String]()
        output[.clientAttentionPhone] = stringLoader.getString("coachmarks_label_customerDigitalService").text
        output[.clientAttentionDate] = stringLoader.getString("coachmarks_label_customerService").text
        return output
    }
}

extension CustomerServicePresenter: VirtualAssistantLauncher {
    var errorHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
    
    var virtualAssistantNavigator: BaseWebViewNavigatable {
        return navigator
    }
}
