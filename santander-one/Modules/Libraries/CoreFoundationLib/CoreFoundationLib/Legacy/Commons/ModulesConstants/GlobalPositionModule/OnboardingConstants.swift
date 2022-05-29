
public struct OnboardingPage: PageTrackable {
    public let page = "/onboarding"
    public init() {}
}

public struct OnboardingLanguage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/onboarding/language"
    public enum Action: String {
        case continueAction = "click_continue_onboarding"
    }
    public init() {}
}

public struct OnboardingOptions: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/onboarding/option"
    public enum Action: String {
        case biometric = "unlock_biometric"
        case biometricError = "error_{step1_step2}"
        case notifications = "unlock_notification"
        case geolocation = "unlock_geolocation"
    }
    public init() {}
}

public struct OnboardingPg: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/onboarding/personalize_global_position"
    public enum Action: String {
        case swipe = "swipe_option"
        case continueAction = "click_continue_onboarding"
    }
    public init() {}
}

public struct OnboardingPhoto: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/onboarding/photo"
    public enum Action: String {
        case swipe = "swipe_photo"
        case continueAction = "click_continue_onboarding"
    }
    public init() {}
}

public struct OnboardingFinal: PageTrackable {
    public let page = "/onboarding/confirmation"
    public init() {}
}
