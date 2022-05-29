import Foundation
import CoreFoundationLib

class PersonalWithoutManagerPresenter: PrivatePresenter<PersonalWithoutManagerViewController, PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol, PersonalWithoutManagerPresenterProtocol> {
    private let personalManagerWebURL = "https://online.bancosantander.es/sites/santanderpersonal/?form=santanderpersonal&_ga=2.53048360.1637370327.1531153700-101642829.1530720638"
    
    var isEmptyView: Bool
    var otherManagers: [Manager]

    var requirements: [LocalizedStylableText] {
        return [stringLoader.getString("manager_text_productHigherValue"), stringLoader.getString("manager_text_expensestHigherValue"), stringLoader.getString("manager_text_investimentHigherValue")]
    }
    
    var offers: [PersonalManagerOffer] {
        return [
            PersonalManagerOffer(type: .clock, title: stringLoader.getString("manager_label_service24WithoutManager"), subtitle: stringLoader.getString("manager_text_allWeek")),
            PersonalManagerOffer(type: .operative, title: stringLoader.getString("manager_label_operativeWithoutManager"), subtitle: stringLoader.getString("manager_text_contractKey")),
            PersonalManagerOffer(type: .devices, title: stringLoader.getString("manager_label_comfortWithoutManager"), subtitle: stringLoader.getString("manager_text_contractComfort")),
            PersonalManagerOffer(type: .free, title: stringLoader.getString("manager_label_freeServiceWithoutManager"))
        ]
    }

    // MARK: - TrackerManager

    override var screenId: String? {
        return isEmptyView ? TrackerPagePrivate.YourManagerWithoutManager().page : TrackerPagePrivate.YourPersonalManager().page
    }

    override func getTrackParameters() -> [String: String]? {
        if isEmptyView {
            return nil
        } else {
            return [
                TrackerDimensions.numPersonalManagers: "0",
                TrackerDimensions.numOfficeManagers: "\(otherManagers.count)"
            ]
        }
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

    init(sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol, isEmptyView: Bool, otherManagers: [Manager]) {
        self.isEmptyView = isEmptyView
        self.otherManagers = otherManagers
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        view.delegate = self
    }
    
    override func loadViewData() {
        super.loadViewData()
        handleCandidateOffers()
        view.submitButton.setTitle(signUpTitlebutton.text, for: .normal)
        getInfo()
    }

    func onSubmitClick() {
        if isEmptyView {
            self.trackEvent(eventId: TrackerPagePrivate.YourManagerWithoutManager.Action.sign.rawValue, parameters: [:])
        } else {
            self.trackEvent(eventId: TrackerPagePrivate.YourPersonalManager.Action.sign.rawValue, parameters: [:])
        }
        self.signUpDidTouch()
    }

    func getInfo() {
        var sections = [TableModelViewSection]()
        
        let section = ManagerProfileSection()
        
        let titleModel = PersonalWithoutManagerTitleViewModel(dependencies: dependencies, title: title, subtitle: subtitle)
        
        section.add(item: titleModel)
        
        let requirementSectionTitle = PersonalWithoutManagerSectionTitleViewModel(dependencies: dependencies, title: requirementsTitle)
        
        section.add(item: requirementSectionTitle)
        
        for requirement in requirements {
            let requirementViewModel = PersonalManagerRequirementViewModel(dependencies: dependencies, text: requirement)
            section.add(item: requirementViewModel)
        }
        
        let offersSectionTitle = PersonalWithoutManagerSectionTitleViewModel(dependencies: dependencies, title: offersTitle)
        
        section.add(item: offersSectionTitle)
        
        for offer in offers {
            if let subtitle = offer.subtitle {
                section.add(item: PersonalManagerOfferViewModelWithSubtitle(dependencies: dependencies, titleLabel: offer.title, subtitle: subtitle, type: offer.type))
            } else {
                section.add(item: PersonalManagerOfferNoSubtitleViewModel(dependencies: dependencies, titleLabel: offer.title, type: offer.type))
            }
        }
        
        sections.append(section)
        
        view.reloadData(sections: sections)
    }
    
}

extension PersonalWithoutManagerPresenter: PersonalWithoutManagerViewControllerDelegate {
    func signUpDidTouch() {
        guard let signUpURL = URL(string: personalManagerWebURL) else { return }
        navigator.open(signUpURL)
    }
}

extension PersonalWithoutManagerPresenter: PersonalWithoutManagerPresenterProtocol {    
    var title: LocalizedStylableText {
        return stringLoader.getString("manager_title_withoutMenager")
    }
    
    var subtitle: LocalizedStylableText {
        return stringLoader.getString("manager_text_ownManager")
    }
    
    var signUpTitlebutton: LocalizedStylableText {
        return stringLoader.getString("manager_button_emptyView")
    }
    
    var requirementsTitle: LocalizedStylableText {
        return stringLoader.getString("manager_subtitle_keeptoRequirement")
    }
    
    var offersTitle: LocalizedStylableText {
        return stringLoader.getString("manager_subtitle_enjoyAdvantage")
    }
}

extension PersonalWithoutManagerPresenter: Presenter {}

struct PersonalManagerOffer {
    let type: PersonalManagerOfferType
    let title: LocalizedStylableText
    let subtitle: LocalizedStylableText?
    
    init(type: PersonalManagerOfferType, title: LocalizedStylableText, subtitle: LocalizedStylableText? = nil) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
    }
}

extension PersonalWithoutManagerPresenter: LocationsResolver {}

extension PersonalWithoutManagerPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}
