import UIKit
import CoreFoundationLib

class SiriIntentsManager {
    
    weak var delegate: SiriIntentsPresentationDelegate? {
        didSet {
            tryToPerformIntent()
        }
    }
    private let deeplinkManager: DeepLinkManager
    
    private var pendingIntentAction: (() -> Void)?
    private let siriHandler: SiriAssistantProtocol
    
    init(deeplinkManager: DeepLinkManager, siriHandler: SiriAssistantProtocol) {
        self.deeplinkManager = deeplinkManager
        self.siriHandler = siriHandler
    }
    
    private func call(toPhone phone: String) {
        guard let phoneUrl = URL(string: "tel://" + phone.replacingOccurrences(of: " ", with: "")) else {
            return
        }
        open(phoneUrl)
    }
}

extension SiriIntentsManager: UrlActionsCapable {}

extension SiriIntentsManager: UserActivityHandler {
    struct Constants {
        struct Offers {
            let callToManagerIntent = "SIRI_CONTRATAR_GESTOR_PERSONAL"
        }
    }
    
    func shouldContinueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let intentResponseCode = self.siriHandler.getSiriIntentResponseCode(userActivity: userActivity) else {
            return false
        }
        handle(intentResponseCode)
        return true
    }
    
    private func handle(_ intentResponse: SiriIntentResponseCode) {
        switch intentResponse {
        case .callOK(let phone):
            pendingIntentAction = { [weak self] in
                self?.call(toPhone: phone)
            }
            tryToPerformIntent()
        case .callOkNoManager:
            deeplinkManager.registerDeepLink(DeepLink.offerLink(identifier: Constants.Offers().callToManagerIntent, location: nil))
        case .noToken:
            deeplinkManager.registerDeepLink(DeepLink.personalArea)
        default: break
        }
    }
    
    private func tryToPerformIntent() {
        if let pendingAction = pendingIntentAction, delegate?.letPerformIntent == true {
            pendingAction()
            delegate?.intentDidPerform()
            pendingIntentAction = nil
        }
    }
}

extension SiriIntentsManager: SiriIntentsManagerProtocol {
    func setDelegate(_ delegate: SiriIntentsPresentationDelegate) {
        self.delegate = delegate
    }
}
