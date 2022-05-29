import CoreFoundationLib

protocol LoginMessagesData {
    static var hash: String { get }
}

struct LoginMessagesContext {
    var userPref: UserPrefEntity
    var isOnboardingDisabled: Bool
    var loginMessagesCheckings: [LoginMessagesState: Bool]
    var enableOtpPush: Bool
    var messageOtpPushBeta: Bool
    var isFirstTimeBiometricCredentialActivated: Bool
    var isWhatsNewEnabled: Bool?
    var needUpdatePassword: Bool
    var tutorialBeforeOnboardingOffer: Offer?
    var tutorialOffer: Offer?
    var floatingBannerOffer: Offer?
    
    var isOnboardingCancelled: Bool {
        get {
            return userPref.getOnboardingCancelled()
        }
        set {
            userPref.setOnboardingCancelled(newValue)
        }
    }
    
    var onboardingFinished: Bool {
        get {
            return userPref.getOnboardingFinished()
        }
        set {
            userPref.setOnboardingFinished(newValue)
        }
    }
    
    var otpPushBetaFinished: Bool {
        get {
            return userPref.getOtpPushBetaFinished()
        }
        set {
            userPref.setOtpPushBetaFinished(newValue)
        }
    }
    
    var askedForBiometricPermissions: Bool {
        get {
            return userPref.getAskedForBiometricPermissions()
        }
        set {
            userPref.setAskedForBiometricPermissions(newValue)
        }
    }
    
    var whatsNewCounter: Int {
        get {
            return userPref.getWhatsNewCounter()
        }
        set {
            userPref.setWhatsNewCounter(newValue)
        }
    }
    
    var transitiveAppIcon: AppIconEntity? {
        get {
            return userPref.getTransitiveAppIcon()
        }
        set {
            guard let newIcon = newValue else { return }
            userPref.setTransitiveAppIcon(newIcon)
        }
    }
    
    init(userPref: UserPrefEntity) {
        self.userPref = userPref
        loginMessagesCheckings = [:]
        isOnboardingDisabled = false
        isFirstTimeBiometricCredentialActivated = false
        needUpdatePassword = false
        enableOtpPush = false
        messageOtpPushBeta = false
    }
}
