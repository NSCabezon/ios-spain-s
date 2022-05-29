import Foundation
import CoreFoundationLib

class AuthOptionOnboardingViewModel: OnboardingStackItem<AuthOptionOnboardingView> {
    // MARK: - Private attributes
    private let stringLoader: StringLoader
    var switchState: Bool
    private let type: BiometryTypeEntity
    private weak var view: AuthOptionOnboardingView?
    private let change: ((AuthOptionOnboardingViewModel) -> Void)?
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader, type: BiometryTypeEntity, switchState: Bool, change: ((AuthOptionOnboardingViewModel) -> Void)?, insets: OnboardingStackViewInsets = OnboardingStackViewInsets(left: 0, right: 0, top: 0, bottom: 24)) {
        self.stringLoader = stringLoader
        self.type = type
        self.switchState = switchState
        self.change = change
        super.init(insets: insets)
    }
    
    override func bind(view: AuthOptionOnboardingView) {
        view.setType(type, "onboarding_label_faceId", "onboarding_label_touchId", stringLoader)
        view.setDescriptionText(type, "onboarding_text_touchFaceId", "onboarding_text_touchId", stringLoader)
        view.setSwitchText(switchState ? "onboarding_label_enabled" : "onboarding_label_disabled", stringLoader)
        view.isSwitchOn = switchState
        view.switchValueDidChange = { [weak self] switchValue in
            self?.switchState = switchValue
            guard let strongSelf = self else { return }
            self?.change?(strongSelf)
        }
        view.setAccessibilityIdentifiers(type)
        self.view = view
    }
}
