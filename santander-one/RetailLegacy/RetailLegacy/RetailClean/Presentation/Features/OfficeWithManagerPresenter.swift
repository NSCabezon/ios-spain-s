import Foundation
import CoreFoundationLib

class OfficeWithManagerPresenter: PrivatePresenter<OfficeWithManagerViewController, PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol, OfficeWithManagerPresenterProtocol>, OfficeWithManagerPresenterProtocol {
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().officeWithManager
    }
    
    var managersSections = [TableModelViewSection]()
    var managers: [Manager]
    var otherManagers: [Manager]
    var index = 0

    // MARK: - TrackerManager

    override var screenId: String? {
        return TrackerPagePrivate.YourManagerOffice().page
    }

    override func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimensions.numPersonalManagers: "\(otherManagers.count)",
            TrackerDimensions.numOfficeManagers: "\(managers.count)"
        ]
    }

    // MARK: -

    private var presenterOffers: [PullOfferLocation: Offer] = [:]

    init(sessionManager: CoreSessionManager,
         dependencies: PresentationComponent,
         navigator: PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol,
         managers: [Manager], otherManagers: [Manager]) {

        self.managers = managers
        self.otherManagers = otherManagers
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        getLocationOption()
    }
        
    func getInfo() {
        var sections = [TableModelViewSection]()
        
        let managerProfileSection = ManagerProfileSection()
        
        managers.forEach { (manager) in
            let hideTopSeparator = (managers.first == manager)
            
            let managerProfileViewModel =
                ProfileManagerViewModel(profileImageURL: "",
                                        profileName: manager.formattedName,
                                        isHiddenTopSeparator: hideTopSeparator,
                                        isPersonalManager: false,
                                        managerCode: "",
                                        privateComponent: dependencies)
            
            let phoneViewModel =
                PhoneManagerViewModel(title: stringLoader.getString("manager_label_callMe").uppercased(),
                                      subtitle: stringLoader.getString("manager_label_hoursOffice"),
                                      phoneNumber: manager.phone,
                                      note: stringLoader.getString("manager_label_descriptionAsterisk"),
                                      index: index,
                                      delegate: view,
                                      presentation: dependencies)
            
            let mailViewModel =
                PersonalManagerDefaultViewModel(iconImage: "icnSendEmail",
                                                title: stringLoader.getString("manager_label_orderEmail").uppercased(),
                                                subtitle: stringLoader.getString("manager_label_descriptionSendEmail"),
                                                buttonText: stringLoader.getString("manager_button_write").uppercased(),
                                                isHiddenBottomView: false,
                                                action: .mail,
                                                delegate: view,
                                                presentation: dependencies)
            
            let dateViewModel =
                PersonalManagerDefaultViewModel(iconImage: "icnAskMeeting",
                                                title: stringLoader.getString("manager_label_requestDate").uppercased(),
                                                subtitle: stringLoader.getString("manager_label_descriptionRequestDate"),
                                                buttonText: stringLoader.getString("manager_button_request").uppercased(),
                                                isHiddenBottomView: true,
                                                action: .date,
                                                delegate: view,
                                                presentation: dependencies)
            
            managerProfileSection.add(item: managerProfileViewModel)
            managerProfileSection.items.append(phoneViewModel)
            managerProfileSection.items.append(mailViewModel)
            
            //LOCATION CITA_GESTOR_OFICINA
            if presenterOffers[.CITA_GESTOR_OFICINA] != nil {
                managerProfileSection.items.append(dateViewModel)
            }
            index += 1
        }
        sections.append(managerProfileSection)
        managersSections = sections
        view.reloadData()
        index = 0
    }
    
    func sendMail(at index: Int) {
        self.trackEvent(eventId: TrackerPagePrivate.YourManagerOffice.Action.email.rawValue, parameters: [:])

        guard managers.indices.contains(index) else {
            return
        }
        let share: ShareCase = .mail(delegate: view, content: "", subject: nil, toRecipients: [managers[index].email], isHTML: false)
        guard share.canShare() else {
            showError(keyDesc: "generic_error_settingsMail")
            return
        }
        share.show(from: view)
    }
    
    func dateWithManager() {
        guard let offer = presenterOffers[.CITA_GESTOR_OFICINA], let offerAction = offer.action else { return }
        executeOffer(action: offerAction, offerId: offer.id, location: PullOfferLocation.CITA_GESTOR_OFICINA)
    }

    func startChat() {
        // Do nothing
    }

    func startViewCall() {
        // Do nothing
    }

    func phoneButtonWasTapped(index: Int) {
        self.trackEvent(eventId: TrackerPagePrivate.YourManagerOffice.Action.call.rawValue, parameters: [:])
        guard let number = URL(string: "tel://\(managers[index].phone.replacingOccurrences(of: " ", with: ""))") else { return }
        navigator.open(number)
    }

    // MARK: - Private

    private func getLocationOption() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
            self?.getInfo()
        }
    }

}

extension OfficeWithManagerPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension OfficeWithManagerPresenter: Presenter {}
extension OfficeWithManagerPresenter: LocationsResolver {}
