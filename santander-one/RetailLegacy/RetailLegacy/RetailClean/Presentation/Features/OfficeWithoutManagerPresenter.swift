import Foundation
import CoreFoundationLib

class OfficeWithoutManagerPresenter: PrivatePresenter<OfficeWithoutManagerViewController, PersonalManagerNavigatorProtocol, OfficeWithoutManagerPresenterProtocol>, OfficeWithoutManagerDelegate {
    let officeManagerWebURL = "https://online.bancosantander.es/forms/gestoroficina-app/"

    var otherManagers: [Manager]

    // MARK: - TrackerManager

    override var screenId: String? {
        return TrackerPagePrivate.YourManagerOffice().page
    }

    override func getTrackParameters() -> [String: String]? {
        return [
            "num_gestores_sant_personal": "\(otherManagers.count)",
            "num_gestores_oficina": "0"
        ]
    }

    // MARK: -

    init(sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: PersonalManagerNavigatorProtocol, otherManagers: [Manager]) {
        self.otherManagers = otherManagers
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        view.delegate = self
    }

    func signUpButtonDidTouched() {
        self.trackEvent(eventId: TrackerPagePrivate.YourManagerOffice.Action.sign.rawValue, parameters: [:])
        guard let signUpURL = URL(string: officeManagerWebURL) else { return }
        navigator.open(signUpURL)
    }

}

extension OfficeWithoutManagerPresenter: OfficeWithoutManagerPresenterProtocol {
    
    var title: LocalizedStylableText {
        return stringLoader.getString("manager_title_withoutMenager")
    }
    
    var subtitle: LocalizedStylableText {
        return stringLoader.getString("manager_text_withoutMenagerOfice")
    }
    
    var signUpTitlebutton: LocalizedStylableText {
        return stringLoader.getString("manager_button_emptyView")
    }
    
    var stackViewOneConfig: PersonalManagerStackViewConfig {
        return ("icnDevicesManager",
                stringLoader.getString("manager_label_contact"),
                stringLoader.getString("manager_text_contact"))
    }
    
    var stackViewTwoConfig: PersonalManagerStackViewConfig {
        return ("icnMeetingManager",
                stringLoader.getString("manager_label_date"),
                stringLoader.getString("manager_text_date"))
    }
}
