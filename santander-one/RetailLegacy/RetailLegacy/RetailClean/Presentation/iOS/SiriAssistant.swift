import SANLegacyLibrary
import Intents
import CoreFoundationLib

class SiriAssistant {
    let appConfigRepository: AppConfigRepository
    let appRepository: AppRepository
    let bsanManagersProvider: BSANManagersProvider
    let siriHandler: SiriAssistantProtocol
    
    init(appConfigRepository: AppConfigRepository, appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider, siriHandler: SiriAssistantProtocol) {
        self.appConfigRepository = appConfigRepository
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.siriHandler = siriHandler
    }
    
    func donateIntents() {
        guard #available(iOS 12.0, *) else {
            return
        }
        self.siriHandler.donate {[weak self] intent in
            guard let intent = intent else {
                return
            }
            self?.donate(intent: intent)
        }
    }
    
    func deleteIntents() {
        guard #available(iOS 12.0, *) else {
            return
        }
        deleteAllIntents()
    }
}

extension SiriAssistant: UserManagersGetter {}

// MARK: Siri Intents
@available(iOS 12.0, *)
extension SiriAssistant {
    private func donate(intent: INIntent) {
        deleteAllIntents {
            INInteraction(intent: intent, response: nil).donate { (error) in
                if let error = error {
                    print("'intCall'" + error.localizedDescription)
                } else {
                    print("'intCall' Shortcut donated")
                }
            }
        }
    }
    
    private func deleteAllIntents(completion: (() -> Void)? = nil) {
        INInteraction.deleteAll(completion: { _ in
            completion?()
        })
    }
}

