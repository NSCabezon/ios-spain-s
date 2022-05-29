import Intents
import CoreFoundationLib
import CommonAppExtensions
import RetailLegacy

@available(iOS 12.0, *)
class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        guard intent is CallToManagerIntent || intent is Get123DataIntent || intent is GetBalanceIntent || intent is CallToOfficeIntent else {
            fatalError("No handler defined")
        }
        
        switch intent {
        case is CallToManagerIntent:
            print("CallToManagerIntent")
            return CallToManagerIntentHandler()
        case is CallToOfficeIntent:
            print("CallToOfficeIntent")
        case is GetBalanceIntent:
            print("GetBalanceIntent")
        default:
            print("Get123DataIntent")
        }
        
        fatalError("no handler found!")
    }
}

// MARK: - CallToManager Intent Handling

@available(iOS 12.0, *)
class CallToManagerIntentHandler: NSObject, CallToManagerIntentHandling {
    
    private lazy var dependencies: SiriDependencies = {
        return SiriDependencies()
    }()
    
    func confirm(intent: CallToManagerIntent, completion: @escaping (CallToManagerIntentResponse) -> Void) {
        completion(CallToManagerIntentResponse(code: .success, userActivity: nil))
    }
    
    func handle(intent: CallToManagerIntent, completion: @escaping (CallToManagerIntentResponse) -> Void) {
        getManagers { response in
            switch response {
            case .success(let loginOutput, let managerList):
                switch loginOutput {
                case .login:
                    guard let managers = managerList?.managers, let manager = managers.first else {
                        completion(.init(code: .callOkNoManager, userActivity: nil))
                        return
                    }
                    let responseToSiri = CallToManagerIntentResponse(code: .callOK, userActivity: nil)
                    responseToSiri.managerCode = manager.dto.codGest
                    responseToSiri.availableName = manager.formattedName
                    responseToSiri.availablePhone = manager.phone
                    
                    completion(responseToSiri)
                case .notTokenForLogin:
                    completion(.init(code: .noToken, userActivity: nil))
                }
            case .failure:
                completion(.init(code: .failure, userActivity: nil))
            }
        }
    }
}

enum CallToManagersResponse {
    case success(ExtensionsLoginUseCaseOkOutput, ManagerList?)
    case failure
}

@available(iOS 12.0, *)
@available(iOSApplicationExtension 12.0, *)
extension CallToManagerIntentHandler {
    func getManagers(completion: @escaping (CallToManagersResponse) -> Void) {
        loginCall { [weak self] result in
            guard let result = result else {
                completion(.failure)
                return
            }
            switch result {
            case .login:
                self?.managersCall { managers in
                    completion(.success(result, managers))
                }
            case .notTokenForLogin:
                completion(.success(result, nil))
            }
            
        }
    }
    
    private func loginCall(completion: @escaping (ExtensionsLoginUseCaseOkOutput?) -> Void) {
        let useCaseHandler = dependencies.usecaseHandler
        UseCaseWrapper(with: dependencies.loginUseCase, useCaseHandler: useCaseHandler, onSuccess: { result in
            completion(result)
        }, onError: { error in
            completion(nil)
        })
    }
    
    private func managersCall(completion: @escaping(ManagerList?) -> Void) {
        let useCaseHandler = dependencies.usecaseHandler
        UseCaseWrapper(with: dependencies.getManagersUseCase, useCaseHandler: useCaseHandler, onSuccess: { result in
            completion(result.managers)
        }, onError: { error in
            completion(nil)
        })
    }
}
