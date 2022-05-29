import Foundation
import CoreFoundationLib

class PersonalWithManagerPresenter: PrivatePresenter<PersonalWithManagerViewController, PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol, PersonalWithManagerPresenterProtocol>, PersonalWithManagerPresenterProtocol, SingleSignOn {
    
    var appStoreNavigator: AppStoreNavigatable {
        return navigator
    }
    
    var managersSections =  [TableModelViewSection]()
    var managers: [Manager]
    var otherManagers: [Manager]
    
    private var userId: String?

    // MARK: - TrackerManager

    override var screenId: String? {
        return TrackerPagePrivate.YourPersonalManager().page
    }

    override func getTrackParameters() -> [String: String]? {
        return [TrackerDimensions.numPersonalManagers: "\(managers.count)",
                TrackerDimensions.numOfficeManagers: "\(otherManagers.count)"]
    }

    // MARK: - Location
    var locationTutorial: PullOfferLocation? {
        return PullOffersLocationsFactory().personalManagerTutorial
    }
    
    private func handleCandidateOffers() {
        getCandidateTutorialsOffers { [weak self] offers in
            guard let offer = offers[.MANAGER_TUTORIAL], let action = offer.action else {
                return
            }
            self?.executeOffer(action: action, offerId: offer.id, location: PullOfferLocation.MANAGER_TUTORIAL)
        }
    }

    init(sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol, managers: [Manager], otherManagers: [Manager]) {
        self.managers = managers
        self.otherManagers = otherManagers
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        handleCandidateOffers()
        loadVariables()
    }
    
    func loadVariables() {
        let useCase = dependencies.useCaseProvider.getLoadPersonalWithManagerUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            self?.userId = result.userId
            self?.getInfo(managerWallEnabled: result.managerWallEnabled, videoCallEnabled: result.videoCallEnabled, videoCallSubtitle: result.videoCallSubtitle)
        }, onError: nil)
    }
    
    func getInfo(managerWallEnabled: Bool, videoCallEnabled: Bool, videoCallSubtitle: String?) {
        var sections = [TableModelViewSection]()
        
        let managerProfileSection = ManagerProfileSection()
        
        managers.forEach { (manager) in
            let hideTopSeparator = (managers.first == manager)
            
            let managerProfileViewModel = ProfileManagerViewModel(profileImageURL: "",
                                                                  profileName: manager.formattedName,
                                                                  isHiddenTopSeparator: hideTopSeparator,
                                                                  isPersonalManager: true,
                                                                  managerCode: manager.codGest ?? "",
                                                                  privateComponent: dependencies)
            
            let phoneViewModel = PhoneManagerViewModel(title: stringLoader.getString("manager_label_callMe").uppercased(),
                                                       subtitle: stringLoader.getString("manager_label_24h"),
                                                       phoneNumber: manager.phone,
                                                       note: nil,
                                                       index: 0,
                                                       delegate: view,
                                                       presentation: dependencies)
            
            let videoCallViewModel = PersonalManagerDefaultViewModel(iconImage: "icnVideoCall",
                                                                     title: stringLoader.getString("manager_label_videoCall").uppercased(),
                                                                     subtitle: stringLoader.getString(videoCallSubtitle ?? ""),
                                                                     buttonText: stringLoader.getString("manager_button_request").uppercased(),
                                                                     isHiddenBottomView: false,
                                                                     action: .videoCall,
                                                                     delegate: view,
                                                                     presentation: dependencies)
            
            let mailViewModel = PersonalManagerDefaultViewModel(iconImage: "icnSendEmail",
                                                                title: stringLoader.getString("manager_label_sendEmail").uppercased(),
                                                                subtitle: stringLoader.getString("manager_label_descriptionSendEmail"),
                                                                buttonText: stringLoader.getString("manager_button_write").uppercased(),
                                                                isHiddenBottomView: !managerWallEnabled,
                                                                action: .mail,
                                                                delegate: view,
                                                                presentation: dependencies)
            
            let chatViewModel = PersonalManagerDefaultViewModel(iconImage: "icnChatAgent",
                                                                title: stringLoader.getString("manager_label_chatManage").uppercased(),
                                                                subtitle: stringLoader.getString("manager_label_chat"),
                                                                buttonText: stringLoader.getString("manager_button_start").uppercased(),
                                                                isHiddenBottomView: true,
                                                                action: .chat,
                                                                delegate: view,
                                                                presentation: dependencies)
            
            let opinatorModel = OpinatorManagerViewModel(title: stringLoader.getString("manager_button_opinator"),
                                                         delegate: view,
                                                         presentation: dependencies)
            
            managerProfileSection.add(item: managerProfileViewModel)
            managerProfileSection.items.append(phoneViewModel)
            if videoCallEnabled {
                managerProfileSection.items.append(videoCallViewModel)
            }
            managerProfileSection.items.append(mailViewModel)
            if managerWallEnabled {
                managerProfileSection.items.append(chatViewModel)
            }
            managerProfileSection.items.append(opinatorModel)
        }
        sections.append(managerProfileSection)
        managersSections = sections
        view.reloadData()
    }
    
    func sendMail(at index: Int) {
        self.trackEvent(eventId: TrackerPagePrivate.YourPersonalManager.Action.email.rawValue, parameters: [:])

        guard managers.indices.contains(index) else {
            return
        }
        let subject: String?
        if let userId = userId {
            subject = stringLoader.getString("manager_label_writeMail", [StringPlaceholder(.value, userId)]).text
        } else {
            subject = nil
        }
        
        let share: ShareCase = .mail(delegate: view, content: "", subject: subject, toRecipients: [managers[index].email], isHTML: false)
        guard share.canShare() else {
            showError(keyDesc: "generic_error_settingsMail")
            return
        }
        share.show(from: view)
    }
    
    func startChat() {
        guard let manager = managers.first else {
            return
        }
        dependencies.managerWallManager.errorHandler = genericErrorHandler
        dependencies.managerWallManager.getManagerWallConfigurationWebView(withManager: manager) { [weak self] configuration, error in
            guard let configuration = configuration else {
                if error != nil {
                    self?.showError(keyDesc: nil)
                }
                return
            }
            guard let strongSelf = self else {
                return
            }

            strongSelf.trackEvent(eventId: TrackerPagePrivate.YourPersonalManager.Action.chat.rawValue, parameters: [:])
            strongSelf.navigator.goToWebView(with: configuration,
                                             linkHandlerType: .managerWall,
                                             dependencies: strongSelf.dependencies,
                                             errorHandler: strongSelf.genericErrorHandler,
                                             didCloseClosure: nil)
        }
    }

    func startVideoCall() {
        self.openSingleSignOn(type: .videoCall, parameters: nil)
    }
    
    func opinatorTouched() {
        self.trackEvent(eventId: TrackerPagePrivate.YourPersonalManager.Action.value.rawValue, parameters: [:])

        guard let manager = managers.first else {
            return
        }
        openOpinator(forRegularPage: .yourManager, parametrizable: manager, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }

    func startDate() {
        // Do nothing
    }

    func phoneButtonWasTapped(index: Int) {
        self.trackEvent(eventId: TrackerPagePrivate.YourPersonalManager.Action.call.rawValue, parameters: [:])
        guard let number = URL(string: "tel://\(managers[index].phone.replacingOccurrences(of: " ", with: ""))") else { return }
        navigator.open(number)
    }

}

extension PersonalWithManagerPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

extension PersonalWithManagerPresenter: Presenter {}

extension PersonalWithManagerPresenter: LocationsResolver {}

extension PersonalWithManagerPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}
