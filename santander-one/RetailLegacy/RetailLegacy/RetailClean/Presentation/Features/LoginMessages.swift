import CoreFoundationLib

protocol LoginMessagesProtocol {
    var isPaused: Bool { get set }
    func resume()
    func stateHandled(state: LoginMessagesState, value: Bool)
    func update(state: LoginMessagesState, withValue value: Bool, completion: (() -> Void)?)
    func getData<T: LoginMessagesData>(state: LoginMessagesState) -> T?
    func disableOnboarding(completion: @escaping () -> Void)
    func finishOnboarding()
}

extension LoginMessagesProtocol {
    func update(state: LoginMessagesState, withValue value: Bool) {
        update(state: state, withValue: value, completion: nil)
    }
}

protocol LoginMessagesDelegate: class {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var useCaseErrorHandler: UseCaseErrorHandler { get }
    func handle(state: LoginMessagesState)
}

final class LoginMessages {
    private typealias LoginMessagesStorage = [String: LoginMessagesData]
    var isPaused = false
    private var alreadyChangedForcedPassword = false
    weak var delegate: LoginMessagesDelegate?
    
    private var determiner: LoginMessagesDeterminerProtocol? = LoginMessagesDeterminer()
    private var dataContainer: [LoginMessagesState: LoginMessagesStorage] = [:]
    private var context: LoginMessagesContext?
    
    private var allCheckingsDone: Bool {
        return determiner == nil
    }
    
    private func annotate(state: LoginMessagesState, value: Bool, completion: @escaping () -> Void) {
        set(value: value, forState: state)
        saveContext(completion: completion)
    }
    
    private func didCheck(state: LoginMessagesState) -> Bool {
        return context?.loginMessagesCheckings[state] ?? false
    }
    
    private func set(value: Bool, forState state: LoginMessagesState) {
        switch state {
        case .onboarding:
            context?.loginMessagesCheckings[state] = value
        case .tutorialBeforeOnboarding,
             .signatureActivation,
             .tutorial,
             .finished,
             .updateDeviceToken,
             .santanderKey,
             .floatingBanner,
             .notificationsPermission,
             .globalLocationPermission,
             .whatsNew,
             .alternativeIcon,
             .thirdLevelRecovery:
            context?.loginMessagesCheckings[state] = value
        case .biometryAuthActivation:
            if value { context?.askedForBiometricPermissions = true }
            context?.loginMessagesCheckings[state] = value
        case .updateUserPassword:
            context?.loginMessagesCheckings[state] = value
        }
    }
    
    private func saveContext(completion: @escaping () -> Void) {
        guard let delegate = delegate else {
            completion()
            return
        }
        let input = SetLoginMessagesContextUseCaseInput(context: context)
        let useCase = delegate.useCaseProvider.setLoginMessagesContextUseCase(input: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: delegate.useCaseHandler,
            errorHandler: delegate.useCaseErrorHandler,
            onSuccess: { _ in
            completion()
        }, onError: { _ in
            completion()
        })
    }
    
    private func loadCheckings(completion: @escaping () -> Void) {
        guard let delegate = delegate else {
            completion()
            return
        }
        let useCase = delegate
            .useCaseProvider
            .getLoginMessagesContextUseCase()
        UseCaseWrapper(with: useCase,
                       useCaseHandler: delegate.useCaseHandler,
                       errorHandler: delegate.useCaseErrorHandler,
                       queuePriority: Operation.QueuePriority.veryHigh,
                       onSuccess: { [weak self] result in
                        self?.context = result.context
                        completion()
            }, onError: { _ in
                completion()
        })
    }
    
    private func handleStateInPresentation(_ state: LoginMessagesState) {
        guard !isPaused else {
            return
        }
        delegate?.handle(state: state)
    }
}

extension LoginMessages {
    private func evaluate() {
        determiner?.determine { [weak self] state in
            switch state {
            case .globalLocationPermission:
                self?.evaluateAskLocationPermissions()
            case .notificationsPermission:
                self?.evaluateAskPushNotifications()
            case .biometryAuthActivation:
                self?.evaluateAskBiometricPermissions()
            case .updateDeviceToken:
                self?.evaluateStart()
            case .signatureActivation:
                self?.evaluateSignatureActivation()
            case .tutorialBeforeOnboarding:
                self?.evaluateTutorialBeforeOnboarding()
            case .onboarding:
                self?.evaluateOnboarding()
            case .tutorial:
                self?.evaluateTutorial()
            case .santanderKey:
                self?.evaluateSantanderKey()
            case .floatingBanner:
                self?.evaluateFloatingBanner()
            case .whatsNew:
                self?.evaluateWhatsNew()
            case .alternativeIcon:
                self?.evaluateAlternativeIcon()
            case .thirdLevelRecovery:
                self?.evaluateThirdLevelRecovery()
            case .updateUserPassword:
                self?.evaluateNeedUpdatePassword()
            case .finished:
                self?.determiner = nil
                self?.delegate?.handle(state: state)
            }
        }
    }
    
    private func evaluateSignatureActivation() {
        guard let delegate = delegate,
            !didCheck(state: .signatureActivation) else {
                stateHandled(state: .signatureActivation, value: false)
                return
        }
        let useCase = delegate.useCaseProvider.getSignatureActivationStateUseCase()
        UseCaseWrapper(with: useCase,
                       useCaseHandler: delegate.useCaseHandler,
                       errorHandler: delegate.useCaseErrorHandler,
                       onSuccess: { [weak self] response in
                        if response.isSignatureActivationPending {
                            self?.delegate?.handle(state: .signatureActivation)
                        } else {
                            self?.stateHandled(state: .signatureActivation, value: true)
                        }
            }, onError: { [weak self] _ in
                self?.stateHandled(state: .signatureActivation, value: false)
        })
    }
    
    private func evaluateSantanderKey(){
        guard
            !didCheck(state: .santanderKey),
            context?.enableOtpPush == true
            else {
                stateHandled(state: .santanderKey, value: true)
                return
        }
        handleStateInPresentation(.santanderKey)
    }
    
    private func evaluateStart() {
        guard !didCheck(state: .updateDeviceToken) else {
            stateHandled(state: .updateDeviceToken, value: true)
            return
        }
        handleStateInPresentation(.updateDeviceToken)
    }
    
    private func evaluateOnboarding() {
        guard
            context?.isOnboardingDisabled != true,
            context?.onboardingFinished != true,
            context?.isOnboardingCancelled != true,
            !didCheck(state: .onboarding)
            else {
                stateHandled(state: .onboarding, value: true)
                return
        }
        handleStateInPresentation(.onboarding)
    }
    
    private func evaluateTutorialBeforeOnboarding() {
        guard
            !didCheck(state: .tutorialBeforeOnboarding),
            let offer = context?.tutorialBeforeOnboardingOffer
            else {
                stateHandled(state: .tutorialBeforeOnboarding, value: true)
                return
        }
        saveToContainer(data: offer, step: .tutorialBeforeOnboarding)
        handleStateInPresentation(.tutorialBeforeOnboarding)
    }
    
    private func evaluateTutorial() {
        guard
            !didCheck(state: .tutorial),
            let offer = context?.tutorialOffer
            else {
                stateHandled(state: .tutorial, value: true)
                return
        }
        saveToContainer(data: offer, step: .tutorial)
        handleStateInPresentation(.tutorial)
    }
    
    private func evaluateWhatsNew() {
        guard
            !didCheck(state: .whatsNew),
            context?.isWhatsNewEnabled == true
            else {
                stateHandled(state: .whatsNew, value: true)
                return
        }
        handleStateInPresentation(.whatsNew)
    }
    
    private func evaluateThirdLevelRecovery() {
        guard !didCheck(state: .thirdLevelRecovery) else {
            return stateHandled(state: .thirdLevelRecovery, value: true)
        }
        handleStateInPresentation(.thirdLevelRecovery)
    }
    
    private func evaluateFloatingBanner() {
        guard
            !didCheck(state: .floatingBanner),
            let offer = context?.floatingBannerOffer
            else {
                stateHandled(state: .floatingBanner, value: true)
                return
        }
        saveToContainer(data: offer, step: .floatingBanner)
        handleStateInPresentation(.floatingBanner)
    }
    
    private func evaluateAskPushNotifications() {
        guard
            context?.isOnboardingCancelled == true,
            !didCheck(state: .notificationsPermission)
            else {
                stateHandled(state: .notificationsPermission, value: false)
                return
        }
        self.delegate?.handle(state: .notificationsPermission)
    }
    
    private func evaluateAskBiometricPermissions() {
        guard
            context?.isOnboardingCancelled == true,
            !didCheck(state: .biometryAuthActivation),
            context?.isFirstTimeBiometricCredentialActivated != true,
            context?.askedForBiometricPermissions != true
            else { return stateHandled(state: .biometryAuthActivation, value: false) }
        self.delegate?.handle(state: .biometryAuthActivation)
    }
    
    private func evaluateAskLocationPermissions() {
        guard context?.isOnboardingCancelled == true,
            !didCheck(state: .globalLocationPermission)
            else {
                stateHandled(state: .globalLocationPermission, value: false)
                return
        }
        self.delegate?.handle(state: .globalLocationPermission)
    }
    
    private func evaluateNeedUpdatePassword() {
        guard
            context?.needUpdatePassword == true,
            !didCheck(state: .updateUserPassword)
        else {
            return stateHandled(state: .updateUserPassword, value: true)
        }
        self.delegate?.handle(state: .updateUserPassword)
    }
    
    private func saveToContainer<T: LoginMessagesData>(data: T, step: LoginMessagesState) {
        if dataContainer[step] == nil {
            dataContainer[step] = [:]
        }
        dataContainer[step]?[T.hash] = data
    }
}

extension LoginMessages: LoginMessagesProtocol {
    
    func resume() {
        isPaused = false
        guard !allCheckingsDone else {
            handleStateInPresentation(.finished)
            return
        }
        guard context == nil else {
            evaluate()
            return
        }
        loadCheckings { [weak self] in
            self?.evaluate()
        }
    }
    
    func stateHandled(state: LoginMessagesState, value: Bool) {
        annotate(state: state, value: value) {}
        guard
            !isPaused,
            determiner?.currentState == state
            else { return }
        determiner?.stateHandled()
    }
    
    func update(state: LoginMessagesState, withValue value: Bool, completion: (() -> Void)?) {
        annotate(state: state, value: value) { completion?() }
    }
    
    func getData<T: LoginMessagesData>(state: LoginMessagesState) -> T? {
        return dataContainer[state]?[T.hash] as? T
    }
    
    func disableOnboarding(completion: @escaping () -> Void) {
        context?.isOnboardingCancelled = true
        annotate(state: .onboarding, value: false, completion: completion)
    }
    
    func finishOnboarding() {
        context?.onboardingFinished = true
        stateHandled(state: .onboarding, value: true)
    }
    
    func saveWhatsNewCounter() {
        guard let counter = context?.whatsNewCounter else { return }
        context?.whatsNewCounter = counter + 1
        stateHandled(state: .whatsNew, value: false)
    }
    
    func saveValidCampaign(_ icon: AppIconEntity) {
        context?.transitiveAppIcon = icon
        stateHandled(state: .alternativeIcon, value: false)
    }
}

private extension LoginMessages {
    func evaluateAlternativeIcon() {
        handleStateInPresentation(.alternativeIcon)
    }
}
