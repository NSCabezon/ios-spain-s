protocol LoginMessagesDeterminerProtocol {
    var currentState: LoginMessagesState? { get }
    func determine(handleState: @escaping (LoginMessagesState) -> Void)
    func stateHandled()
}

public enum LoginMessagesState: Int {
    case updateUserPassword = 0
    case updateDeviceToken
    case whatsNew
    case tutorialBeforeOnboarding
    case notificationsPermission
    case globalLocationPermission
    case biometryAuthActivation
    case onboarding
    case signatureActivation
    case tutorial
    case santanderKey
    case alternativeIcon
    case floatingBanner
    case thirdLevelRecovery
    case finished
}

private enum DeterminerState {
    case zero
    case working(state: LoginMessagesState)
    case error
}

class LoginMessagesDeterminer {
    var currentState: LoginMessagesState? {
        guard case .working(let state) = currentStatus else {
            return nil
        }
        return state
    }
    
    private var handle: ((LoginMessagesState) -> Void)?
    private var currentStatus: DeterminerState = .zero
    
    private func prepare() {
        defer {
            work()
        }
        
        guard let first = LoginMessagesState(rawValue: 0) else {
            currentStatus = .error
            return
        }
        currentStatus = .working(state: first)
    }
    
    private func work() {
        switch currentStatus {
        case .zero:
            prepare()
        case .working(let state):
            handle?(state)
        case .error:
            fatalError()
        }
    }
}

extension LoginMessagesDeterminer: LoginMessagesDeterminerProtocol {
    func determine(handleState: @escaping (LoginMessagesState) -> Void) {
        handle = handleState
        work()
    }
    
    func stateHandled() {
        defer {
            work()
        }
        
        guard case .working(let state) = currentStatus, let new = LoginMessagesState(rawValue: state.rawValue + 1) else {
            currentStatus = .error
            return
        }
        dump(state)
        currentStatus = .working(state: new)
    }
}
